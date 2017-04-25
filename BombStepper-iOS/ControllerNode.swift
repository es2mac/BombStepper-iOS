//
//  ControllerNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


protocol ControllerDelegate: class {
    func buttonDown(_ button: Button)
    func buttonUp(_ button: Button)
}


typealias ButtonMap = [SKShapeNode : Button]


/**
 Buttons layout:
 0 1        6  7
 2 3        8  9
 4 5       10 11
 */
final class ControllerNode: SKNode {

    let sceneSize: CGSize
    weak var delegate: ControllerDelegate?
    

    fileprivate let buttonNodes: [SKShapeNode]
    fileprivate var buttonMap: ButtonMap

    fileprivate var lrSwipeEnabled: Bool = true

    // Stores touches that correspond to buttons to calculate swipe speed
    fileprivate var touchesData = [UITouch : TouchData]()


    init(sceneSize: CGSize, delegate: ControllerDelegate?) {
        self.sceneSize = sceneSize
        self.delegate = delegate

        let buttonWidth = Int(sceneSize.height / 8) * 2     // Quarter height, rounded down to even number
        buttonNodes = (0 ..< 12).map { ControllerNode.regularButton(width: buttonWidth, name:"\($0)") }
        buttonMap = ControllerNode.buildButtonMap(withButtons: buttonNodes, buttons: SettingsManager.defaultButtons)

        super.init()

        buttonNodes.forEach(addChild)
        layoutButtons(for: sceneSize)

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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(touchDown)
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

}


extension ControllerNode: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        TouchData.swipeDropEnabled = settings.swipeDropEnabled
        TouchData.swipeDownThreshold = settings.swipeDownThreshold
        lrSwipeEnabled = settings.lrSwipeEnabled
        buttonMap = ControllerNode.buildButtonMap(withButtons: buttonNodes, buttons: settings.buttonsArray)
    }
}


private extension ControllerNode {

    final class TouchData {
        static var swipeDropEnabled = true
        static var swipeDownThreshold = 1000.0

        let node: SKShapeNode
        let button: Button
        var lastTime: TimeInterval
        var lastLocation: CGPoint
        let isLeft: Bool

        var speeds: [Double] = []

        init(node: SKShapeNode, button: Button, time: TimeInterval, location: CGPoint) {
            self.node = node
            self.button = button
            self.lastTime = time
            self.lastLocation = location
            self.isLeft = location.x < 0
        }

        func recordSpeed(time: TimeInterval, location: CGPoint) {
            guard TouchData.swipeDropEnabled else { return }

            // Calculate speed by taking account to slanted directions
            // to avoid conflict with LR swipe (side-swipe should not trigger a drop)

            let c = cos(Double.pi / 8)
            let s = sin(Double.pi / 8)
            let rotation = isLeft ? (c, -s, s, c) : (c, s, -s, c) 
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

    func touchDown(_ touch: UITouch) {
        let location = touch.location(in: self)
        if let node = nodes(at: location).first as? SKShapeNode,
            let button = buttonMap[node] {
            touchesData[touch] = TouchData(node: node, button: button, time: touch.timestamp, location: location)
            node.alpha = Alpha.pressedButton
            delegate?.buttonDown(button)
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
        guard lrSwipeEnabled else { return }
        
        let button = data.button
        let oppositeButton: Button
        switch button {
        case .moveLeft: oppositeButton = .moveRight
        case .moveRight: oppositeButton = .moveLeft
        default: return
        }

        let location = touch.location(in: self)
        if let node = nodes(at: location).first as? SKShapeNode,
            node != data.node,
            buttonMap[node]! == oppositeButton {
            touchUp(touch)
            touchDown(touch)
        }

    }

    func touchUp(_ touch: UITouch) {
        if let node = touchesData.removeValue(forKey: touch)?.node {
            node.alpha = Alpha.releasedButton
            delegate?.buttonUp(buttonMap[node]!)
        }
    }

    func stopAllTouches() {
        Array(touchesData.keys).forEach(touchUp)
    }
}



fileprivate extension ControllerNode {

    class func regularButton(width: Int, name: String) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: -width/2, y: -width/2, width: width, height: width), cornerRadius: 4)
        node.name = name
        node.fillColor = .white
        node.alpha = Alpha.releasedButton
        node.lineWidth = 0
        return node
    }

    class func buildButtonMap(withButtons buttonNodes: [SKShapeNode], buttons: [Button]) -> ButtonMap {
        var map = ButtonMap()
        zip(buttonNodes, buttons).forEach { map[$0] = $1 }
        return map
    }

    func layoutButtons(for sceneSize: CGSize) {
        let margin = CGFloat(2)
        let unit = CGFloat(Int(sceneSize.height / 8)) + margin   // let button be 2 x 2, and add margin

        // x = (1, 0), y = (0, 1)
        // (x, y) => (u, v) rotation by -pi/8
        let u = CGVector(dx: unit * cos(-CGFloat.pi/8), dy: unit * sin(-CGFloat.pi/8))
        let v = CGVector(dx: -u.dy, dy: u.dx)
        let shift = CGVector(dx: u.dx * 2 / 3, dy: u.dy * 2 / 3)

        let origin = CGPoint(x: -sceneSize.width / 2 + unit * 3, y: -sceneSize.height / 2 + unit * 1)
        var p = [CGPoint](repeating: .zero, count: 12)
        p[5] = origin
        p[4] = p[5] - u - u
        p[3] = p[5] + v + v - shift
        p[2] = p[3] - u - u
        p[1] = p[3] + v + v - shift
        p[0] = p[1] - u - u
        for (i, j) in zip([0, 1, 2, 3, 4, 5], [7, 6, 9, 8, 11, 10]) {
            p[j] = CGPoint(x: -p[i].x, y: p[i].y)
        }
        zip(buttonNodes, p).forEach { $0.position = $1 }
        buttonNodes[0 ..< 6].forEach { $0.zRotation = -.pi/8 }
        buttonNodes[6 ..< 12].forEach { $0.zRotation = .pi/8 }
    }
}


private func +(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

private func -(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}


