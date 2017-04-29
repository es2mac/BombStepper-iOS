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



