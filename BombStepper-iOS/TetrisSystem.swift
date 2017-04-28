//
//  TetrisSystem.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


protocol BaseGameUIDisplay: class {
    func updateFieldDisplay(blocks: [Block])
    func updatePreviews(_ types: [Tetromino])
    func updateHeldPiece(_ type: Tetromino?)
    func clearFieldDisplay()
}

protocol GameEventDelegate: class {
    // Game start/end closures are for the delegate to call, to tell the system to start/end
    var gameStartAction: (() -> Void)? { get set }
    var gameEndAction: (() -> Void)? { get set }

    // Methods are feedback to the delegate of what happened
    func linesCleared(_ lineClear: LineClear)
    func toppedOut()
}


class TetrisSystem {
    
    weak var displayDelegate: BaseGameUIDisplay?
    weak var eventDelegate: GameEventDelegate?
    
    fileprivate(set) var isGameRunning = false

    fileprivate let manipulator = FieldManipulator(field: Field())
    fileprivate let tetrominoRandomizer = TetrominoRandomizer()
    fileprivate let dasManager = DASManager()
    fileprivate let movementTimer = MovementTimer()
    
    fileprivate var heldPieceType: Tetromino?
    fileprivate var holdPieceLocked = false
    
    init() {
        manipulator.system = self
        movementTimer.moveAction = { [weak self] direction, steps in
            self?.manipulator.movePiece(direction, steps: steps)
        }
        movementTimer.lockAction = { [weak self] in
            self?.manipulator.hardDrop()
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

        displayDelegate?.clearFieldDisplay()
        displayDelegate?.updateHeldPiece(nil)
        manipulator.reset()
        tetrominoRandomizer.reset()
        dasManager.reset()
        movementTimer.resetAll()
        heldPieceType = nil
        holdPieceLocked = false
        
        isGameRunning = true
        playNextPiece()
    }

    func stopGame() {
        movementTimer.resetAll()
        dasManager.reset()
        isGameRunning = false
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
        manipulator.settingsDidUpdate(settings)
        dasManager.settingsDidUpdate(settings)
        movementTimer.settingsDidUpdate(settings)
    }
}


extension TetrisSystem: ControllerDelegate {

    func buttonDown(_ button: Button) {

        
        /* Temporary game starter */
//        if !isGameRunning, case .hold = button {
//            startGame()
//            return
//        }
        /* end temp */

        
        guard isGameRunning else { return }
        
        switch button {
        case .moveLeft:
            manipulator.movePiece(.left)
            dasManager.inputBegan(.left)
        case .moveRight:
            manipulator.movePiece(.right)
            dasManager.inputBegan(.right)
        case .hardDrop:
            manipulator.hardDrop()
        case .softDrop:
            movementTimer.startTiming(.softDrop)
        case .hold:
            holdPiece()
        case .rotateLeft:
            manipulator.rotatePiece(.left)
        case .rotateRight:
            manipulator.rotatePiece(.right)
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

/// Communication with Field
extension TetrisSystem {


    // TODO: Event reporting, and the system relay them to eventDelegate
    // Think about what the outside user of TetrisSystem needs to be able to tell it to do
    // e.g., start game, play next piece (future: bomb rise?)
    
    
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
        if manipulator.startPiece(type: piece) {
            movementTimer.startTiming(.gravity)
            displayDelegate?.updatePreviews(tetrominoRandomizer.previews())
        }
    }

    func holdPiece() {
        guard isGameRunning else { return }
        guard !holdPieceLocked else { return }
        guard let piece = manipulator.extractActivePiece() else { return }

        playNextPiece(heldPieceType)
        heldPieceType = piece.type
        holdPieceLocked = true
        displayDelegate?.updateHeldPiece(piece.type)
    }

    func endGame() {
        isGameRunning = false
        // TODO: find out how this crashes, thread locked?
//        manipulator.extractActivePiece()
    }
}






















