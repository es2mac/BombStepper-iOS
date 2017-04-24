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

    private var controllerNode: ControllerNode?

    fileprivate var playfieldNode: PlayfieldNode?

    fileprivate var field: Field!
    fileprivate var tetrominoRandomizer: TetrominoRandomizer!
    
    private var dasManager: DASManager!

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupPlayfieldNode()

        // TODO: a "tetris system" class that composes of field, hold, preview, randomizer/generator
        setupTetrisSystem()
        setupDASManager()
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update()
        controllerNode?.update()
        field.update(currentTime)
    }

    private func buttonDown(_ button: Button, isDown: Bool) {


        // debug
        if case .hold = button, isDown == true {
            field.startPiece(type: tetrominoRandomizer.popNext())
        }


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
    }

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
        self.playfieldNode?.place(blocks: blocks)
    }

    func fieldActivePieceDidLock() {
        // TODO: pass to actual game logic component

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.field.startPiece(type: self.tetrominoRandomizer.popNext())
        }
    }
}







