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
    private let previewsCount = 5

    init() {
        randomizer = GKARC4RandomSource()
        defer {
            while stack.count < previewsCount + 1 {
                stack.insert(contentsOf: newBag(), at: 0)
            }
        }
    }

    func popNext() -> Tetromino {
        if stack.count <= previewsCount {
            defer {
                stack.insert(contentsOf: newBag(), at: 0)
            }
        }
        return stack.popLast()!
    }

    func previews() -> [Tetromino] {
        return stack.suffix(previewsCount).reversed()
    }

    func reset() {
        stack = newBag()
    }

    private func newBag() -> [Tetromino] {
        return randomizer.arrayByShufflingObjects(in: Tetromino.allCases) as! [Tetromino]
    }
    
}

