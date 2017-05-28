//
//  ButtonNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/27/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonNode: SKNode {

    let configuration: ButtonConfiguration
    weak var delegate: ControllerDelegate?

    private let baseNode: SKSpriteNode
    
    private var isDown: Bool = false {
        didSet {
            if isDown != oldValue {
                if isDown {
                    baseNode.alpha = Alpha.pressedButton
                    delegate?.buttonDown(configuration.type)
                }
                else {
                    baseNode.alpha = Alpha.releasedButton
                    delegate?.buttonUp(configuration.type)
                }
            }
        }
    }

    init(configuration: ButtonConfiguration) {
        self.configuration = configuration
        let baseImage = UIImage.roundedRect(size: configuration.size, cornerRadius: configuration.corner, color: .white)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.alpha = Alpha.releasedButton

        super.init()

        addChild(baseNode)

        position = configuration.position
        zRotation = configuration.tilt * .pi / 180
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.contains(where: { baseNode.contains($0.location(in: self)) }) {
            isDown = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDown = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDown = false
    }

}

private extension ButtonNode { }



