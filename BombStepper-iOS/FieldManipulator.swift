//
//  FieldManipulator.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/28/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/**
 A field manipulator handles the logic of how the playing piece behave on the
 field. It operates and reports on field changes.  For soft drop lock timing,
 call update for each scene tick.
 */
final class FieldManipulator {


    enum PieceLandingStatus {
        case floating
        case landed
        case landedMoved  // i.e. was landed, now moved but still landed
    }


    /// FieldManipulator does work on a separate queue, so UI stuff might want to be dispatched back to main
    weak var system: TetrisSystem?

    fileprivate let field: Field
    fileprivate var hideGhost = false
    fileprivate var isActivePieceLanded: Bool = false

    // Put most operations on a serial queue to make access on the two properties above atomic
    fileprivate let queue = DispatchQueue(label: "net.mathemusician.BombStepper.Field")

    fileprivate var activePiece: Piece? {
        didSet { activePieceUpdated(current: activePiece, previous: oldValue) }
    }
    fileprivate var ghostPiece: Piece?

    init(field: Field) {
        self.field = field
    }

}


extension FieldManipulator: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        hideGhost = settings.hideGhost
    }
}


extension FieldManipulator {
    
    // Returns if piece successfully started
    @discardableResult
    func startPiece(type: Tetromino) -> Bool {
        var result = true
        queue.sync {
            guard activePiece == nil else {
                result = false
                return
            }
            
            let piece = Piece(type: type, x: 4, y: 20)

            guard !field.pieceIsObstructed(piece) else {
                result = false
                defer {
                    self.system?.fieldDidTopOut()
                }
                return
            }

            self.activePiece = piece
            reportChanges()
        }
        return result
    }
    
    func movePiece(_ direction: Direction, steps: Int = 1) {
        queue.async {
            self.movePieceAsync(direction, steps: steps)
            self.reportChanges()
        }
    }

    @discardableResult
    func extractActivePiece() -> Piece? {
        var piece: Piece?
        queue.sync {
            piece = activePiece
            activePiece = nil
        }
        return piece
    }

    func rotatePiece(_ direction: RotationDirection) {
        guard let piece = activePiece else { return }

        let kickCandidates: [Piece]
        switch direction {
        case .left:
            kickCandidates = piece.kickCandidatesForRotatingLeft()
        case .right:
            kickCandidates = piece.kickCandidatesForRotatingRight()
        }
        
        replacePieceWithFirstValidPiece(in: kickCandidates)
    }
    
    func hardDrop() {
        queue.async {
            while self.moveActivePiece(.down) { }
            self.lockDown()
            self.reportChanges()
        }
    }
    
    func reset() {
        queue.async {
            self.field.reset()
            self.activePiece = nil
            self.ghostPiece = nil
        }
    }
}


private extension FieldManipulator {

    func activePieceUpdated(current: Piece?, previous: Piece?) {
        // Only go forward if pieces are "blockwise different"
        switch (current, previous) {
        case (nil, nil): return
        case (.some(let c), .some(let p)) where c.isBlockwiseEqual(to: p): return
        default: break
        }

        // Update blocks
        previous.map(field.clearPiece)
        ghostPiece.map(field.clearPiece)

        ghostPiece = hideGhost ? nil : current.map(positionedGhost)
        ghostPiece.map(field.setPiece)
        current.map(field.setPiece)

        testSoftLock()
    }

    func testSoftLock() {

        let wasLanded = isActivePieceLanded
        let isLanded = field.isPieceLanded(activePiece)
        isActivePieceLanded = isLanded

        let status: FieldManipulator.PieceLandingStatus

        switch (wasLanded, isLanded) {
        case (true, false):  status = .floating
        case (false, true):  status = .landed
        case (true, true):   status = .landedMoved
        case (false, false): return
        }

        system?.activePieceLandingStatusChanged(landed: status)
    }
    
    func lockDown() {
        guard let piece = activePiece else { return }
        activePiece = nil
        field.setLockedPiece(piece)

        // Check lock out (http://tetris.wikia.com/wiki/Top_out)
        let lockedOut = !piece.blocks.contains { $0.y < 20 }
        if lockedOut {
            self.system?.fieldDidTopOut()
        }
        else {
            let clearedLines = field.clearCompletedLines(spannedBy: piece)
            
            // TODO: T-spin detection and reporting
            
            self.system?.activePieceDidLock(lineClear: .normal(lines: clearedLines))
        }
    }

    func movePieceAsync(_ direction: Direction, steps: Int = 1) {
        for _ in 0 ..< steps {
            if !moveActivePiece(direction) { break }
        }
    }
    
    func replacePieceWithFirstValidPiece(in candidates: [Piece]) {
        queue.async {
            for candidate in candidates {
                if !self.field.pieceIsObstructed(candidate) {
                    self.activePiece = candidate
                    self.reportChanges()
                    break
                }
            }
        }
    }

    // Returns whether move was successful
    // Remember to manually reportChanges()
    func moveActivePiece(_ direction: Direction) -> Bool {
        guard var piece = activePiece else { return false }

        let offset = direction.offset

        if offset.x != 0 { piece.x += offset.x }
        if offset.y != 0 { piece.y += offset.y }
        
        let canMove = !field.pieceIsObstructed(piece)
        if canMove { activePiece = piece }

        return canMove
    }
 
    func reportChanges() {
        let blocks = field.dumpUnreportedChanges()
        system?.updatePlayField(blocks: blocks)
    }

}


private extension FieldManipulator {

    func positionedGhost(for piece: Piece) -> Piece {
        var ghost = piece.ghost
        while !field.pieceIsObstructed(ghost) { ghost.y -= 1 }
        ghost.y += 1
        return ghost
    }

}

