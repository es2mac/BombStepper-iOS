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

    fileprivate let settingsManager: SettingsManager
    fileprivate let system: TetrisSystem

    fileprivate let controllerNode: ControllerNode
    fileprivate let playfieldNode: PlayfieldNode
    fileprivate let heldPieceNode: HeldPieceNode
    fileprivate let previewsNode: PreviewsNode

    init(size: CGSize, eventDelegate: GameEventDelegate) {
        settingsManager = SettingsManager()
        system = TetrisSystem()

        (controllerNode, playfieldNode, heldPieceNode, previewsNode) = GameScene.standardNodes(sceneSize: size)

        super.init(size: size)

        system.displayDelegate = self
        system.eventDelegate = eventDelegate

        eventDelegate.gameStartAction = { [weak system] in system?.startGame() }
        eventDelegate.gameEndAction = { [weak system] in system?.stopGame() }

        controllerNode.delegate = system
        
        settingsManager.addNotificationTargets([controllerNode, playfieldNode, system])
        
        [controllerNode, playfieldNode, heldPieceNode, previewsNode].forEach(addChild)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(_ currentTime: TimeInterval) {
        system.update(currentTime)
    }

}


private extension GameScene {

    class func standardNodes(sceneSize size: CGSize) -> (controller: ControllerNode, playField: PlayfieldNode, heldPiece: HeldPieceNode, previews: PreviewsNode) {
        let controllerNode = ControllerNode(sceneSize: size)
        controllerNode.alpha = 0
        controllerNode.zPosition = ZPosition.controls
        controllerNode.run(.fadeIn(withDuration: 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            controllerNode.isUserInteractionEnabled = true
        }

        let playfieldNode = PlayfieldNode(sceneSize: size)
        playfieldNode.alpha = 0
        playfieldNode.fadeIn()

        let tileWidth = playfieldNode.tileWidth

        let previewsNode = PreviewsNode(tileWidth: tileWidth)
        previewsNode.position.x = tileWidth * (5 + 2) + CGFloat(Dimension.outerFrameWidth) + 5
        previewsNode.position.y = tileWidth * 2

        let heldPieceNode = HeldPieceNode(tileWidth: tileWidth)
        heldPieceNode.position.x = -(tileWidth * (5 + 2) + CGFloat(Dimension.outerFrameWidth) + 5)
        heldPieceNode.position.y = tileWidth * 8

        return (controller: controllerNode, playField: playfieldNode, heldPiece: heldPieceNode, previews: previewsNode)

    }

}


extension GameScene: BaseGameUIDisplay {
    func updateFieldDisplay(blocks: [Block]) {
        self.playfieldNode.place(blocks: blocks)
    }

    func clearFieldDisplay() {
        playfieldNode.clearField()
    }

    func updatePreviews(_ types: [Tetromino]) {
        previewsNode.show(types)
    }

    func updateHeldPiece(_ type: Tetromino?) {
        heldPieceNode.show(type)
    }

}









