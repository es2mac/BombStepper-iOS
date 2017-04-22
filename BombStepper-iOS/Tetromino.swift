//
//  Tetromino.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit



/**
 Tetromino defines the drawing color and shape in the initial (0) orientation
 for the 7 tetromino types.
 */
enum Tetromino: Int {
    case I, J, L, O, S, T, Z

    static let allCases: [Tetromino] = [.I, .J, .L, .O, .S, .T, .Z]
}


extension Tetromino {

    /// This defines the shape of the tetromino in its initial orientation,
    /// by specifying its four minos in terms of their offsets from the center mino
    var blockOffsets: [Offset] {
        switch self {
        case .I: return [(0, 0), (-1, 0), ( 1, 0), (2, 0)]
        case .J: return [(0, 0), (-1, 1), (-1, 0), (1, 0)]
        case .L: return [(0, 0), (-1, 0), ( 1, 0), (1, 1)]
        case .O: return [(0, 0), ( 0, 1), ( 1, 1), (1, 0)]
        case .S: return [(0, 0), (-1, 0), ( 0, 1), (1, 1)]
        case .T: return [(0, 0), (-1, 0), ( 1, 0), (0, 1)]
        case .Z: return [(0, 0), (-1, 1), ( 0, 1), (1, 0)]
        }
    }
}


extension Tetromino {

    var color: UIColor {
        switch self {
        case .I: return #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
        case .J: return #colorLiteral(red: 0.3169852495, green: 0.3903964162, blue: 0.6502153277, alpha: 1)
        case .L: return #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
        case .O: return #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
        case .S: return #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
        case .T: return #colorLiteral(red: 0.5975912213, green: 0.3411847949, blue: 0.7378113866, alpha: 1)
        case .Z: return #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
        }
    }

    var edgeColor: UIColor {

        switch self {
        case .I: return #colorLiteral(red: 0.1951910259, green: 0.4890178243, blue: 0.7345129925, alpha: 1)
        case .J: return #colorLiteral(red: 0.2253215105, green: 0.2783082841, blue: 0.4640846382, alpha: 1)
        case .L: return #colorLiteral(red: 0.6602754359, green: 0.3731460931, blue: 0.001209538981, alpha: 1)
        case .O: return #colorLiteral(red: 0.7639135355, green: 0.6259482935, blue: 0.002231495134, alpha: 1)
        case .S: return #colorLiteral(red: 0.1901697925, green: 0.5817678467, blue: 0.2838678132, alpha: 1)
        case .T: return #colorLiteral(red: 0.4623155365, green: 0.2632599308, blue: 0.5732287609, alpha: 1)
        case .Z: return #colorLiteral(red: 0.619027612, green: 0.2164497218, blue: 0.1466268146, alpha: 1)
        }
    }

}


