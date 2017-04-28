//
//  GameCoordinator.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/28/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


enum LineClear {
    case normal(lines: Int)
    case TSpin(lines: Int)  // 3+ corners, clears 1+ lines except those matching mini rule
    case TSpinMini          // Exactly 3 corners, clears one line, not immobile
}


protocol GameCoordinator: GameEventDelegate {
    func modeSpecificNodes() -> [SKNode]
}

/*
 Coordinator handles the rules for game mode objectives
 Coordinator -> view controller:
 - Dismiss
 
 Coordinator -> tetris system:
 - Stop game, objective reached
 
 Coordinator -> game scene:
 - hand over the nodes, but keeping a reference and manipulate itself
 
 It needs to be able to tell the system to end
 System needs to tell the
 */

class DummyCoordinator: GameCoordinator {
    
    var gameEndAction: (() -> Void)?
    
    func modeSpecificNodes() -> [SKNode] { return [] }
    
    func linesCleared(_ lineClear: LineClear) {
        print(lineClear)
    }
    
}

