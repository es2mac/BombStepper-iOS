//
//  GameModeController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/29/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


protocol GameModeController: GameEventDelegate {

    // These are added to the scene to show & update
    var modeSpecificDisplayNode: SKNode? { get }
    var updateReceiver: GameSceneUpdatable? { get }

    // Game mode controller call these to tell the game to start/end
    var signalGamePrepare: (() -> Void)? { get set }
    var signalGameStart: (() -> Void)? { get set }
    var signalGameEnd: (() -> Void)? { get set }

}


