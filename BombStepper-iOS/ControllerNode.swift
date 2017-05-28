//
//  ControllerNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


// TODO: Individual buttons fire through delegate themselves

protocol ControllerDelegate: class {
    func buttonDown(_ button: ButtonType)
    func buttonUp(_ button: ButtonType)
}


final class ControllerNode: SKNode {

    let sceneSize: CGSize
    weak var delegate: ControllerDelegate? {
        didSet { buttonNodes.forEach { $0.delegate = delegate } }
    }
    

    fileprivate let buttonNodes: [ButtonNode]

    // Stores touches that correspond to buttons to calculate swipe speed
//    fileprivate var touchesData = [UITouch : TouchData]()


    init(sceneSize: CGSize, delegate: ControllerDelegate? = nil) {
        self.sceneSize = sceneSize
        self.delegate = delegate

        // TODO: create buttons using config
        let layoutProfile = ButtonProfilesManager().loadSelectedProfile()
        buttonNodes = layoutProfile.buttons.map(ButtonNode.init)

        super.init()

        buttonNodes.forEach {
            addChild($0)
            $0.delegate = delegate
        }
        layoutButtons(for: sceneSize)

        // Make touchable area span the scene
//        let touchableNode = SKSpriteNode(color: .clear, size: sceneSize)
//        addChild(touchableNode)

        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
            self?.stopAllTouches()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touchDown($0) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(touchMoved)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(touchUp)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(touchUp)
    }
     */

}


private extension ControllerNode {

    /*
    // TODO: Move swipe functionality to nodes
    final class TouchData {
        static var swipeDownThreshold = 1000.0

        let node: ButtonNode
        var lastTime: TimeInterval
        var lastLocation: CGPoint
        let isOnLeftHalf: Bool

        var speeds: [Double] = []

        init(node: ButtonNode, buttonIndex: Int, time: TimeInterval, location: CGPoint) {
            self.node = node
            self.lastTime = time
            self.lastLocation = location
            self.isOnLeftHalf = location.x < 0
        }

        func recordSpeed(time: TimeInterval, location: CGPoint) {
//            guard swipeDropEnabled else { return }

            // Calculate speed by taking account to slanted directions
            // (Buttons are slanted pi/8, detection slant goes half way at pi/16)
            // to avoid conflict with LR swipe (side-swipe should not trigger a drop)

            let c = cos(Double.pi / 16)
            let s = sin(Double.pi / 16)
            let rotation = isOnLeftHalf ? (c, -s, s, c) : (c, s, -s, c) 
            let delta = (Double(location.x - lastLocation.x),
                         Double(location.y - lastLocation.y))
            let rotatedY = delta.0 * rotation.2 + delta.1 * rotation.3

            let speed = rotatedY / (time - lastTime)
            lastTime = time
            lastLocation = location
            if speeds.count >= 3 { speeds.removeFirst() }
            speeds.append(speed)
        }

        func touchIsSwipingDown() -> Bool {
            guard speeds.count >= 3 else { return false }
            return speeds.reduce(0, +) / Double(speeds.count) < -TouchData.swipeDownThreshold
        }
    }

    func touchDown(_ touch: UITouch, isLRSwipe: Bool = false) {
        let location = touch.location(in: self)

        if let node = buttonNodes.first(where: { node in
            node.contains(node.convert(location, from: self))
        }) {
            touchesData[touch] = TouchData(node: node, buttonIndex: buttonNodes.index(of: node)!, time: touch.timestamp, location: location)
            node.touchDown(touch)
            delegate?.buttonDown(node.configuration.type)
        }
    }

    func touchMoved(_ touch: UITouch) {
        guard let data = touchesData[touch] else { return }

        // Swipe down test
        data.recordSpeed(time: touch.timestamp, location: touch.location(in: self))
        if data.touchIsSwipingDown() {
            touchUp(touch)
            delegate?.buttonDown(.hardDrop)
        }
        
        // LR swipe test
//        guard lrSwipeEnabled else { return }
        
        let button = data.node.configuration.type
        let oppositeButton: ButtonType
        switch button {
        case .moveLeft: oppositeButton = .moveRight
        case .moveRight: oppositeButton = .moveLeft
        default: return
        }

        let location = touch.location(in: self)
        if let node = nodes(at: location).first(where: { $0 is ButtonNode }) as? ButtonNode,
            node != data.node,
            node.configuration.type == oppositeButton {
            touchUp(touch)
            touchDown(touch, isLRSwipe: true)
        }

    }

    func touchUp(_ touch: UITouch) {
        if let node = touchesData.removeValue(forKey: touch)?.node {
            node.touchUp(touch)
            delegate?.buttonUp(node.configuration.type)
        }
    }
    */

    func stopAllTouches() {
//        Array(touchesData.keys).forEach(touchUp)
    }
}



fileprivate extension ControllerNode {

    func layoutButtons(for sceneSize: CGSize) {

    }
}



