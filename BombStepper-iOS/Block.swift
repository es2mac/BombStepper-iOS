//
//  Block.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


/**
 A block is a single square on the playing field.  It has a position and knows
 how to it is displayed.
 */
struct Block {

    enum BlockType {
        case blank
        case active(Tetromino)
        case ghost(Tetromino)
        case locked(Tetromino)
        // case bomb
    }

    let type: BlockType
    var x: Int
    var y: Int

    var locked: Block {
        switch type {
        case .blank:
            return self
        case .active(let t), .ghost(let t), .locked(let t):
            return Block(type: .locked(t), x: x, y: y)
        }
    }
}


extension Block.BlockType {
    static var allCases: [Block.BlockType] {
        return [.blank]
            + Tetromino.allCases.map { Block.BlockType.active($0) }
            + Tetromino.allCases.map { Block.BlockType.ghost($0) }
            + Tetromino.allCases.map { Block.BlockType.locked($0) }
    }
}


extension Block.BlockType: Hashable, Equatable {

    var hashValue: Int {
        switch self {
        case .blank: return 0
        case .active(let t): return 1 + 1 * 7 + t.rawValue
        case .ghost(let t):  return 1 + 2 * 7 + t.rawValue
        case .locked(let t): return 1 + 3 * 7 + t.rawValue
        }
    }

    var name: String {
        switch self {
        case .blank:         return "blank"
        case .active(let t): return "active \(t.name)"
        case .ghost(let t):  return "ghost \(t.name)"
        case .locked(let t): return "locked \(t.name)"
        }
    }

    public static func ==(lhs: Block.BlockType, rhs: Block.BlockType) -> Bool {
        switch (lhs, rhs) {
        case (.blank, blank):
            return true
        case (.active(let t1), .active(let t2)),
             (.ghost(let t1),  .ghost(let t2)),
             (.locked(let t1), .locked(let t2)):
            return t1 == t2
        default:
            return false
        }
    }
}






