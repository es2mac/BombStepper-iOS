//
//  FieldModel.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


final class FieldModel {


//    fileprivate struct Piece {
    struct Piece {


        enum Orientation {

            case up, right, down, left

            func rotatedRight() -> Orientation {
                switch self {
                case .up: return .right
                case .right: return .down
                case .down: return .left
                case .left: return .up
                }
            }

            func rotatedLeft() -> Orientation {
                switch self {
                case .up: return .left
                case .left: return .down
                case .down: return .right
                case .right: return .up
                }
            }
        }


        let type: Tetromino
        let x: Int
        let y: Int
        let orientation: Orientation

    }

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
extension FieldModel.Piece {

    struct KickStates: Sequence, IteratorProtocol {
        var offsetsIterator: Array<(x: Int, y: Int)>.Iterator
        let piece: FieldModel.Piece
        mutating func next() -> FieldModel.Piece? {
            return offsetsIterator.next().map { piece.offsetBy($0) }
        }

        init(piece: FieldModel.Piece) {
            self.piece = piece
            offsetsIterator = kickOffsets[piece.type]![piece.orientation]!.makeIterator()
        }
    }

    func rotatedRight() -> FieldModel.Piece {
        return FieldModel.Piece(type: type, x: x, y: y, orientation: orientation.rotatedRight())
    }

    func rotatedLeft() -> FieldModel.Piece {
        return FieldModel.Piece(type: type, x: x, y: y, orientation: orientation.rotatedLeft())
    }

    func offsetBy(_ offset: (x: Int, y: Int)) -> FieldModel.Piece {
        return FieldModel.Piece(type: type, x: x + offset.x, y: y + offset.y, orientation: orientation)
    }

    var kickStates: KickStates {
        return KickStates(piece: self)
    }

    var blocks: [Block] {
        // TODO: bring in table
        
        return []
    }

    static func startingPiece(type: Tetromino) -> FieldModel.Piece {
        return FieldModel.Piece(type: type, x: 4, y: 20, orientation: .up)
    }

}


extension FieldModel.Piece.Orientation: Hashable { }


private let kickOffsets: [Tetromino : [FieldModel.Piece.Orientation : [(x: Int, y: Int)]]] = [
    .I : [ .up:    [( 0,  0), (-1,  0), ( 2,  0), (-1,  0), ( 2,  0)],
           .right: [(-1,  0), ( 0,  0), ( 0,  0), ( 0,  1), ( 0, -2)],
           .down:  [(-1,  1), ( 1,  1), (-2,  1), ( 1,  0), (-2,  0)],
           .left:  [( 0,  1), ( 0,  1), ( 0,  1), ( 0, -1), ( 0,  2)]],

    .J : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)],
           .down:  [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]],

    .L : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)],
           .down:  [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]],

    .O : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0, -1), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .down:  [(-1, -1), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [(-1,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)]],

    .S : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)],
           .down:  [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]],

    .T : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)],
           .down:  [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]],

    .Z : [ .up:    [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .right: [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)],
           .down:  [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)],
           .left:  [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]]]






