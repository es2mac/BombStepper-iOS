//
//  Directions.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


typealias Offset = (x: Int, y: Int)


enum Direction {
    case up, down, left, right
    
    var offset: Offset {
        switch self {
        case .up:    return (x:  0, y:  1)
        case .down:  return (x:  0, y: -1)
        case .left:  return (x: -1, y:  0)
        case .right: return (x:  1, y:  0)
        }
    }

    init(_ xDirection: XDirection) {
        switch xDirection {
        case .left:  self = .left
        case .right: self = .right
        }
    }
}


enum XDirection {
    case left, right
    
    var offset: Offset {
        switch self {
        case .left:  return (x: -1, y:  0)
        case .right: return (x:  1, y:  0)
        }
    }

    init?(_ direction: Direction) {
        switch direction {
        case .left:  self = .left
        case .right: self = .right
        default: return nil
        }
    }
}

