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
    func updatePreviews(_ types: [Tetromino])
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
        movementTimer.lockAction = { [weak self] in
            self?.field.hardDrop()
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
//        tetrominoRandomizer.popNext()
//        delegate?.updatePreviews(tetrominoRandomizer.previews())
        guard !isGameRunning else { return }
        delegate?.clearFieldDisplay()
        field.reset()
        tetrominoRandomizer.reset()
        field.startPiece(type: tetrominoRandomizer.popNext())
        delegate?.updatePreviews(tetrominoRandomizer.previews())
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
    
    func activePieceDidLock(lockedOut: Bool) {
        movementTimer.stopTiming(.gravity)
        movementTimer.resetDelayedLock()

        guard !lockedOut else {
            isGameRunning = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playNextPiece()
        }
    }

    func activePieceBottomTouchingStatusChanged(touching: Field.BottomTouchingStatus) {
        switch touching {
        case .floating:
            movementTimer.stopTiming(.delayedLock(touching))
        default:
            movementTimer.startTiming(.delayedLock(touching))
        }
    }
}


private extension TetrisSystem {

    func playNextPiece() {
        switch field.startPiece(type: tetrominoRandomizer.popNext()) {
        case .blockedOut:
            isGameRunning = false
        case .success:
            movementTimer.startTiming(.gravity)
            delegate?.updatePreviews(tetrominoRandomizer.previews())
        default:
            break
        }
    }
}


