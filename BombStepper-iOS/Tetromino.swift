//
//  Tetromino.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

enum Tetromino {
    case I, J, L, O, S, Z, T, blank

    var color: UIColor {
        switch self {
        case .I: return #colorLiteral(red: 0.5975912213, green: 0.3411847949, blue: 0.7378113866, alpha: 1)
        case .J: return #colorLiteral(red: 0.3169852495, green: 0.3903964162, blue: 0.6502153277, alpha: 1)
        case .L: return #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
        case .O: return #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
        case .S: return #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
        case .Z: return #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
        case .T: return #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
        case .blank: return #colorLiteral(red: 0.1686089337, green: 0.1686392725, blue: 0.1686022878, alpha: 1)
        }
    }

    func pixelImage() -> UIImage {
        let pixelSize = CGSize(width: 1, height: 1)
        
        UIGraphicsBeginImageContext(pixelSize)
        defer { UIGraphicsEndImageContext() }

        color.setFill()
        UIGraphicsGetCurrentContext()!.fill(CGRect(origin: .zero, size: pixelSize))

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
