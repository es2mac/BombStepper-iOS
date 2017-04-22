//
//  TetrominoRandomizer.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/23/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation
import GameplayKit


class TetrominoRandomizer {

    private var stack: [Tetromino] = []
    private let randomizer: GKARC4RandomSource

    init() {
        randomizer = GKARC4RandomSource()
        stack = randomizer.arrayByShufflingObjects(in: Tetromino.allCases) as! [Tetromino]
    }

    func popNext() -> Tetromino {
        if stack.count < 6 {
            defer {
                stack.insert(contentsOf: randomizer.arrayByShufflingObjects(in: Tetromino.allCases) as! [Tetromino], at: 0)
            }
        }
        return stack.popLast()!
    }

    func previews() -> [Tetromino] {
        return Array(stack.suffix(5))
    }
    
}

