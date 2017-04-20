//
//  ControllerNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


private let pressedAlpha: CGFloat = 0.15
private let releasedAlpha: CGFloat = 0.04


/**
 Buttons layout:
 0 1        6  7
 2 3        8  9
 4 5       10 11
 */
class ControllerNode: SKNode {

    let buttons: [SKShapeNode]
    let sceneSize: CGSize

    convenience override init() {
        self.init(sceneSize: .zero)
    }

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        let buttonWidth = Int(sceneSize.height / 8) * 2     // Quarter height, rounded down to even number
        buttons = (0 ..< 12).map { ControllerNode.regularButton(width: buttonWidth, name:"\($0)") }

        super.init()

        isUserInteractionEnabled = true
        buttons.forEach(addChild)
        layoutButtons(for: sceneSize)
    }

    private func layoutButtons(for sceneSize: CGSize) {
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
        p[3] = p[5] - shift + v + v
        p[2] = p[3] - u - u
        p[1] = p[3] - shift + v + v
        p[0] = p[1] - u - u
        for (i, j) in zip([0, 1, 2, 3, 4, 5], [7, 6, 9, 8, 11, 10]) {
            p[j] = CGPoint(x: -p[i].x, y: p[i].y)
        }
        zip(buttons, p).forEach { $0.position = $1 }
        buttons[0 ..< 6].forEach { $0.zRotation = -.pi/8 }
        buttons[6 ..< 12].forEach { $0.zRotation = .pi/8 }


//        node.zRotation = -.pi/8


        // ...
    }

    var touchedNodes = [UITouch : SKShapeNode]()

    func addTouchedNodes(for touch: UITouch) {
        if let node = nodes(at:(touch.location(in: self))).first as? SKShapeNode {
            touchedNodes[touch] = node
            node.alpha = pressedAlpha
        }
        print("add:", touchedNodes.count)
    }

    func removeTouchedNodes(for touch: UITouch) {
        if let node = touchedNodes.removeValue(forKey: touch) {
            node.alpha = releasedAlpha
        }
        print("remove:", touchedNodes.count)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(addTouchedNodes)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(removeTouchedNodes)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach(removeTouchedNodes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private class func regularButton(width: Int, name: String) -> SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: -width/2, y: -width/2, width: width, height: width), cornerRadius: 4)
        node.name = name
        node.fillColor = .white
        node.alpha = releasedAlpha
        node.lineWidth = 0
        return node
    }

}



private func +(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

private func -(lhs: CGPoint, rhs: CGVector) -> CGPoint  {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}


