//
//  TetrisSystem.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


protocol TetrisSystemDelegate: class {
    func updateFieldDisplay(blocks: [Block])
    func clearFieldDisplay()
}


class TetrisSystem {

    weak var delegate: TetrisSystemDelegate?

    fileprivate(set) var isGameRunning = false

    fileprivate let field = Field()
    fileprivate let tetrominoRandomizer = TetrominoRandomizer()
    fileprivate let gravityTimer = GravityTimer()
    fileprivate let dasManager = DASManager()

    init(delegate: TetrisSystemDelegate? = nil) {
        self.delegate = delegate
        defer { setup() }
    }

    private func setup() {
        field.delegate = self
        gravityTimer.dropAction = { [weak self] dropBy in
            self?.field.shiftPiece(.down, steps: dropBy)
        }
        dasManager.performDAS = { [weak self] direction in
            self?.field.process(das: direction)
        }


        // TODO: DAS manager tells the field how much to shift so the field doesn't need to know about das

        // TODO: unified timer for timed movements e.g. das, soft drop, gravity


    }
}


extension TetrisSystem {

    func startGame() {
        guard !isGameRunning else { return }
        delegate?.clearFieldDisplay()
        field.reset()
        tetrominoRandomizer.reset()
        field.startPiece(type: tetrominoRandomizer.popNext())
        gravityTimer.start()
        isGameRunning = true
    }

}


extension TetrisSystem: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {
        dasManager.update(currentTime)
        gravityTimer.update(currentTime)
    }
}


extension TetrisSystem: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        field.settingsDidUpdate(settings)
        dasManager.settingsDidUpdate(settings)
    }
}


extension TetrisSystem: ControllerDelegate {

    func buttonDown(_ button: Button) {


        /* debug */
        if !isGameRunning, case .hold = button {
            startGame()
            return
        }
        /* end debug */

        
        field.process(input: button)

        switch button {
        case .moveLeft:
            dasManager.inputBegan(.left)
        case .moveRight:
            dasManager.inputBegan(.right)
        default:
            return
        }
    }

    func buttonUp(_ button: Button) {

        switch button {
        case .moveLeft:
            dasManager.inputEnded(.left)
        case .moveRight:
            dasManager.inputEnded(.right)
        default:
            return
        }

    }

}

extension TetrisSystem: FieldDelegate {
    
    func updateField(blocks: [Block]) {
        delegate?.updateFieldDisplay(blocks: blocks)
    }
    
    func fieldActivePieceDidLock() {
        // TODO: actual game logic component
        gravityTimer.stop()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            switch self.field.startPiece(type: self.tetrominoRandomizer.popNext()) {
            case .toppedOut:
                self.isGameRunning = false
            case .success:
                self.gravityTimer.start()
            default:
                break
            }
        }
    }
    
    func fieldActivePieceDidTouchBottom(touching: Bool) {
        // TODO: lock timer
    }
}


