//
//  Block.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


typealias Offset = (x: Int, y: Int)


struct Block {
    let mino: Tetromino
    var x: Int
    var y: Int
}

func +(lhs: Block, rhs: Offset) -> Block {
    var block = lhs
    block.x += rhs.x
    block.y += rhs.y
    return block
}


