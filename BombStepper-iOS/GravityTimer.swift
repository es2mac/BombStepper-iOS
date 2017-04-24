//
//  GravityTimer.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


class GravityTimer {

    var dropAction: ((_ dropBy: Int) -> Void)?

    fileprivate var started = false
    fileprivate var lastUpdateTime: TimeInterval = 0
    fileprivate var lastGravityDropTime: TimeInterval = 0

    init(dropAction: ((Int) -> Void)? = nil) {
        self.dropAction = dropAction
    }

    func start() {
        started = true
        lastGravityDropTime = lastUpdateTime
    }

    func stop() {
        started = false
    }
}


extension GravityTimer: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {
        
        lastUpdateTime = currentTime

        if started, currentTime - lastGravityDropTime > 1 {
            let dropBy = Int(currentTime - lastGravityDropTime)
            dropAction?(dropBy)
            lastGravityDropTime += Double(dropBy)
        }
    }
}



