//
//  Field.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/**
 A field is a model of what is presently on the playfield.  It handles the logic
 of how the playing piece behave on the field, reports how field changes at the
 individual blocks level, and handles piece locking / line clears.  The field
 size is 40 x 10, of which the lower half is visible (and change is reported).
 */
final class Field {


    enum StartPieceResult {
        case success
        case stillHasActivePiece
        case obstructed
    }


    // 
    fileprivate var blockTypes: [Block.BlockType]
    // Changes are keyed by their index, so multiple changes on same place is overridden
    fileprivate var unreportedChanges: [Int : Block] = [:]

    fileprivate let updateBlocks: ([Block]) -> Void

    fileprivate var activePiece: Piece? {
        didSet {
            oldValue?.blocks.forEach(clearBlock)
            activePiece?.blocks.forEach(setBlock)
            reportChanges()
        }
    }

    init(updateBlocks: @escaping ([Block]) -> Void) {
        blockTypes = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
        self.updateBlocks = updateBlocks
    }

}


extension Field {

    @discardableResult
    func startPiece(type: Tetromino) -> StartPieceResult {
//        guard activePiece == nil else { return .stillHasActivePiece }

//        activePiece = Piece(type: type, x: 4, y: 20, orientation: .up)
        activePiece = Piece(type: type, x: 4, y: 10, orientation: .up)


        

        // TODO: Top-out logic

        return .success
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
        let type = clear ? .blank : block.type
        let newBlock = clear ? Block(type: .blank, x: block.x, y: block.y) : block
        let i = block.x + block.y * 10
        if blockTypes[i] != type {
            blockTypes[i] = type
            if i < 10 * 20 {
                unreportedChanges[i] = newBlock
            }
        }
    }

    func reportChanges() {
        updateBlocks(Array(unreportedChanges.values))
        unreportedChanges.removeAll(keepingCapacity: true)
    }

}





