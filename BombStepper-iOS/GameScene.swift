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

    fileprivate var field: Field!
    fileprivate var tetrominoRandomizer: TetrominoRandomizer!
    
    fileprivate var dasManager: DASManager!
    fileprivate let settingsManager = SettingsManager()
    

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupPlayfieldNode()

        // TODO: a "tetris system" class that composes of field, hold, preview, randomizer/generator
        // TODO: Preview
        // TODO: Hold
        setupTetrisSystem()
        setupDASManager()
        settingsManager.addNotificationTargets([controllerNode, dasManager, field, playfieldNode])
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update(currentTime)
        controllerNode.update(currentTime)
        field.update(currentTime)
    }

    private func buttonDown(_ button: Button, isDown: Bool) {


        /* debug */
        if case .hold = button, isDown == true {
            field.startPiece(type: tetrominoRandomizer.popNext())
        }
        /* end debug */


        if isDown {
            field.process(input: button)
        }

        let dasManagerCall = isDown ? dasManager.inputBegan : dasManager.inputEnded
        
        switch button {
        case .moveLeft:
            dasManagerCall(.left)
        case .moveRight:
            dasManagerCall(.right)
        default:
            return
        }
    }

    // Create or (if size changed) recreate the controller node
    // Treat controllerNode as regular optional here
    private func setupControllerNode() {
        guard controllerNode?.sceneSize != size else { return }
        controllerNode?.removeFromParent()
        let node = ControllerNode(sceneSize: size, buttonDownAction: { [unowned self] (button, isDown) in
            self.buttonDown(button, isDown: isDown)
        })
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
    private func setupPlayfieldNode() {
        guard playfieldNode?.sceneSize != size else { return }
        playfieldNode?.removeFromParent()
        let node = PlayfieldNode(sceneSize: size)
        node.alpha = 0
        addChild(node)
        node.fadeIn()
        playfieldNode = node
    }

    private func setupTetrisSystem() {
        guard field == nil else { return }
        field = Field(delegate: self)
        tetrominoRandomizer = TetrominoRandomizer()
    }

    private func setupDASManager() {
        dasManager = DASManager(performDAS: { [weak self] direction in
            self?.field.process(das: direction)
        })
    }
}


extension GameScene: FieldDelegate {

    func updateField(blocks: [Block]) {
        self.playfieldNode.place(blocks: blocks)
    }

    func fieldActivePieceDidLock() {
        // TODO: pass to actual game logic component

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.field.startPiece(type: self.tetrominoRandomizer.popNext())
        }
    }
}







