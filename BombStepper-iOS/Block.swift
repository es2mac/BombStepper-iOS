//
//  Block.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


typealias Offset = (x: Int, y: Int)


/**
 A block is a single square on the playing field.  It has a position and knows
 how to it is displayed.
 */
struct Block {

    enum BlockType {
        case blank
        case tetromino(Tetromino)

        // TODO: Separate types with different drawing methods
//        case ghost, active, locked
    }

    let type: BlockType
    var x: Int
    var y: Int
}


/// Allow BlockType to be used as keys in a SKTileGroup lookup table
extension Block.BlockType: Hashable, Equatable {
    var hashValue: Int {
        switch self {
        case .blank:
            return 0
        case .tetromino(let t):
            return 1 + t.rawValue
        }
    }

    public static func ==(lhs: Block.BlockType, rhs: Block.BlockType) -> Bool {
        switch (lhs, rhs) {
        case (.blank, blank): return true
        case (.tetromino(let t1), .tetromino(let t2)): return t1 == t2
        default:
            return false
        }
    }
}


extension Block.BlockType {

    /// This gives an image to be used on the playfield.  It's a rounded rect
    /// that's offset by 1 point from each edge, giving it a border
    func squareImage(side: CGFloat) -> UIImage {
        switch self {
        case .blank:
            return borderedSquare(side: side,
                                  color: .blankTile,
                                  edgeColor: .playfieldBorder)
        case .tetromino(let t):
            return borderedSquare(side: side,
                                  color: t.color,
                                  edgeColor: t.edgeColor)
        }
    }

    private func borderedSquare(side: CGFloat, color: UIColor, edgeColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: side, height: side)

        //    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:0.18];

        UIGraphicsBeginImageContextWithOptions(rect.size, true, UIScreen.main.scale)
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





