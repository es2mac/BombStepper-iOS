//
//  GameScene.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit
import GameplayKit


protocol GameSceneUpdatable {
    func update(_ currentTime: TimeInterval)
}


final class GameScene: SKScene {
    
    fileprivate var controllerNode: ControllerNode!
    fileprivate var playfieldNode: PlayfieldNode!
    fileprivate let settingsManager = SettingsManager()
    fileprivate let system = TetrisSystem()

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupPlayfieldNode()
        system.delegate = self
        
        // TODO: Preview
        // TODO: Hold
        settingsManager.addNotificationTargets([controllerNode, playfieldNode, system])
    }
    
    override func update(_ currentTime: TimeInterval) {
        controllerNode.update(currentTime)
        system.update(currentTime)
    }
    
}


private extension GameScene {

    // Create or (if size changed) recreate the controller node
    // Treat controllerNode as regular optional here
    func setupControllerNode() {
        guard controllerNode?.sceneSize != size else { return }
        controllerNode?.removeFromParent()
        let node = ControllerNode(sceneSize: size, delegate: system)
        node.alpha = 0
        node.zPosition = ZPosition.controls
        addChild(node)
        node.run(.fadeIn(withDuration: 1))
        controllerNode = node
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            node.isUserInteractionEnabled = true
        }
    }
    
    // Create or (if size changed) recreate the playfield node
    // Treat playfieldNode as regular optional here
    func setupPlayfieldNode() {
        guard playfieldNode?.sceneSize != size else { return }
        playfieldNode?.removeFromParent()
        let node = PlayfieldNode(sceneSize: size)
        node.alpha = 0
        addChild(node)
        node.fadeIn()
        playfieldNode = node
    }

}


extension GameScene: TetrisSystemDelegate {
    func updateFieldDisplay(blocks: [Block]) {
        self.playfieldNode.place(blocks: blocks)
    }

    func clearFieldDisplay() {
        playfieldNode.clearField()
    }
}









