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
        case das
        case gravity
        case softDrop
    }
    
    var moveAction: ((_ direction: Direction, _ steps: Int) -> Void)?

    fileprivate var lastUpdateTime: TimeInterval = 0
    fileprivate var gravityStarted = false
    fileprivate var lastGravityDropTime: TimeInterval = 0
    
    func startTiming(_ type: TimedMoveType) {
        switch type {
        case .das:      startDAS()
        case .gravity:  startGravity()
        case .softDrop: startSoftDrop()
        }
    }
    
    func stopTiming(_ type: TimedMoveType) {
        switch type {
        case .das:      stopDAS()
        case .gravity:  stopGravity()
        case .softDrop: stopSoftDrop()
        }
    }

}


private extension MovementTimer {

    func startDAS() { }
    func stopDAS() { }

    func startSoftDrop() { }
    func stopSoftDrop() { }

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
    }

    private func updateGravity() {

        let elapsed = lastUpdateTime - lastGravityDropTime

        if gravityStarted, elapsed > 1 {
            let dropBy = Int(elapsed)
            moveAction?(.down, dropBy)
            lastGravityDropTime += Double(dropBy)
        }
    }
}



