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
    fileprivate var heldPieceNode: SinglePieceNode!
    fileprivate var previewsNode: PreviewsNode!
    fileprivate let settingsManager = SettingsManager()
    fileprivate let system = TetrisSystem()

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupDisplayNodes()
        system.delegate = self
        settingsManager.addNotificationTargets([controllerNode, playfieldNode, system])
    }
    
    override func update(_ currentTime: TimeInterval) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            node.isUserInteractionEnabled = true
        }
    }
    
    // Create or (if size changed) recreate the playfield node
    // Treat playfieldNode as regular optional here
    func setupDisplayNodes() {
        guard playfieldNode?.sceneSize != size else { return }
        playfieldNode?.removeFromParent()

        playfieldNode = PlayfieldNode(sceneSize: size)
        playfieldNode.alpha = 0
        addChild(playfieldNode)
        playfieldNode.fadeIn()

        let tileWidth = playfieldNode.tileWidth

        previewsNode = PreviewsNode(tileWidth: tileWidth)
        previewsNode.position.x = tileWidth * (5 + 2) + CGFloat(Dimension.outerFrameWidth) + 5
        previewsNode.position.y = tileWidth * 2
        addChild(previewsNode)

        heldPieceNode = SinglePieceNode(tileWidth: tileWidth)
        heldPieceNode.position.x = -tileWidth * (5 + 2) - CGFloat(Dimension.outerFrameWidth) + 5
        heldPieceNode.position.y = tileWidth * 8
        addChild(heldPieceNode)
    }

}


extension GameScene: TetrisSystemDelegate {
    func updateFieldDisplay(blocks: [Block]) {
        self.playfieldNode.place(blocks: blocks)
    }

    func clearFieldDisplay() {
        playfieldNode.clearField()
    }

    func updatePreviews(_ types: [Tetromino]) {
        previewsNode.show(types)
    }

    func updateHeldPiece(_ type: Tetromino) {
        heldPieceNode.show(type)
    }

}









