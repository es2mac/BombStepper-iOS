//
//  TetrisSystem.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


protocol BaseGameUIDisplay: class {
    func updateFieldDisplay(blocks: [Block])
    func updatePreviews(_ types: [Tetromino])
    func updateHeldPiece(_ type: Tetromino?)
    func clearFieldDisplay()
}


protocol GameEventDelegate: class {
    func linesCleared(_ lineClear: LineClear)
    func toppedOut()
}


class TetrisSystem {
    
    weak var displayDelegate: BaseGameUIDisplay?
    weak var eventDelegate: GameModeController?
    
    fileprivate(set) var isGameRunning = false

    fileprivate let filedManipulator = FieldManipulator(field: Field())
    fileprivate let tetrominoRandomizer = TetrominoRandomizer()
    fileprivate let movementTimer = MovementTimer()
    
    fileprivate var heldPieceType: Tetromino?
    fileprivate var holdPieceLocked = false
    
    init() {
        filedManipulator.system = self
        movementTimer.moveAction = { [weak self] direction, steps in
            self?.filedManipulator.movePiece(direction, steps: steps)
        }
        movementTimer.lockAction = { [weak self] in
            self?.filedManipulator.hardDrop()
        }
        prepareGame()
    }
}


extension TetrisSystem {

    func prepareGame() {
        guard !isGameRunning else { return }

        displayDelegate?.clearFieldDisplay()
        displayDelegate?.updateHeldPiece(nil)
        filedManipulator.reset()
        tetrominoRandomizer.reset()
        movementTimer.resetAll()
        heldPieceType = nil
        holdPieceLocked = false
        
        displayDelegate?.updatePreviews(tetrominoRandomizer.previews())
    }

    func startGame() {
        guard !isGameRunning else { return }

        isGameRunning = true
        playNextPiece()
    }

    func stopGame() {
        movementTimer.resetAll()
        isGameRunning = false
    }

}


extension TetrisSystem: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {
        movementTimer.update(currentTime)
    }
}


extension TetrisSystem: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        filedManipulator.settingsDidUpdate(settings)
        movementTimer.settingsDidUpdate(settings)
    }
}


extension TetrisSystem: ControllerDelegate {

    func buttonDown(_ button: Button) {
        guard isGameRunning else { return }
        
        switch button {
        case .moveLeft:
            filedManipulator.movePiece(.left)
            movementTimer.startTiming(.das(.left))
        case .moveRight:
            filedManipulator.movePiece(.right)
            movementTimer.startTiming(.das(.right))
        case .hardDrop:
            filedManipulator.hardDrop()
        case .softDrop:
            movementTimer.startTiming(.softDrop)
        case .hold:
            holdPiece()
        case .rotateLeft:
            filedManipulator.rotatePiece(.left)
        case .rotateRight:
            filedManipulator.rotatePiece(.right)
        case .none:
            break
        }

    }

    func buttonUp(_ button: Button) {

        switch button {
        case .moveLeft:
            movementTimer.stopTiming(.das(.left))
        case .moveRight:
            movementTimer.stopTiming(.das(.right))
        case .softDrop:
            movementTimer.stopTiming(.softDrop)
        default:
            break
        }
    }
}

/// Communication with Field
extension TetrisSystem {

    func updatePlayField(blocks: [Block]) {
        displayDelegate?.updateFieldDisplay(blocks: blocks)
    }
    
    func activePieceDidLock(lineClear: LineClear?) {
        movementTimer.stopTiming(.gravity)
        movementTimer.resetDelayedLock()
        holdPieceLocked = false

        if let lines = lineClear {
            eventDelegate?.linesCleared(lines)
        }
        
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        DispatchQueue.main.async {
            self.playNextPiece()
        }
    }

    func fieldDidTopOut() {
        endGame()
        eventDelegate?.toppedOut()
    }

    func activePieceLandingStatusChanged(landed: FieldManipulator.PieceLandingStatus) {
        switch landed {
        case .floating:
            movementTimer.stopTiming(.delayedLock(landed))
        default:
            movementTimer.startTiming(.delayedLock(landed))
        }
    }

}


private extension TetrisSystem {

    func playNextPiece(_ nextPiece: Tetromino? = nil) {
        guard isGameRunning else { return }

        let piece = nextPiece ?? tetrominoRandomizer.popNext()
        if filedManipulator.startPiece(type: piece) {
            movementTimer.startTiming(.gravity)
            displayDelegate?.updatePreviews(tetrominoRandomizer.previews())
        }
    }

    func holdPiece() {
        guard isGameRunning else { return }
        guard !holdPieceLocked else { return }
        guard let piece = filedManipulator.extractActivePiece() else { return }

        playNextPiece(heldPieceType)
        heldPieceType = piece.type
        holdPieceLocked = true
        displayDelegate?.updateHeldPiece(piece.type)
    }

    // WISHLIST: Animate blur and/or dim game field when game ends?
    func endGame() {
        isGameRunning = false
    }
}






















