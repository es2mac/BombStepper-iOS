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
    private var playfieldNode: PlayfieldNode?

    private var dasManager: DASManager!
    private var field: Field!

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupPlayfield()
        setupDASManager()
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update()
    }

    var tetro = 0

    private func buttonDown(_ button: Button, isDown: Bool) {

        
        if isDown {
            tetro = (tetro + 1) % 7
            let mino = Tetromino(rawValue: tetro)!
            field.startPiece(type: mino)
        }

        
        let dasManagerCall = isDown ? dasManager.inputBegan : dasManager.inputEnded
        
        switch button {
        case .moveLeft:
            dasManagerCall(.left)
        case .moveRight:
            dasManagerCall(.right)
            break
        case .hardDrop:
//            if isDown { mino.0 -= 1 }
            break
        case .softDrop:
            break
        case .rotateLeft:
            break
        case .rotateRight:
            break
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

    private func setupPlayfield() {
        guard playfieldNode?.sceneSize != size else { return }
        playfieldNode?.removeFromParent()
        let node = PlayfieldNode(sceneSize: size)
        node.alpha = 0
        addChild(node)
        node.fadeIn()
        playfieldNode = node

        guard field == nil else { return }
        field = Field(updateBlocks: { [weak self] blocks in
            self?.playfieldNode?.place(blocks: blocks)
        })
    }

    private func setupDASManager() {
        dasManager = DASManager(performDAS: { direction in
            switch direction {
            case .left:
                break
            case .right:
                break
            }
        })
    }
}







