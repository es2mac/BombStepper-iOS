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
    static let swipeDown  = ButtonState(rawValue: 1 << 1)
    static let swipeUp    = ButtonState(rawValue: 1 << 2)
    static let swipeLeft  = ButtonState(rawValue: 1 << 3)
    static let swipeRight = ButtonState(rawValue: 1 << 4)
}


final class ButtonNode: SKNode {

    let configuration: ButtonConfiguration
    weak var delegate: ControllerDelegate?

    fileprivate let baseNode: SKSpriteNode
    fileprivate let swipeCoordinateNode = SKNode()  // Use this to calculate swipe distance accounting for tilts

    fileprivate var state: ButtonState = []
    fileprivate var startLocation: CGPoint = .zero

    init(configuration: ButtonConfiguration) {
        self.configuration = configuration
        let baseImage = UIImage.roundedRect(size: configuration.size, cornerRadius: configuration.corner, color: .white)
        baseNode = SKSpriteNode(texture: SKTexture(image: baseImage))
        baseNode.alpha = Alpha.releasedButton

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
            addState(.touchDown)
            startLocation = swipeCoordinateNode.convert(location, from: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state.contains(.touchDown), let location = touches.first?.location(in: self) else { return }

        let p = swipeCoordinateNode.convert(location, from: self)
        let x = CGPoint(x: p.x - startLocation.x, y: p.y - startLocation.y)

        print(NSStringFromCGPoint(x))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeState(.touchDown)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeState(.touchDown)
    }

}


private extension ButtonNode {

    func addState(_ added: ButtonState) {
        if added.contains(.touchDown), !state.contains(.touchDown) {
            baseNode.alpha = Alpha.pressedButton
            delegate?.buttonDown(configuration.type)
        }
        state.insert(added)
    }

    func removeState(_ removed: ButtonState) {
        if removed.contains(.touchDown), state.contains(.touchDown) {
            baseNode.alpha = Alpha.releasedButton
            delegate?.buttonUp(configuration.type)
            state = []
        }
    }

}










