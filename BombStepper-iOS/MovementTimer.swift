//
//  MovementTimer.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/// DAS, gravity and soft drop fires continuously
/// Delayed lock fires once and resets
final class MovementTimer {


    enum TimedMoveType {
        case das(XDirection)
        case gravity
        case softDrop
        case delayedLock(FieldManipulator.PieceLandingStatus)
    }


    fileprivate enum DASStatus {
        case none
        case pending(XDirection, fire: MachAbsTime)
        case imminent(XDirection)   // Only when mach_waiting, within 1 frame time
        case active(XDirection)

        var direction: XDirection? {
            switch self {
            case .pending(let d, _), .imminent(let d), .active(let d):
                return d
            default:
                return nil
            }
        }
    }


    var moveAction: ((_ direction: Direction, _ steps: Int) -> Void)?
    var lockAction: (() -> Void)?
    

    fileprivate var mostRecentUpdateTime: TimeInterval = 0

    fileprivate var gravityStarted = false
    fileprivate var gravityStartTime: TimeInterval = 0

    // Soft drop & DAS continuously fires with each frame
    fileprivate var softDropStarted = false
    fileprivate var softDropFrames = 1
    fileprivate var softDropFrameCounter = 0

    fileprivate var dasStatus: DASStatus = .none
    fileprivate var dasDelay: MachAbsTime = msToAbs(8 * 1000 / 60)  // Updates on settings manager callback
    // High priority queue for mach_wait for precision DAS firing
    fileprivate let dasPendingQueue = DispatchQueue(label: "net.mathemusician.BombStepper.MovementTimer", qos: .userInteractive)
    fileprivate var dasFrames = 1
    fileprivate var dasFrameCounter = 0

    fileprivate var lockDelayStarted = false
    fileprivate var lockDelayQuota: TimeInterval = Timing.lockDelay
    fileprivate var lockDelayExtensionQuota: TimeInterval = Timing.lockDelayExtension

    func startTiming(_ type: TimedMoveType) {
        switch type {
        case .das(let d): startDAS(d)
        case .gravity:    startGravity()
        case .softDrop:   startSoftDrop()
        case .delayedLock(.floating): assertionFailure("This doesn't make sense")
        case .delayedLock(.landed): startDelayedLock()
        case .delayedLock(.landedMoved): extendDelayedLock()
        }
    }
    
    func stopTiming(_ type: TimedMoveType) {
        switch type {
        case .das(let d):  stopDAS(d)
        case .gravity:     stopGravity()
        case .softDrop:    stopSoftDrop()
        case .delayedLock: stopDelayedLock(); extendDelayedLock()
        }
    }
    
    // Soft locking is cumulative for one piece, so it can start/stop multiple times, and needs to be explicit reset.
    // Resetting also stops.
    func resetDelayedLock() {
        lockDelayStarted = false
        lockDelayQuota = Timing.lockDelay
        lockDelayExtensionQuota = Timing.lockDelayExtension
    }

    func resetAll() {
        gravityStarted = false
        softDropStarted = false
        resetDelayedLock()
        dasStatus = .none
        dasFrameCounter = 0
    }

}


private extension MovementTimer {

    func startDAS(_ direction: XDirection) {
        let dasFireTime = mach_absolute_time() + dasDelay
        dasStatus = DASStatus.pending(direction, fire: dasFireTime)
    }

    func stopDAS(_ direction: XDirection) {
        if direction == dasStatus.direction {
            dasStatus = .none
        }
    }
    
    func startSoftDrop() {
        softDropFrameCounter = 0
        softDropStarted = true
        fireSoftDrop()
    }

    func stopSoftDrop() {
        softDropStarted = false
    }

    func startGravity() {
        gravityStarted = true
        gravityStartTime = mostRecentUpdateTime
    }

    func stopGravity() {
        gravityStarted = false
    }

    func startDelayedLock() {
        lockDelayStarted = true
    }

    func extendDelayedLock() {
        let idealExtensionLength = Timing.lockDelay - lockDelayQuota
        let grantedExtension = min(idealExtensionLength, lockDelayExtensionQuota)
        lockDelayQuota += grantedExtension
        lockDelayExtensionQuota -= grantedExtension
    }

    // This only happens when a piece was touching ground, then left it.  So gravity is reset.
    func stopDelayedLock() {
        lockDelayStarted = false
        gravityStartTime = mostRecentUpdateTime
    }
}


extension MovementTimer: GameSceneUpdatable {

    func update(_ currentTime: TimeInterval) {
        if gravityStarted   { gravityTick() }
        if softDropStarted  { softDropTick() }
        if lockDelayStarted { lockDelayTick(elapsed: currentTime - mostRecentUpdateTime) }
        switch dasStatus {
        case .pending(let direction, fire: let t):
            activateDASIfNeeded(direction: direction, fireTime: t)
        case .active(let direction):
            dasTick(direction: direction)
        default:
            break
        }

        mostRecentUpdateTime = currentTime
    }

    func activateDASIfNeeded(direction: XDirection, fireTime: MachAbsTime) {
        let now = mach_absolute_time()

        guard fireTime < now + singleFrameTime else { return }

        if fireTime < now {
            dasStatus = .active(direction)
            dasTick(direction: direction)
        }
        else {
            dasStatus = .imminent(direction)
            dasPendingQueue.async {
                mach_wait_until(fireTime)
                if case .imminent(let d) = self.dasStatus, d == direction {
                    self.dasStatus = .active(direction)
                    self.dasTick(direction: direction)
                }
            }
        }
    }
}

private extension MovementTimer {

    func gravityTick() {
        if mostRecentUpdateTime > gravityStartTime + 1 {
            fireGravityDrop()
        }
    }

    func softDropTick() {
        softDropFrameCounter += 1
        if softDropFrameCounter >= softDropFrames {
            fireSoftDrop()
        }
    }

    func lockDelayTick(elapsed: TimeInterval) {
        lockDelayQuota -= elapsed
        if lockDelayQuota < 0 {
            fireLock()
        }
    }

    func dasTick(direction: XDirection) {
        dasFrameCounter += 1
        if dasFrameCounter >= dasFrames {
            fireDAS(xDirection: direction)
        }
    }

}


private extension MovementTimer {

    func fireGravityDrop() {
        // If the app's been inactive, just drop once and advance time
        moveAction?(.down, 1)
        let elapsed = mostRecentUpdateTime - gravityStartTime
        gravityStartTime += elapsed.rounded(.down)
    }

    func fireSoftDrop() {
        let dropBy = (softDropFrames == 0) ? Int.max : 1
        moveAction?(.down, dropBy)
        softDropFrameCounter = 0
    }

    func fireLock() {
        lockAction?()
        resetDelayedLock()
    }

    func fireDAS(xDirection: XDirection) {
        let dasBy = (dasFrames == 0) ? Int.max : 1
        moveAction?(Direction(xDirection), dasBy)
        dasFrameCounter = 0
    }

}

extension MovementTimer: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        softDropFrames = settings.softDropFrames
        dasDelay = msToAbs(Double(settings.dasValue) * 1000 / 60)
        dasFrames = settings.dasFrames
    }
}


