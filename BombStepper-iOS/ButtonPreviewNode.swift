//
//  ButtonPreviewNode.swift
//  ButtonCreator
//
//  Created by Paul on 5/2/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


class ButtonPreviewNode: SKNode {

    var configuration: ButtonConfiguration

    let swipeAxisNode: SKSpriteNode
    let labelNode: SKLabelNode

    init(configuration: ButtonConfiguration) {
        self.configuration = configuration

        let baseImage = UIImage.roundedRect(size: configuration.size, cornerRadius: configuration.corner, color: UIColor(white: 1, alpha: Alpha.pressedButton))
        let baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.zRotation = configuration.tilt * .pi / 180

        let swipeAxisImage = UIImage.image(from: configuration)
        swipeAxisNode = SKSpriteNode(texture: SKTexture(image: swipeAxisImage))
        swipeAxisNode.zPosition = 1
        swipeAxisNode.zRotation = configuration.swipeAxisTilt * .pi / 180
        swipeAxisNode.alpha = 0

        labelNode = SKLabelNode()
        labelNode.text = configuration.type.displayText
        labelNode.fontSize = 16
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        if labelNode.frame.width > (configuration.width - 4) {
            let factor = labelNode.frame.width / (configuration.width - 4)
            labelNode.fontSize = (16 / factor).rounded(.down)
        }

        super.init()

        addChild(baseNode)
        baseNode.addChild(labelNode)
        self.position = configuration.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var showDetails: Bool = false {
        didSet {
            if showDetails {
                addChild(swipeAxisNode)
                swipeAxisNode.run(.fadeAlpha(to: 0.5, duration: 0.5))
                labelNode.run(.fadeOut(withDuration: 0.5))
            }
            else {
                swipeAxisNode.run(.fadeOut(withDuration: 0.5)) {
                    self.swipeAxisNode.removeFromParent()
                }
                labelNode.run(.fadeIn(withDuration: 0.5))
            }
        }
    }
    
}
