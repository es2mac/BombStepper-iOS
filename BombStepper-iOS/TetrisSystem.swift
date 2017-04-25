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
    fileprivate let dasManager = DASManager()
    fileprivate let movementTimer = MovementTimer()

    init(delegate: TetrisSystemDelegate? = nil) {
        self.delegate = delegate
        defer { setup() }
    }

    private func setup() {
        field.delegate = self
        movementTimer.moveAction = { [weak self] direction, steps in
            self?.field.movePiece(direction, steps: steps)
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
        movementTimer.startTiming(.gravity)
        isGameRunning = true
    }

}


extension TetrisSystem: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {
        dasManager.update(currentTime)
        movementTimer.update(currentTime)
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


        /* Temporary game starter */
        if !isGameRunning, case .hold = button {
            startGame()
            return
        }
        /* end temp */

        
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
        movementTimer.stopTiming(.gravity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            switch self.field.startPiece(type: self.tetrominoRandomizer.popNext()) {
            case .toppedOut:
                self.isGameRunning = false
            case .success:
                self.movementTimer.startTiming(.gravity)
            default:
                break
            }
        }
    }
    
    func fieldActivePieceDidTouchBottom(touching: Bool) {
        // TODO: lock timer
    }
}


