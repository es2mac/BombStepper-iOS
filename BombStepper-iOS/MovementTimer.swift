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
        case delayedLock(Field.BottomTouchingStatus)
    }


    var moveAction: ((_ direction: Direction, _ steps: Int) -> Void)?
    var lockAction: (() -> Void)?
    

    fileprivate var lastUpdateTime: TimeInterval = 0

    fileprivate var gravityStarted = false
    fileprivate var lastGravityDropTime: TimeInterval = 0

    // Soft drop & DAS continuously fires with each frame
    fileprivate var softDropStarted = false
    fileprivate var softDropFrames = 1
    fileprivate var softDropFrameCounter = 0

    fileprivate var dasDirection: XDirection?
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
        case .delayedLock(.touching): startDelayedLock()
        case .delayedLock(.touchingMoved): extendDelayedLock()
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

}

// TODO: when piece touch the ground and off again, gravity time should reset


private extension MovementTimer {

    func startDAS(_ direction: XDirection) {
        dasFrameCounter = 0
        dasDirection = direction
        fireDAS(xDirection: direction)
    }

    func stopDAS(_ direction: XDirection) {
        if dasDirection == direction {
            dasDirection = nil
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
        lastGravityDropTime = lastUpdateTime
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

    func stopDelayedLock() {
        lockDelayStarted = false
    }
}


extension MovementTimer: GameSceneUpdatable {

    func update(_ currentTime: TimeInterval) {
        let elapsed = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if gravityStarted   { updateGravity() }
        if softDropStarted  { updateSoftDrop() }
        if lockDelayStarted { updateLockDelay(elapsed: elapsed) }
        dasDirection.map(updateDAS)
    }
}

private extension MovementTimer {

    func updateGravity() {
        let elapsed = lastUpdateTime - lastGravityDropTime
        if elapsed > 1 {
            let dropBy = Int(elapsed)
            moveAction?(.down, dropBy)
            lastGravityDropTime += Double(dropBy)
        }
    }

    func updateSoftDrop() {
        softDropFrameCounter += 1
        if softDropFrameCounter >= softDropFrames {
            softDropFrameCounter = 0
            fireSoftDrop()
        }
    }

    func fireSoftDrop() {
        let dropBy = (softDropFrames == 0) ? Int.max : 1
        moveAction?(.down, dropBy)
    }

    func updateDAS(direction: XDirection) {
        dasFrameCounter += 1
        if dasFrameCounter >= dasFrames {
            dasFrameCounter = 0
            fireDAS(xDirection: direction)
        }
    }

    func fireDAS(xDirection: XDirection) {
        let dasBy = (dasFrames == 0) ? Int.max : 1
        moveAction?(Direction(xDirection), dasBy)
    }

    func updateLockDelay(elapsed: TimeInterval) {
        lockDelayQuota -= elapsed
        if lockDelayQuota < 0 {
            lockDelayStarted = false
            fireLock()
        }
    }

    func fireLock() {
        lockAction?()
        resetDelayedLock()
    }

}

extension MovementTimer: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        softDropFrames = settings.softDropFrames
        dasFrames = settings.dasFrames
    }
}


