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
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1)
        let warpAction = SKAction.warp(to: warpGeometryGridNoWarp, duration: Timing.buttonFlipUpDuration)!
        warpAction.timingMode = .easeIn
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

        // Make touchable area that doesn't warp with the other stuff
        let touchableNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width + 2, height: size.height + 2))

        super.init()

        self.name = name
        [baseNode, maskNode, touchableNode].forEach(addChild)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchDown(_ touch: UITouch, warnIfOffCenter: Bool = true)  {
        displayButtonTapDown(touch.location(in: self), warnIfOffCenter: warnIfOffCenter)
    }

    func touchUp(_ touch: UITouch) {
        resetDisplay()
    }
}


private extension ButtonNode {

    func displayButtonTapDown(_ location: CGPoint, warnIfOffCenter: Bool = true) {
        baseNode.alpha = Alpha.pressedButton

        let radius = size.width / 2
        let scaledLocation = float2(x: Float(location.x / radius),
                                    y: Float(location.y * (size.width / size.height) / radius))
        let distance = min(1, length(scaledLocation)) // unit = circle radius, or half button width
        let safeDistance: Float = 0.4
        
        // (safeDistance ~ 1) => (0 ~ 1) "off-center" weight
        let weight = max(distance - safeDistance, 0) / (1 - safeDistance)

        // If the tap is close enough to the center then no jiggly warning is needed
        guard warnIfOffCenter, weight > 0.1 else { return }
        
        maskNode.alpha = Alpha.maxButtonWarning * CGFloat(weight)

        
        // Calculate rotation
        // https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
        // https://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/building-basic-perspective-projection-matrix
        // http://metalbyexample.com/linear-algebra/

        let maxRotation = Float.pi / 4
        let angle = -weight * maxRotation
        let s = sin(angle)
        let c = cos(angle)

        // Axis unit vector
        let u = normalize(float4(x: -Float(location.y),
                                 y:  Float(location.x),
                                 z: 0, w: 1))

        // Rotation in 3D space
        // https://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
        let rotation = float4x4(rows: [float4(    c + pow(u.x, 2) * (1 - c),    u.x * u.y * (1 - c) - u.z * s,    u.x * u.z * (1 - c) + u.y * s, 0),
                                       float4(u.y * u.x * (1 - c) + u.z * s,        c + pow(u.y, 2) * (1 - c),    u.y * u.z * (1 - c) - u.x * s, 0),
                                       float4(u.z * u.x * (1 - c) - u.y * s,    u.z * u.y * (1 - c) + u.x * s,        c + pow(u.z, 2) * (1 - c), 0),
                                       float4(0, 0, 0, 1)])

        // Projection matrix

        let n: Float = 1
        let f: Float = 3
        let projection = float4x4(rows: [float4(1, 0,            0,                0),
                                         float4(0, 1,            0,                0),
                                         float4(0, 0, -f / (f - n), -f * n / (f - n)),
                                         float4(0, 0,           -1,                0)])

        let sourcePoints = [ float4(-1, -1, 0, 1), float4(1, -1, 0, 1), float4(-1, 1, 0, 1), float4(1, 1, 0, 1) ]
        let destinationPoints = sourcePoints.map { source -> float4 in
            let rotated = rotation * source
            let repositioned = rotated * float4(2, 2, 1, 1) + float4(0, 0, 2, 0)
            let projected = projection * repositioned
            return projected
        }

        let sourcePositions = [ float2(0, 0), float2(0, 1), float2(1, 0), float2(1, 1) ]
        let destinationPositions = destinationPoints.map { p -> float2 in
            let x = -p.x / p.w
            let y = -p.y / p.w
            return float2((x + 1) / 2, (y + 1) / 2)
        }

        let warpGeometryGrid = SKWarpGeometryGrid(columns: 1, rows: 1, sourcePositions: sourcePositions, destinationPositions: destinationPositions)
        let warpGeometryGridNoWarp = SKWarpGeometryGrid(columns: 1, rows: 1)
        let warpAction = SKAction.warp(to: warpGeometryGrid, duration: Timing.buttonFlipDownDuration)!
        warpAction.timingMode = .easeOut

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


