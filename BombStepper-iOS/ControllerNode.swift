//
//  ControllerNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


typealias ButtonMap = [SKShapeNode : Button]


/**
 Buttons layout:
 0 1        6  7
 2 3        8  9
 4 5       10 11
 */
final class ControllerNode: SKNode {

    let sceneSize: CGSize
    private let buttonDown: (Button, _ isDown: Bool) -> Void


    init(sceneSize: CGSize, buttonDown: @escaping (Button, _ isDown: Bool) -> Void) {
        self.sceneSize = sceneSize
        self.buttonDown = buttonDown

        let buttonWidth = Int(sceneSize.height / 8) * 2     // Quarter height, rounded down to even number
        settingManager = SettingManager()
        buttons = (0 ..< 12).map { ControllerNode.regularButton(width: buttonWidth, name:"\($0)") }
        settings = SettingManager.Settings.initial
        buttonMap = ControllerNode.buildButtonMap(withButtons: buttons, settings: settings)

        super.init()

        isUserInteractionEnabled = true
        buttons.forEach(addChild)
        layoutButtons(for: sceneSize)

        settingManager.updateSettingsAction = { [weak self] in self?.settings = $0 }

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

    fileprivate let buttons: [SKShapeNode]
    private var buttonMap: ButtonMap
    private let settingManager: SettingManager
    private var settings: SettingManager.Settings {
        didSet {
            TouchData.swipeDownThreshold = settings.swipeDownThreshold
            buttonMap = ControllerNode.buildButtonMap(withButtons: buttons, settings: settings)
        }
    }


    final private class TouchData {
        static var swipeDownThreshold = 1000.0

        let node: SKShapeNode
        var speeds: [Double] = []
        var lastTime: TimeInterval
        var lastY: CGFloat

        init(node: SKShapeNode, time: TimeInterval, y: CGFloat) {
            self.node = node
            self.lastTime = time
            self.lastY = y
        }

        func recordSpeed(time: TimeInterval, y: CGFloat) {
            let speed = Double(y - lastY) / (time - lastTime)
            lastTime = time
            lastY = y
            if speeds.count >= 4 { speeds.removeFirst() }
            speeds.append(speed)
        }

        func touchIsSwipingDown() -> Bool {
            guard speeds.count >= 4 else { return false }
            return speeds.reduce(0, +) / Double(speeds.count) < -TouchData.swipeDownThreshold
        }
    }


    private var touchesData = [UITouch : TouchData]()

    private func touchDown(_ touch: UITouch) {
        let location = touch.location(in: self)
        if let node = nodes(at: location).first as? SKShapeNode {
            touchesData[touch] = TouchData(node: node, time: touch.timestamp, y: location.y)
            node.alpha = Alpha.pressedButton
            buttonDown(buttonMap[node]!, true)
        }
    }

    private func touchMoved(_ touch: UITouch) {
        if let data = touchesData[touch] {
            data.recordSpeed(time: touch.timestamp, y: touch.location(in: self).y)
            if data.touchIsSwipingDown() {
                touchUp(touch)
                buttonDown(.hardDrop, true)
                buttonDown(.hardDrop, false)
            }
        }
    }

    private func touchUp(_ touch: UITouch) {
        if let node = touchesData.removeValue(forKey: touch)?.node {
            node.alpha = Alpha.releasedButton
            buttonDown(buttonMap[node]!, false)
        }
    }

    private func stopAllTouches() {
        Array(touchesData.keys).forEach(touchUp)
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



fileprivate extension ControllerNode {

    class func regularButton(width: Int, name: String) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: -width/2, y: -width/2, width: width, height: width), cornerRadius: 4)
        node.name = name
        node.fillColor = .white
        node.alpha = Alpha.releasedButton
        node.lineWidth = 0
        return node
    }

    class func buildButtonMap(withButtons buttons: [SKShapeNode], settings: SettingManager.Settings) -> ButtonMap {
        return [ buttons[0] : settings.button00,
                 buttons[1] : settings.button01,
                 buttons[2] : settings.button02,
                 buttons[3] : settings.button03,
                 buttons[4] : settings.button04,
                 buttons[5] : settings.button05,
                 buttons[6] : settings.button06,
                 buttons[7] : settings.button07,
                 buttons[8] : settings.button08,
                 buttons[9] : settings.button09,
                 buttons[10] : settings.button10,
                 buttons[11] : settings.button11 ]
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
        zip(buttons, p).forEach { $0.position = $1 }
        buttons[0 ..< 6].forEach { $0.zRotation = -.pi/8 }
        buttons[6 ..< 12].forEach { $0.zRotation = .pi/8 }
    }
}



private func +(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

private func -(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}


