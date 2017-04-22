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
    private var playfieldNode: PlayfieldNode?

    override func didMove(to view: SKView) {
        setupControllerNode()
        setupPlayfieldNode()
        setupDASManager()
    }
    
    override func update(_ currentTime: TimeInterval) {
        dasManager.update()
    }

    var ttype = 1 {
        didSet {
            let tetromino = Tetromino(rawValue: ttype + 1)!
            playfieldNode?.place(blocks: [Block(mino: tetromino, x: mino.0, y: mino.1)])
        }
    }

    var mino = (0, 0) {
        didSet {
            guard (0 ..< 10 ~= mino.0) && (0 ..< 20 ~= mino.1) else {
                mino = oldValue
                return
            }
            let tetromino = Tetromino(rawValue: ttype + 1)!
            playfieldNode?.place(blocks: [
                Block(mino: .blank, x: oldValue.0, y: oldValue.1),
                Block(mino: tetromino, x: mino.0, y: mino.1) ])
        }
    }

    private func buttonDown(_ button: Button, isDown: Bool) {
        
        let dasManagerCall = isDown ? dasManager.inputBegan : dasManager.inputEnded

        
        switch button {
        case .moveLeft:
            dasManagerCall(.left)
            if isDown { mino.0 -= 1 }
        case .moveRight:
            dasManagerCall(.right)
            if isDown { mino.0 += 1 }
        case .hardDrop:
            if isDown { mino.1 += 1 }
        case .softDrop:
            if isDown { mino.1 -= 1 }
        case .rotateLeft:
            if isDown { ttype = (ttype + 6) % 7 }
        case .rotateRight:
            if isDown { ttype = (ttype + 1) % 7 }
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


    private func setupDASManager() {
        dasManager = DASManager(performDAS: { [weak self] direction in
            switch direction {
            case .left:
                self?.mino.0 = 0
            case .right:
                self?.mino.0 = 9
            }
        })
    }
}







