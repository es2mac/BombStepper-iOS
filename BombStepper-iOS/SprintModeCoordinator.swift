//
//  SprintModeCoordinator.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/29/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


class SprintModeCoordinator: GameCoordinator {

    var gameEndAction: (() -> Void)?
    var gameStartAction: (() -> Void)?
    var exitGameAction: (() -> Void)?
    
    private let sceneSize: CGSize
    private let labelNode: SKLabelNode

    private var remainingLines = 40

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        labelNode = SKLabelNode()
        labelNode.fontColor = .red
        labelNode.fontSize = sceneSize.height / 10
        labelNode.text = "Hello Tetris"
        labelNode.fontName = "Helvetica-Bold"
        labelNode.position.x = (-sceneSize.width / 2) + 20
        labelNode.horizontalAlignmentMode = .left
    }

    func modeSpecificNodes() -> [SKNode] {
        return [labelNode]
    }

    func linesCleared(_ lineClear: LineClear) {
        switch lineClear {
        case .normal(lines: let lines), .TSpin(lines: let lines):
            remainingLines -= lines
        case .TSpinMini:
            remainingLines -= 1
        }

        if remainingLines <= 0 {
            endGame()
        }
    }

    private func endGame() {

        // Tell nodes to update and stuff

        

        gameEndAction?()
    }
    
}










