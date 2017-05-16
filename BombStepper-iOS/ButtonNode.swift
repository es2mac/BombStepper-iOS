//
//  ButtonNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/27/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonNode: SKNode {

    var type: ButtonType

    fileprivate let baseNode: SKSpriteNode

    init(size: CGSize, type: ButtonType) {
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

    func touchDown(_ touch: UITouch)  {
        baseNode.alpha = Alpha.pressedButton
    }

    func touchUp(_ touch: UITouch) {
        baseNode.alpha = Alpha.releasedButton
    }

    override func contains(_ p: CGPoint) -> Bool {
        return baseNode.contains(p)
    }
}



