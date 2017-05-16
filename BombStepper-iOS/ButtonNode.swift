//
//  ButtonNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/27/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonNode: SKNode {

    fileprivate let size: CGSize
    fileprivate let baseNode: SKSpriteNode

    fileprivate var buttonDownTime = Date()

    fileprivate let warpBackAction: SKAction = {
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1)
        let warpAction = SKAction.warp(to: warpGeometryGridNoWarp, duration: Timing.buttonFlipUpDuration)!
        warpAction.timingMode = .easeIn
        return warpAction
    }()
    

    init(size: CGSize, name: String) {
        self.size = size
        let baseImage = UIImage.roundedRect(size: size, cornerRadius: 4, color: .white)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.alpha = Alpha.releasedButton

        // Make touchable area that doesn't warp with the other stuff
        let touchableNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width + 2, height: size.height + 2))

        super.init()

        self.name = name
        [baseNode, touchableNode].forEach(self.addChild)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchDown(_ touch: UITouch, warnIfOffCenter: Bool = true)  {
        displayButtonTapDown(touch.location(in: self))
    }

    func touchUp(_ touch: UITouch) {
        resetDisplay()
    }
}


private extension ButtonNode {

    func displayButtonTapDown(_ location: CGPoint) {
        baseNode.alpha = Alpha.pressedButton
    }

    func resetDisplay() {
        baseNode.alpha = Alpha.releasedButton
    }

}


