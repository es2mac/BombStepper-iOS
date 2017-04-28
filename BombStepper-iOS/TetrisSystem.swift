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
    func linesCleared(_ lineClear: LineClear)
    func gameDidEnd()
}


class TetrisSystem {
    
    weak var displayDelegate: BaseGameUIDisplay?
    weak var eventDelegate: GameEventDelegate?
    
    fileprivate(set) var isGameRunning = false
    
    fileprivate let field = Field()
    fileprivate let tetrominoRandomizer = TetrominoRandomizer()
    fileprivate let dasManager = DASManager()
    fileprivate let movementTimer = MovementTimer()
    
    fileprivate var heldPieceType: Tetromino?
    fileprivate var holdPieceLocked = false
    
    init() {
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
        guard !isGameRunning else { return }
        displayDelegate?.clearFieldDisplay()
        displayDelegate?.updateHeldPiece(nil)
        field.reset()
        tetrominoRandomizer.reset()
        holdPieceLocked = false
        heldPieceType = nil
        playNextPiece()
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
            holdPiece()
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


    // TODO: Expand FieldDelegate to include event reporting, and the system relay them to eventDelegate
    // Think about what the outside user of TetrisSystem needs to be able to tell it to do
    // e.g., start game, play next piece (future: bomb rise?)
    
    
    func updateField(blocks: [Block]) {
        displayDelegate?.updateFieldDisplay(blocks: blocks)
    }
    
    func activePieceDidLock() {
        movementTimer.stopTiming(.gravity)
        movementTimer.resetDelayedLock()
        holdPieceLocked = false
        
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        DispatchQueue.main.async {
            self.playNextPiece()
        }
    }

    func fieldDidTopOut() {
        // TODO
        
        endGame()
    }

    func activePieceBottomTouchingStatusChanged(touching: Field.BottomTouchingStatus) {
        switch touching {
        case .floating:
            movementTimer.stopTiming(.delayedLock(touching))
        default:
            movementTimer.startTiming(.delayedLock(touching))
        }
    }

    func linesCleared(_ count: Int) {
        // TODO: also keep track of rotation for spin-detection
        eventDelegate?.linesCleared(.normal(lines: count))
    }
}


private extension TetrisSystem {

    func playNextPiece(_ nextPiece: Tetromino? = nil) {
        let piece = nextPiece ?? tetrominoRandomizer.popNext()
        if field.startPiece(type: piece) {
            movementTimer.startTiming(.gravity)
            displayDelegate?.updatePreviews(tetrominoRandomizer.previews())
        }
    }

    func holdPiece() {
        guard !holdPieceLocked, let piece = field.activePiece else { return }

        field.clearActivePiece()
        playNextPiece(heldPieceType)
        heldPieceType = piece.type
        holdPieceLocked = true
        displayDelegate?.updateHeldPiece(piece.type)
    }

    func endGame() {
        isGameRunning = false
        eventDelegate?.gameDidEnd()
    }
}






















