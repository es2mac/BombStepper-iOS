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
 Only changes in the visible half is reported.  For soft drop lock timing,
 call update for each scene tick.
 */
final class Field {


    enum StartPieceResult {
        case success
        case stillHasActivePiece
        case toppedOut
    }


    fileprivate weak var delegate: FieldDelegate?
    // Data for the whole 40 x 10 field
    fileprivate var allTypes: [Block.BlockType]
    // Changes are keyed by their index, so multiple changes on same place is overridden
    fileprivate var unreportedChanges: [Int : (newBlock: Block, oldType:Block.BlockType)] = [:]

    fileprivate var activePiece: Piece? {
        didSet {
            oldValue?.blocks.forEach(clearBlock)
            activePiece?.blocks.forEach(setBlock)
        }
    }

    init(delegate: FieldDelegate?) {
        self.delegate = delegate
        allTypes = Array<Block.BlockType>(repeating: Block.BlockType.blank, count: 10 * 40)
    }

}


extension Field {

    // TODO: rotation
    // TODO: piece lock, lock timing
    // TODO: line clear

    
    /// Top out is reported here
    @discardableResult
    func startPiece(type: Tetromino) -> StartPieceResult {
        guard activePiece == nil else { return .stillHasActivePiece }

//        let piece = Piece(type: type, x: 4, y: 20, orientation: .up)
        let piece = Piece(type: type, x: 4, y: 10, orientation: .up)
        // check if piece obstructed, if it is then we topped out

        activePiece = piece
        
        reportChanges()
        
        return .success
    }

    func process(input: Button) {
        guard activePiece != nil else { return }

        switch input {
        case .moveLeft: moveActivePiece((x: -1, y: 0))
        case .moveRight: moveActivePiece((x: 1, y: 0))
        case .hardDrop: hardDrop()
        case .softDrop: softDrop()
        case .hold: break
        case .rotateLeft: activePiece = activePiece?.kickCandidatesForRotatingLeft()[0]   // TODO: kicking and stuff
        case .rotateRight: activePiece = activePiece?.kickCandidatesForRotatingRight()[0]
        case .none: break
        }

        reportChanges()
    }

    func process(das: DASManager.Direction) {
        let offset: Offset
        switch das {
        case .left:
            offset = (x: -1, y: 0)
        case .right:
            offset = (x: 1, y: 0)
        }
        while moveActivePiece(offset) { }
        reportChanges()
    }

    func update() {

        // TODO: soft drop
    }

}


private extension Field {

    func softDrop()  {
        while moveActivePiece((x: 0, y: -1)) { }
    }

    func hardDrop() {
        softDrop()
        lockDown()
    }
    
    func lockDown() {
        guard let piece = activePiece else { return }
        activePiece = nil
        piece.blocks.forEach(setBlock)
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
        let activePieceBlocks = activePiece?.blocks ?? []
        for block in piece.blocks {
            if !(0 ..< 10 ~= block.x) { return true }
            if !(0 ..< 40 ~= block.y) { return true }
            if allTypes[block.x + block.y * 10] != .blank,
                !activePieceBlocks.contains(where: { $0.x == block.x && $0.y == block.y }) {
                return true
            }
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

        guard allTypes[i] != type else { return }
        let previousType = allTypes[i]
        allTypes[i] = type

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
        delegate?.updateField(blocks: unreportedChanges.map { $0.value.newBlock })
        unreportedChanges.removeAll(keepingCapacity: true)
    }

}





