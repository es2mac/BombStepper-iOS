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
            
        dasManager.activateDAS = { [weak self] active, direction in
            if active {
                self?.movementTimer.startTiming(.das(direction))
            }
            else {
                self?.movementTimer.stopTiming(.das(direction))
            }
        }
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
        movementTimer.settingsDidUpdate(settings)
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

        
        switch button {
        case .moveLeft:
            field.movePiece(.left)
            dasManager.inputBegan(.left)
        case .moveRight:
            field.movePiece(.right)
            dasManager.inputBegan(.right)
        case .hardDrop:
            field.hardDrop()
        case .softDrop:
            movementTimer.startTiming(.softDrop)
        case .hold:

            
            break
        case .rotateLeft:
            field.activePiece.map {
                field.replacePieceWithFirstValidPiece(in: $0.kickCandidatesForRotatingLeft())
            }
        case .rotateRight:
            field.activePiece.map {
                field.replacePieceWithFirstValidPiece(in: $0.kickCandidatesForRotatingRight())
            }
        case .none:
            break
        }

    }

    func buttonUp(_ button: Button) {

        switch button {
        case .moveLeft:
            dasManager.inputEnded(.left)
        case .moveRight:
            dasManager.inputEnded(.right)
        case .softDrop:
            movementTimer.stopTiming(.softDrop)
        default:
            break
        }
    }

}

extension TetrisSystem: FieldDelegate {
    
    func updateField(blocks: [Block]) {
        delegate?.updateFieldDisplay(blocks: blocks)
    }
    
    func fieldActivePieceDidLock(lockedOut: Bool) {
        movementTimer.stopTiming(.gravity)

        guard !lockedOut else {
            isGameRunning = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            switch self.field.startPiece(type: self.tetrominoRandomizer.popNext()) {
            case .blockedOut:
                self.isGameRunning = false
            case .success:
                self.movementTimer.startTiming(.gravity)
            default:
                break
            }
        }
    }
    
    func fieldActivePieceDidTouchBottom(touching: Bool) {
        // TODO: lock timing
    }
}


