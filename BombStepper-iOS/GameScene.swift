//
//  GameScene.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {

    private var dasManager: DASManager!
    private var controllerNode: ControllerNode?

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupDASManager()
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update()
    }

    private func buttonDown(_ button: Button, isDown: Bool) {
        
        print(button, isDown ? "down" : "up")

        let dasManagerCall = isDown ? dasManager.inputBegan : dasManager.inputEnded
        
        switch button {
        case .moveLeft: dasManagerCall(.left)
        case .moveRight: dasManagerCall(.right)
        default: return
        }
    }

    // Create or (if size changed) recreate the controller node
    private func setupControllerNode() {
        guard controllerNode?.sceneSize != size else { return }
        controllerNode?.removeFromParent()
        let node = ControllerNode(sceneSize: size, buttonDown: { [unowned self] (button, isDown) in
            self.buttonDown(button, isDown: isDown)
        })
        node.alpha = 0
        node.zPosition = ZPosition.controls
        addChild(node)
        node.run(.fadeIn(withDuration: 1))
        controllerNode = node
    }

    private func setupDASManager() {
        dasManager = DASManager(das: 8, performDAS: { direction in
            print("DAS", direction)
        })
    }
}







