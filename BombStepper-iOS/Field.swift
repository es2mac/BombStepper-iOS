//
//  Field.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/// Field does work on a separate queue, so delegate might want to dispatch back to main
protocol FieldDelegate: class {
    func updateField(blocks: [Block])
    func activePieceDidLock()
    func fieldDidTopOut()
    func activePieceBottomTouchingStatusChanged(touching: Field.BottomTouchingStatus)
    // Assume "covered T corners count" > 0 only for T-clears
    func linesCleared(_ count: Int, coveredTCornersCount: Int, isImmobile: Bool)
}

extension FieldDelegate {
    func linesCleared(_ count: Int) {
        linesCleared(count, coveredTCornersCount: 0, isImmobile: false)
    }
}


/**
 A field is a model of what is presently on the playfield.  It handles the logic
 of how the playing piece behave on the field, reports how field changes at the
 individual blocks level, and handles things like piece locking, line clears, 
 and top out. The field size is 40 x 10, twice as high as the visible part.
 Only changes in the visible half is reported.  For soft drop lock timing,
 call update for each scene tick.
 */
final class Field {


    enum BottomTouchingStatus {
        case floating
        case touching
        case touchingMoved  // i.e. was touching, now moved but still touching
    }


    weak var delegate: FieldDelegate?

    // Data for the whole 40 x 10 field
    fileprivate var allBlocks: [Block.BlockType]
    // Changes are keyed by their index, so multiple changes on same place is overridden
    fileprivate var unreportedChanges: [Int : (newBlock: Block, oldType:Block.BlockType)] = [:]
    fileprivate var isActivePieceTouchingBottom: Bool = false
    // Put most operations on a serial queue to make access on the two properties above atomic
    fileprivate let queue = DispatchQueue(label: "net.mathemusician.BombStepper.Field")

    fileprivate(set) var activePiece: Piece? {
        didSet { activePieceUpdated(current: activePiece, previous: oldValue) }
    }

    fileprivate var ghostPiece: Piece?

    fileprivate var hideGhost = false

    fileprivate var maxRowOfLockedBlocks = 0

    init(delegate: FieldDelegate? = nil) {
        self.delegate = delegate
        allBlocks = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
    }

}


extension Field: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        hideGhost = settings.hideGhost
    }
}


extension Field {


    // WISHLIST: gravity setting


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
            
            guard !pieceIsObstructed(piece) else {
                result = false
                self.delegate?.fieldDidTopOut()
                return
            }
            
            self.activePiece = piece
            reportChanges()
        }
        return result
    }

    func clearActivePiece() {
        activePiece = nil   // generally this is called when holding, so no need to report just yet
    }

    func movePiece(_ direction: Direction, steps: Int = 1) {
        queue.async {
            self.movePieceAsync(direction, steps: steps)
            self.reportChanges()
        }
    }

    func replacePieceWithFirstValidPiece(in candidates: [Piece]) {
        queue.async {
            candidates.first(where: { !self.pieceIsObstructed($0) }).map {
                self.activePiece = $0
                self.reportChanges()
            }
        }
    }

    func hardDrop() {
        queue.async {
            while self.moveActivePiece((x: 0, y: -1)) { }
            self.lockDown()
            self.reportChanges()
        }
    }

    func reset() {
        (0 ..< allBlocks.count).forEach { allBlocks[$0] = .blank }
        activePiece = nil
        ghostPiece = nil
        unreportedChanges.removeAll()
    }

}


private extension Field {

    func activePieceUpdated(current: Piece?, previous: Piece?) {
        // Only go forward if pieces are "blockwise different"
        switch (current, previous) {
        case (nil, nil): return
        case (.some(let c), .some(let p)) where c.isBlockwiseEqual(to: p): return
        default: break
        }

        // Update blocks
        previous?.blocks.forEach(clearBlock)
        ghostPiece?.blocks.forEach(clearBlock)
        
        ghostPiece = hideGhost ? nil : current.map(positionedGhost)
        ghostPiece?.blocks.forEach(setBlock)
        current?.blocks.forEach(setBlock)

        testSoftLock()
    }

    func testSoftLock() {

        let wasTouching = isActivePieceTouchingBottom
        let isTouching: Bool

        switch activePiece {
        case .some(var testPiece):
            testPiece.y -= 1
            isTouching = pieceIsObstructed(testPiece)
        case nil:
            isTouching = false
        }

        isActivePieceTouchingBottom = isTouching

        let status: BottomTouchingStatus

        switch (wasTouching, isTouching) {
        case (true, false):  status = .floating
        case (false, true):  status = .touching
        case (true, true):   status = .touchingMoved
        case (false, false): return
        }

        delegate?.activePieceBottomTouchingStatusChanged(touching: status)
    }

    func movePieceAsync(_ direction: Direction, steps: Int = 1) {
        for _ in 0 ..< steps {
            if !moveActivePiece(direction.offset) { break }
        }
    }
}


private extension Field {
    
    func positionedGhost(for piece: Piece) -> Piece {
        var ghost = piece.ghost
        while !pieceIsObstructed(ghost) { ghost.y -= 1 }
        ghost.y += 1
        return ghost
    }

    func lockDown() {
        guard let piece = activePiece else { return }
        activePiece = nil
        piece.blocks.forEach { setBlock($0.locked) }

        // Check lock out (http://tetris.wikia.com/wiki/Top_out)
        let lockedOut = !piece.blocks.contains { $0.y < 20 }
        if lockedOut {
            self.delegate?.fieldDidTopOut()
        }
        else {
            maxRowOfLockedBlocks = max(maxRowOfLockedBlocks, piece.blocks.map({$0.y}).max()!)
            clearCompletedLines(clearingPiece: piece)
            self.delegate?.activePieceDidLock()
        }

    }

    func clearCompletedLines(clearingPiece piece: Piece) {

        // TODO: T-spin detection?

        let pieceYMin = piece.blocks.map({$0.y}).min()!
        let pieceYMmax = piece.blocks.map({$0.y}).max()!

        var clearedLinesCount = 0

        // Check lines possibly cleared by this piece
        for y in pieceYMin ... pieceYMmax {
            let currentLine = allBlocks[(y * 10) ..< ((y + 1) * 10)]
            if !currentLine.contains(where: { type in
                if case .locked = type { return false }
                else { return true }
            }) {
                clearedLinesCount += 1
            }
            else if clearedLinesCount > 0 { // Shift this incomplete line down by the number of lines cleared so far
                shiftRow(y, downBy: clearedLinesCount)
            }
        }

        // Shift the rest of the lines if needed
        if clearedLinesCount > 0 {
            for y in (pieceYMmax + 1) ... (maxRowOfLockedBlocks + clearedLinesCount) {
                shiftRow(y, downBy: clearedLinesCount)
            }
            maxRowOfLockedBlocks -= clearedLinesCount
            delegate?.linesCleared(clearedLinesCount)
        }
    }

    func shiftRow(_ row: Int, downBy lines: Int) {
        let destinationRow = row - lines
        guard destinationRow >= 0 else { return }
        print("Shift row", row, "by", lines)
        let currentLine = allBlocks[(row * 10) ..< ((row + 1) * 10)]
        for (index, type) in currentLine.enumerated() {
            let block = Block(type: type, x: index % 10, y: destinationRow)
            setBlock(block)
        }
    }

    // Returns whether move was successful
    // Remember to manually reportChanges()
    @discardableResult
    func moveActivePiece(_ offset: Offset) -> Bool {
        guard var piece = activePiece else { return false }

        piece.x += offset.x
        piece.y += offset.y
        let canMove = !pieceIsObstructed(piece)
        if canMove { activePiece = piece }

        return canMove
    }

    // Rules for free space: within 10 x 40, either blank or is active piece's space
    // because this is used to check if active piece can move
    func pieceIsObstructed(_ piece: Piece) -> Bool {
        for block in piece.blocks {
            if !(0 ..< 10 ~= block.x) { return true }
            if !(0 ..< 40 ~= block.y) { return true }
            if case .locked = allBlocks[block.x + block.y * 10] { return true }
        }
        return false
    }
}


private extension Field {

    func setBlock(_ block: Block) {
        setBlock(block, clear: false)
    }

    func clearBlock(_ block: Block) {
        setBlock(block, clear: true)
    }

    private func setBlock(_ block: Block, clear: Bool) {
        let i = block.x + block.y * 10
        let type = clear ? .blank : block.type

        guard allBlocks[i] != type else { return }
        let previousType = allBlocks[i]
        allBlocks[i] = type

        guard i < 10 * 20 else { return }

        // Change changeset as smartly as possible
        let newBlock = clear ? Block(type: .blank, x: block.x, y: block.y) : block

        if let (_, oldType) = unreportedChanges[i] {
            if type == oldType {
                unreportedChanges.removeValue(forKey: i)
            }
            else {
                unreportedChanges[i] = (newBlock: newBlock, oldType: oldType)
            }
        }
        else {
            unreportedChanges[i] = (newBlock: newBlock, oldType: previousType)
        }
    }

    func reportChanges() {
        guard !unreportedChanges.isEmpty else { return }

        let blocks = unreportedChanges.map { $0.value.newBlock }
        unreportedChanges.removeAll(keepingCapacity: true)

        self.delegate?.updateField(blocks: blocks)
    }

}








