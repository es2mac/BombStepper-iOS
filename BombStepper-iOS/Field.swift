//
//  Field.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/**
 A field is a model of what is presently on the playfield.  The field size is
 40 x 10, twice as high as the visible part. Only changes in the visible half
 is tracked for UI update purposes.
 */
final class Field {


    // Data for the whole 40 x 10 field
    fileprivate var allBlocks: [Block.BlockType]
    // Changes are keyed by their index, so multiple changes on same place is overridden
    fileprivate var unreportedChanges: [Int : (newBlock: Block, oldType:Block.BlockType)] = [:]

    fileprivate var maxRowOfLockedBlocks = 0

    init() {
        allBlocks = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
    }

}


extension Field {

    func reset() {
        (0 ..< allBlocks.count).forEach { allBlocks[$0] = .blank }
        unreportedChanges.removeAll()
    }
    
    func isPieceLanded(_ piece: Piece?) -> Bool {
        switch piece {
        case .some(var testPiece):
            testPiece.y -= 1
            return pieceIsObstructed(testPiece)
        case nil:
            return false
        }
    }

    func setLockedPiece(_ piece: Piece) {
        maxRowOfLockedBlocks = max(maxRowOfLockedBlocks, piece.blocks.map({$0.y}).max()!)
        piece.blocks.forEach { setBlock($0.locked) }
    }

    func clearPiece(_ piece: Piece) {
        piece.blocks.forEach(clearBlock)
    }

    func setPiece(_ piece: Piece) {
        piece.blocks.forEach(setBlock)
    }

    func clearCompletedLines(spannedBy piece: Piece) -> Int {

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
        }

        return clearedLinesCount
    }

    func pieceIsObstructed(_ piece: Piece) -> Bool {
        for block in piece.blocks {
            if !(0 ..< 10 ~= block.x) || !(0 ..< 40 ~= block.y) { return true }
            if case .locked = allBlocks[block.x + block.y * 10] { return true }
        }
        return false
    }

    func dumpUnreportedChanges() -> [Block] {
        let blocks = unreportedChanges.map { $0.value.newBlock }
        unreportedChanges.removeAll(keepingCapacity: true)
        return blocks
    }

}


private extension Field {

    func shiftRow(_ row: Int, downBy lines: Int) {
        let destinationRow = row - lines
        guard destinationRow >= 0 else { return }

        let currentLine = allBlocks[(row * 10) ..< ((row + 1) * 10)]

        for (index, type) in currentLine.enumerated() {
            let block = Block(type: type, x: index % 10, y: destinationRow)
            setBlock(block)
        }
    }
    
    func clearBlock(_ block: Block) {
        let blankBlock = Block(type: .blank, x: block.x, y: block.y)
        setBlock(blankBlock)
    }

    func setBlock(_ block: Block) {
        guard block.y < 20 else { return }

        let i = block.x + block.y * 10

        let previousType = allBlocks[i]
        guard previousType != block.type else { return }
        allBlocks[i] = block.type

        // Record changed set as smartly as possible

        if let (_, oldType) = unreportedChanges[i] {
            if block.type == oldType {
                unreportedChanges.removeValue(forKey: i)
            }
            else {
                unreportedChanges[i] = (newBlock: block, oldType: oldType)
            }
        }
        else {
            unreportedChanges[i] = (newBlock: block, oldType: previousType)
        }
    }
}


// func obstructedDiagonalCorners(aroundX x: Int, y: Int)








