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
        case active(Tetromino)
        case ghost(Tetromino)
        case locked(Tetromino)
        // case bomb
    }

    let type: BlockType
    var x: Int
    var y: Int
}


extension Block.BlockType {
    static var allCases: [Block.BlockType] {
        return [.blank]
            + Tetromino.allCases.map { Block.BlockType.active($0) }
            + Tetromino.allCases.map { Block.BlockType.ghost($0) }
            + Tetromino.allCases.map { Block.BlockType.locked($0) }
    }
}


/// Allow BlockType to be used as keys in a SKTileGroup lookup table
extension Block.BlockType: Hashable, Equatable {
    var hashValue: Int {
        switch self {
        case .blank:
            return 0
        case .active(let t):
            return 1 + 1 * 7 + t.rawValue
        case .ghost(let t):
            return 1 + 2 * 7 + t.rawValue
        case .locked(let t):
            return 1 + 3 * 7 + t.rawValue
        }
    }

    public static func ==(lhs: Block.BlockType, rhs: Block.BlockType) -> Bool {
        switch (lhs, rhs) {
        case (.blank, blank): return true
        case (.active(let t1), .active(let t2)),
             (.ghost(let t1),  .ghost(let t2)),
             (.locked(let t1), .locked(let t2)):
            return t1 == t2
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
        case .active(let t),
             .locked(let t):
            return borderedSquare(side: side,
                                  color: t.color,
                                  edgeColor: t.edgeColor)
        case .ghost(let t):
            return borderedSquare(side: side,
                                  color: t.color.withAlphaComponent(0.5),
                                  edgeColor: t.edgeColor.withAlphaComponent(0.5))
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





