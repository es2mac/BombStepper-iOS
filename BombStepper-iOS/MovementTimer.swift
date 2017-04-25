//
//  MovementTimer.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


final class MovementTimer {

    enum TimedMoveType {
        case das(XDirection)
        case gravity
        case softDrop
    }
    
    var moveAction: ((_ direction: Direction, _ steps: Int) -> Void)?

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

    func startTiming(_ type: TimedMoveType) {
        switch type {
        case .das(let d): startDAS(d)
        case .gravity:    startGravity()
        case .softDrop:   startSoftDrop()
        }
    }
    
    func stopTiming(_ type: TimedMoveType) {
        switch type {
        case .das(let d): stopDAS(d)
        case .gravity:    stopGravity()
        case .softDrop:   stopSoftDrop()
        }
    }

}


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
}


extension MovementTimer: GameSceneUpdatable {

    func update(_ currentTime: TimeInterval) {
        lastUpdateTime = currentTime
        updateGravity()
        updateSoftDrop()
        updateDAS()
    }
}

private extension MovementTimer {

    func updateGravity() {
        let elapsed = lastUpdateTime - lastGravityDropTime
        if gravityStarted, elapsed > 1 {
            let dropBy = Int(elapsed)
            moveAction?(.down, dropBy)
            lastGravityDropTime += Double(dropBy)
        }
    }

    func updateSoftDrop() {
        guard softDropStarted else { return }
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

    func updateDAS() {
        guard let direction = dasDirection else { return }
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
}

extension MovementTimer: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        softDropFrames = settings.softDropFrames
        dasFrames = settings.dasFrames
    }
}


