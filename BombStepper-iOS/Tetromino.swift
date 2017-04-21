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
        case .I: return #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
        case .J: return #colorLiteral(red: 0.3169852495, green: 0.3903964162, blue: 0.6502153277, alpha: 1)
        case .L: return #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
        case .O: return #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
        case .S: return #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
        case .Z: return #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
        case .T: return #colorLiteral(red: 0.5975912213, green: 0.3411847949, blue: 0.7378113866, alpha: 1)
        case .blank: return #colorLiteral(red: 0.1686089337, green: 0.1686392725, blue: 0.1686022878, alpha: 1)
        }
    }

    var edgeColor: UIColor {
        return .playfieldBorder

        // TODO: For each color, pick a darker edge color
        // Except blank, that uses playfieldBorder
        
//        switch self {
//        case .I: return #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
//        case .J: return #colorLiteral(red: 0.3169852495, green: 0.3903964162, blue: 0.6502153277, alpha: 1)
//        case .L: return #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
//        case .O: return #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
//        case .S: return #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
//        case .Z: return #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
//        case .T: return #colorLiteral(red: 0.5975912213, green: 0.3411847949, blue: 0.7378113866, alpha: 1)
//        case .blank: return #colorLiteral(red: 0.1686089337, green: 0.1686392725, blue: 0.1686022878, alpha: 1)
//        }
    }

    static let allCases: [Tetromino] = [.I, .J, .L, .O, .S, .Z, .T, .blank]

}


extension Tetromino {

    /// This gives an image to be used on the playfield.  It's a rounded rect
    /// that's offset by 1 point on the top and right edge, giving it a border
    func minoImage(side: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: side, height: side)

        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        edgeColor.setFill()
        context.fill(rect)

        let roundedRect = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 2)
        color.setFill()
        context.addPath(roundedRect.cgPath)
        context.fillPath()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
