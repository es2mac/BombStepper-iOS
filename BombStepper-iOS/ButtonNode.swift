//
//  ButtonNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/27/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


// TODO: Draw triangular sub-buttons
// TODO: Swipe detection + display
// TODO: Swipe logic: left/right functions depend on button type, drop/hold fires on release

private struct ButtonState: OptionSet {
    let rawValue: Int
    static let touchDown  = ButtonState(rawValue: 1 << 0)
    static let swipeLeft  = ButtonState(rawValue: 1 << 1)
    static let swipeRight = ButtonState(rawValue: 1 << 2)
    static let swipeUp    = ButtonState(rawValue: 1 << 3)
    static let swipeDown  = ButtonState(rawValue: 1 << 4)
}


final class ButtonNode: SKNode {

    let configuration: ButtonConfiguration
    weak var delegate: ControllerDelegate?

    fileprivate let baseNode: SKSpriteNode
    fileprivate let swipeCoordinateNode = SKNode()  // Use this to calculate swipe distance accounting for tilts

    fileprivate var state: ButtonState = []         // use setState(_:) as setter
    fileprivate var startLocation: CGPoint = .zero
    fileprivate let swipeLeftType: ButtonType
    fileprivate let swipeRightType: ButtonType

    init(configuration: ButtonConfiguration) {
        self.configuration = configuration
        let baseImage = UIImage.roundedRect(size: configuration.size, cornerRadius: configuration.corner, color: .white)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.alpha = Alpha.releasedButton

        switch configuration.type {
        case .moveLeft, .moveRight, .softDrop, .none:
            swipeLeftType = .moveLeft
            swipeRightType = .moveRight
        case .rotateLeft, .rotateRight:
            swipeLeftType = .rotateLeft
            swipeRightType = .rotateRight
        case .hardDrop, .hold:
            swipeLeftType = .none
            swipeRightType = .none
        }

        super.init()

        addChild(baseNode)
        addChild(swipeCoordinateNode)

        // By rotating the whole node instead of just the base node, the base node would have a non-mutated frame
        zRotation = configuration.tilt * .pi / 180
        swipeCoordinateNode.zRotation = (configuration.swipeAxisTilt - configuration.tilt) * .pi / 180
        position = configuration.position
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self), baseNode.contains(location) {
            setState(.touchDown)
            startLocation = swipeCoordinateNode.convert(location, from: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state.contains(.touchDown), let location = touches.first?.location(in: self) else { return }

        let adjustedLocation = swipeCoordinateNode.convert(location, from: self)
        let delta = (x: adjustedLocation.x - startLocation.x, y: adjustedLocation.y - startLocation.y)

        let threshold = configuration.swipeDistance

        var newState: ButtonState = .touchDown

        if delta.y > threshold {
            newState.insert(.swipeUp)
        }
        else {
            if delta.y < -threshold {
                newState.insert(.swipeDown)
            }
            if delta.x < -threshold {
                newState.insert(.swipeLeft)
            }
            else if delta.x > threshold {
                newState.insert(.swipeRight)
            }
        }

        setState(newState)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setState([])
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setState([])
    }

}


private extension ButtonNode {

    func setState( _ newState: ButtonState) {
        guard newState != state else { return }
        defer {
            state = newState
            updateAppearance(for: newState)
        }

        switch (newState.contains(.touchDown), state.contains(.touchDown)) {

        // Fire main button function
        case (true, false):
            delegate?.buttonDown(configuration.type)

        // Stop main button function
        case (false, true):
            delegate?.buttonUp(configuration.type)

            // Fire swipe drop/hold on release
            if state.contains(.swipeDown) {
                delegate?.buttonDown(.hardDrop)
            }
            else if state.contains(.swipeUp) {
                delegate?.buttonDown(.hold)
            }
        default: break
        }

        // Left & right swipes
        guard configuration.leftRightSwipeEnabled else { return }

        switch (newState.contains(.swipeLeft), state.contains(.swipeLeft), newState.contains(.swipeRight), state.contains(.swipeRight)) {
        case (true, false, _, _), (_, _, false, true):
            delegate?.buttonDown(swipeLeftType)
            delegate?.buttonUp(swipeLeftType)
        case (false, true, _, _), (_, _, true, false):
            delegate?.buttonDown(swipeRightType)
            delegate?.buttonUp(swipeRightType)
        default: break
        }
        
    }

    private func updateAppearance(for state: ButtonState) {
        
        baseNode.alpha = Alpha.releasedButton
        
        switch (state.contains(.touchDown),
                state.contains(.swipeLeft), state.contains(.swipeRight),
                state.contains(.swipeUp), state.contains(.swipeDown)) {
            
        case (true, false, false, false, false):
            baseNode.alpha = Alpha.pressedButton
        default:
            break
        }
    }

}










