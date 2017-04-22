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
    }

    let type: Tetromino
    var x: Int
    var y: Int
    var orientation: Orientation

    var blocks: [Block] {
        let blockOffsets = type.blockOffsets(for: orientation)
        return blockOffsets.map { offset in
            Block(mino: type, x: x + offset.x, y: y + offset.y)
        }
    }

}


private extension Piece.Orientation {

    func rotatedRight() -> Piece.Orientation {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }

    func rotatedLeft() -> Piece.Orientation {
        switch self {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }
    
}


extension Piece {

    func kickStates(to toOrientation: Orientation) -> [Piece] {

        let kickOffsets = type.kickOffsets(from: orientation, to: toOrientation)

        return kickOffsets.map { offset in
            var piece = self
            piece.x += offset.x
            piece.y += offset.y
            piece.orientation = toOrientation
            return piece
        }
    }
}


extension Piece: Equatable {
    static public func ==(lhs: Piece, rhs: Piece) -> Bool {
        if lhs.type == rhs.type,
            lhs.x == rhs.x,
            lhs.y == rhs.y,
            lhs.orientation == rhs.orientation { return true }
        else { return false }
    }
}


private extension Tetromino {

    func blockOffsets(for orientation: Piece.Orientation) -> [Offset] {
        let neutralBlockOffsets = blockOffsets
        let pieceOffset = offsets(for: orientation)[0]
        let rotationMatrix: (Int, Int, Int, Int)

        switch orientation {
        case .up: return neutralBlockOffsets
        case .right: rotationMatrix = (0, 1, -1, 0)
        case .down: rotationMatrix = (-1, 0, 0, -1)
        case .left: rotationMatrix = (0, -1, 1, 0)
        }

        return neutralBlockOffsets.map { blockOffset in
            (x: pieceOffset.x + (rotationMatrix.0 * blockOffset.x + rotationMatrix.2 * blockOffset.y),
             y: pieceOffset.y + (rotationMatrix.1 * blockOffset.x + rotationMatrix.3 * blockOffset.y))
        }
    }
    
    private var blockOffsets: [Offset] {
        switch self {
        case .I: return [(0, 0), (-1, 0), ( 1, 0), (2, 0)]
        case .J: return [(0, 0), (-1, 1), (-1, 0), (1, 0)]
        case .L: return [(0, 0), (-1, 0), ( 1, 0), (1, 1)]
        case .O: return [(0, 0), ( 0, 1), ( 1, 1), (1, 0)]
        case .S: return [(0, 0), (-1, 0), ( 0, 1), (1, 1)]
        case .T: return [(0, 0), (-1, 0), ( 1, 0), (0, 1)]
        case .Z: return [(0, 0), (-1, 1), ( 0, 1), (1, 0)]
        default: return []
        }
    }
}


// https://harddrop.com/wiki/SRS
private extension Tetromino {

    func offsets(for orientation: Piece.Orientation) -> [Offset] {
        switch self {
        case .I:
            switch orientation {
            case .up:    return [( 0,  0), (-1,  0), ( 2,  0), (-1,  0), ( 2,  0)]
            case .right: return [(-1,  0), ( 0,  0), ( 0,  0), ( 0,  1), ( 0, -2)] 
            case .down:  return [(-1,  1), ( 1,  1), (-2,  1), ( 1,  0), (-2,  0)] 
            case .left:  return [( 0,  1), ( 0,  1), ( 0,  1), ( 0, -1), ( 0,  2)]
            }
            
        case .J, .L, .S, .T, .Z:
            switch orientation {
            case .up:    return [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)]
            case .right: return [( 0,  0), ( 1,  0), ( 1, -1), ( 0,  2), ( 1,  2)]
            case .down:  return [( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0), ( 0,  0)]
            case .left:  return [( 0,  0), (-1,  0), (-1, -1), ( 0,  2), (-1,  2)]
            }
        case .O:
            switch orientation {
            case .up:    return [( 0,  0)]
            case .right: return [( 0, -1)]
            case .down:  return [(-1, -1)]
            case .left:  return [(-1,  0)]
            }                  
        default:
            return [(x: 0, y: 0)]
        }
    }

    func kickOffsets(from fromOrientation: Piece.Orientation, to toOrientation: Piece.Orientation) -> [Offset] {
        let fromOffsets = offsets(for: fromOrientation)
        let toOffsets = offsets(for: toOrientation)
        return zip(fromOffsets, toOffsets).map(-)
    }
}

private func -(lhs: Offset, rhs: Offset) -> Offset {
        return (x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}




