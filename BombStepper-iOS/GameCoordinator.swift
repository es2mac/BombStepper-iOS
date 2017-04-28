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
    case TSpin(lines: Int)
    case TSpinMini
}


protocol GameCoordinator {
    func modeSpecificNodes() -> [SKNode]
    func linesDidClear(_ type: LineClear)
}


class DummyCoordinator: GameCoordinator {
    func modeSpecificNodes() -> [SKNode] { return [] }
    func linesDidClear(_ type: LineClear) { }
}

