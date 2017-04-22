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
            oldValue?.blocks.forEach(setBlock)
            activePiece?.blocks.forEach(setBlock)
            reportChanges()
        }
    }

    init(updateBlocks: @escaping ([Block]) -> Void) {
        blockTypes = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
        self.updateBlocks = updateBlocks
    }

}


private extension Field {

    func startPiece(type: Tetromino) -> StartPieceResult {
//        guard activePiece == nil else { return .stillHasActivePiece }

        activePiece = Piece(type: type, x: 4, y: 20, orientation: .up)


        

        // TODO: Top-out logic

        return .success
    }

}


private extension Field {

    func setBlock(_ block: Block) {
        let i = block.x + block.y * 10
        if blockTypes[i] != block.type {
            blockTypes[i] = block.type
            unreportedChanges[i] = block
        }
    }

    func reportChanges() {
        updateBlocks(Array(unreportedChanges.values))
        unreportedChanges.removeAll(keepingCapacity: true)
    }

}





