//
//  Piece.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


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


extension Piece {

    struct KickStates: Sequence, IteratorProtocol {
        var offsetsIterator: Array<(x: Int, y: Int)>.Iterator
        let piece: Piece
        mutating func next() -> Piece? {
            return offsetsIterator.next().map { piece.offsetBy($0) }
        }

        init(piece: Piece) {
            self.piece = piece
            offsetsIterator = kickOffsets[piece.type]![piece.orientation]!.makeIterator()
        }
    }

    func rotatedRight() -> Piece {
        return Piece(type: type, x: x, y: y, orientation: orientation.rotatedRight())
    }

    func rotatedLeft() -> Piece {
        return Piece(type: type, x: x, y: y, orientation: orientation.rotatedLeft())
    }

    func offsetBy(_ offset: (x: Int, y: Int)) -> Piece {
        return Piece(type: type, x: x + offset.x, y: y + offset.y, orientation: orientation)
    }

    var kickStates: KickStates {
        return KickStates(piece: self)
    }

    var blocks: [Block] {
        // TODO: bring in table

        return []
    }

    static func startingPiece(type: Tetromino) -> Piece {
        return Piece(type: type, x: 4, y: 20, orientation: .up)
    }

}


extension Piece.Orientation: Hashable { }


extension Piece: Equatable {
    static public func ==(lhs: Piece, rhs: Piece) -> Bool {
        if lhs.type == rhs.type,
            lhs.x == rhs.x,
            lhs.y == rhs.y,
            lhs.orientation == rhs.orientation { return true }
        else { return false }
    }
}


private let kickOffsets: [Tetromino : [Piece.Orientation : [(x: Int, y: Int)]]] = [
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


