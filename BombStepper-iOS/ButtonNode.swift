//
//  ButtonNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/27/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonNode: SKNode {

    var type: Button

    fileprivate let size: CGSize
    fileprivate let baseNode: SKSpriteNode

    fileprivate var buttonDownTime = Date()

    fileprivate let warpBackAction: SKAction = {
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1)
        let warpAction = SKAction.warp(to: warpGeometryGridNoWarp, duration: Timing.buttonFlipUpDuration)!
        warpAction.timingMode = .easeIn
        return warpAction
    }()


    init(size: CGSize, type: Button) {
        self.size = size
        self.type = type
        let baseImage = UIImage.roundedRect(size: size, cornerRadius: 4, color: .white)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.alpha = Alpha.releasedButton


        super.init()

        addChild(baseNode)
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

    override func contains(_ p: CGPoint) -> Bool {
        return baseNode.contains(p)
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


