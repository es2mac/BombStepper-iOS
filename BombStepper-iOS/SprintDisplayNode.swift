//
//  SprintDisplayNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/30/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


class SprintDisplayNode: SKNode {

    fileprivate let timeElapsedNode = SKLabelNode()
    fileprivate let linesLeftNode = SKLabelNode()

    init(sceneSize: CGSize) {

        super.init()

        timeElapsedNode.position = CGPoint(x: -40 - sceneSize.width / 4, y: 0)
        linesLeftNode.position = CGPoint(x: -40 - sceneSize.width / 4, y: -40)
        timeElapsedNode.alpha = 0.6
        linesLeftNode.alpha = 0.6
        addChild(timeElapsedNode)
        addChild(linesLeftNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension SprintDisplayNode {

    func matchTimeElapsedNodeStyle(with label: UILabel) {
        timeElapsedNode.fontName = label.font.fontName
        timeElapsedNode.fontSize = label.font.pointSize
        timeElapsedNode.fontColor = label.textColor
        timeElapsedNode.text = label.text
    }

    func matchLinesLeftNodeStyle(with label: UILabel) {
        linesLeftNode.fontName = label.font.fontName
        linesLeftNode.fontSize = label.font.pointSize
        linesLeftNode.fontColor = label.textColor
        linesLeftNode.text = label.text
    }

    func startCountDown() {
        DispatchQueue.main.async {
            self.timeElapsedNode.text = "3"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.timeElapsedNode.text = "2"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.timeElapsedNode.text = "1"
        }
    }

    func showLinesRemaining(_ lines: Int) {
        DispatchQueue.main.async {
            self.linesLeftNode.text = String(lines)
        }
    }

    func showTimeElapsed(elapsed: MachAbsTime) {
        let interval: TimeInterval = absToMs(elapsed) / 1000
        let intInterval = Int(interval)
        let decimals = Int(interval * 100) - intInterval * 100
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60
        let text = String(format: "%02d:%02d.%02d", minutes, seconds, decimals)
        timeElapsedNode.text = text
    }

}
