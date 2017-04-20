//
//  GameScene.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private var dasManager: DASManager!
    private var controllerNode: ControllerNode?

    override func didMove(to view: SKView) {
        createControllerNode()
        dasManager = DASManager(das: 8, performDAS: { _ in })
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update()
    }

    // Create or (if size changed) recreate the controller node
    private func createControllerNode() {
        guard controllerNode?.sceneSize != size else { return }
        controllerNode?.removeFromParent()
        controllerNode = ControllerNode(sceneSize: size)
        controllerNode?.alpha = 0
        addChild(controllerNode!)
        controllerNode?.run(.fadeIn(withDuration: 1))
    }
}







