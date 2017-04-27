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
    fileprivate let maskNode: SKSpriteNode

    fileprivate var buttonDownTime = Date()

    fileprivate let warpBackAction: SKAction = {
        let sourcePositions  = [ float2(0, 1), float2(1, 1),
                                 float2(0, 0), float2(1, 0) ]
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: sourcePositions)
        let warpAction = SKAction.warp(to: warpGeometryGridNoWarp, duration: Timing.buttonFlipUpDuration)!
        return warpAction
    }()
    

    init(size: CGSize, name: String) {
        self.size = size
        let baseImage = UIImage.roundedRect(size: size, cornerRadius: 4, color: .white)
        let maskImage = UIImage.roundedRect(size: size, cornerRadius: 4, color: .red)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        maskNode = SKSpriteNode(texture: SKTexture(image: maskImage))
        baseNode.alpha = Alpha.releasedButton
        maskNode.alpha = 0

        super.init()

        self.name = name
        addChild(baseNode)
        addChild(maskNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchDown(_ touch: UITouch)  {
        displayButtonTapDown(touch.location(in: self))
    }

    func touchUp(_ touch: UITouch) {
        resetDisplay()
    }
}


private extension ButtonNode {

    func displayButtonTapDown(_ location: CGPoint) {
        baseNode.alpha = Alpha.pressedButton

        let radius = size.width / 2
        let scaledLocation = float2(x: Float(location.x / radius),
                                    y: Float(location.y * (size.width / size.height) / radius))
        let distance = min(1, length(scaledLocation)) // unit = circle radius, or half button width
        let safeDistance: Float = 0.4
        
        // (safeDistance ~ 1) => (0 ~ 1) "off-center" weight
        let weight = max(distance - safeDistance, 0) / (1 - safeDistance)

        // If the tap is close enough to the center then no jiggly warning is needed
        guard weight > 0.1 else { return }
        
        maskNode.alpha = Alpha.maxButtonWarning * CGFloat(weight)
        
        // Calculate rotation
        // https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
        let maxRotation = Float.pi / 3
        let angle = -weight * maxRotation
        let s = sin(angle)
        let c = cos(angle)

        // Axis unit vector
        let u = normalize(float2(x:  Float(location.y),
                                 y: -Float(location.x)))
        
        let m = float2x3(rows: [float2(c + pow(u.x, 2) * (1 - c), u.x * u.y * (1 - c)),
                                float2(u.y * u.x * (1 - c),       c + pow(u.y, 2) * (1 - c)),
                                float2(-u.y * s,                  u.x * s)])
        
        let sourcePositions  = [ float2(0, 1), float2(1, 1),
                                 float2(0, 0), float2(1, 0) ]
        
        let destinationPositions = sourcePositions.map { source -> float2 in
            let rotated = m * (source - float2(0.5, 0.5))
            return float2(0.5 + rotated.x, 0.5 + rotated.y)
        }

        let warpGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: destinationPositions)
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: sourcePositions)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: Timing.buttonFlipDownDuration)!
        
        [baseNode, maskNode].forEach { node in
            node.warpGeometry = warpGeometryGridNoWarp
            node.removeAllActions()
            node.run(warpAction)
        }
        
        buttonDownTime = Date()
    }

    func resetDisplay() {
        baseNode.alpha = Alpha.releasedButton
        maskNode.alpha = 0
        warpBack()
    }

    func warpBack() {
        let timeTillWrappingEnds = buttonDownTime.addingTimeInterval(Timing.buttonFlipDownDuration + 0.01).timeIntervalSinceNow
        let actions = ((timeTillWrappingEnds > 0) ? [SKAction.wait(forDuration: timeTillWrappingEnds)] : []) + [warpBackAction]
        baseNode.run(SKAction.sequence(actions))
        maskNode.run(SKAction.sequence(actions))
    }
}


