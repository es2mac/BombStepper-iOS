//
//  Field.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


protocol FieldDelegate: class {
    func updateField(blocks: [Block])
    func fieldActivePieceDidLock()
}


/**
 A field is a model of what is presently on the playfield.  It handles the logic
 of how the playing piece behave on the field, reports how field changes at the
 individual blocks level, and handles things like piece locking, line clears, 
 and top out. The field size is 40 x 10, twice as high as the visible part.
 Only changes in the visible half is reported.
 */
final class Field {


    enum StartPieceResult {
        case success
        case stillHasActivePiece
        case toppedOut
    }


    fileprivate weak var delegate: FieldDelegate?
    // Data for the whole 40 x 10 field
    fileprivate var blockTypes: [Block.BlockType]
    // Changes are keyed by their index, so multiple changes on same place is overridden
    fileprivate var unreportedChanges: [Int : Block] = [:]

    fileprivate var activePiece: Piece? {
        didSet {
            oldValue?.blocks.forEach(clearBlock)
            activePiece?.blocks.forEach(setBlock)
        }
    }

    init(delegate: FieldDelegate?) {
        self.delegate = delegate
        blockTypes = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
    }

}


extension Field {

    // TODO: handle inputs
    // TODO: piece lock, lock timing
    // TODO: line clear

    
    /// Top out is reported here
    @discardableResult
    func startPiece(type: Tetromino) -> StartPieceResult {
        guard activePiece == nil else { return .stillHasActivePiece }

        let piece = Piece(type: type, x: 4, y: 20, orientation: .up)
        // check if piece obstructed, if it is then we topped out

        activePiece = piece
        
        reportChanges()
        
        return .success
    }

    func process(input: Button) {
        guard activePiece != nil else { return }

        switch input {
        case .moveLeft:
            activePiece?.x -= 1
        case .moveRight:
            activePiece?.x += 1
        case .hardDrop:
            activePiece = nil
        case .softDrop:
            activePiece?.y -= 1
        case .hold:
            break
        case .rotateLeft:
            activePiece = activePiece?.kickCandidatesForRotatingLeft()[0]
        case .rotateRight:
            activePiece = activePiece?.kickCandidatesForRotatingRight()[0]
        case .none:
            break
        }

        reportChanges()
    }

    func process(das: DASManager.Direction) {

        // TODO
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
        guard !unreportedChanges.isEmpty else { return }
        delegate?.updateField(blocks: Array(unreportedChanges.values))
        unreportedChanges.removeAll(keepingCapacity: true)
    }

}





