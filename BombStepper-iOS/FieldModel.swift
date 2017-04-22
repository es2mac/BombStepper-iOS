//
//  FieldModel.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


final class FieldModel {



    enum StartPieceResult {
        case success
        case atPlay
        case blocked
    }


    private var minos: [Tetromino]
    private let updateBlocks: ([Block]) -> Void
    private var activePiece: Piece? {
        didSet {
            oldValue?.blocks.forEach(setBlock)
            activePiece?.blocks.forEach(setBlock)
        }
    }

    init(updateBlocks: @escaping ([Block]) -> Void) {
        minos = [Tetromino](repeating: .blank, count: 10 * 40)
        self.updateBlocks = updateBlocks
    }

    func startPiece(type: Tetromino) -> StartPieceResult {
        guard activePiece == nil else { return .atPlay }

        activePiece = Piece.startingPiece(type: type)


        

        // TODO: Top-out logic

        return .success
    }

    // Changes are keyed by their index, so multiple changes on same place is overridden
    private var unreportedChanges: [Int : Block] = [:]

    private func setBlock(_ block: Block) {
        let i = block.x + block.y * 10
        if minos[i] != block.mino {
            minos[i] = block.mino
            unreportedChanges[i] = block
        }
    }

}


//private extension FieldModel.Piece {





