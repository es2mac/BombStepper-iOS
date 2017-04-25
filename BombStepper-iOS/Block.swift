//
//  Block.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit
import SpriteKit


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


extension Block.BlockType {

    /// This gives an image to be used on the playfield.  It's a rounded rect
    /// that's offset by 1 point from each edge, giving it a border.
    ///
    func defaultImage(side: CGFloat, adjacency: SKTileAdjacencyMask = []) -> UIImage {
        switch self {
        case .blank:
            return UIImage.borderedSquare(side: side, color: .blankTile, edgeColor: .playfieldBorder)
        case .active(let t), .locked(let t):
            return UIImage.borderedSquare(side: side, color: t.color, edgeColor: t.edgeColor, adjacency: adjacency)
        case .ghost:
            assertionFailure("You should use ghostImage() with user-specified alpha")
            return ghostImage(side: side, alpha: Alpha.ghostDefault, adjacency: adjacency)
        }
    }

    /// Specialized drawing for ghost pieces.  If self is not a ghost piece,
    /// you get a black image.
    func ghostImage(side: CGFloat, alpha: CGFloat, adjacency: SKTileAdjacencyMask = []) -> UIImage {
        guard case .ghost(let t) = self else {
            return UIImage.borderedSquare(side: side, color: .black, edgeColor: .black, adjacency: adjacency)
        }
        guard alpha > 0.05 else { return Block.BlockType.blank.defaultImage(side: side) }
        let blankImage = Block.BlockType.blank.defaultImage(side: side)
        let activeImage = Block.BlockType.active(t).defaultImage(side: side, adjacency: adjacency)
        return activeImage.layeredOnTop(of: blankImage, alpha: alpha)
    }

}


private extension UIImage {

    static func borderedSquare(side: CGFloat, color: UIColor, edgeColor: UIColor, adjacency: SKTileAdjacencyMask = []) -> UIImage {

        let drawSize = CGSize(width: side, height: side)

        UIGraphicsBeginImageContextWithOptions(drawSize, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        // Fill background with background edge color first
        let fullRect = CGRect(origin: .zero, size: drawSize)
        UIColor.playfieldBorder.setFill()
        context.fill(fullRect)

        // Fill background with edge color
        context.addPath(UIBezierPath(roundedRect: fullRect, cornerRadius: 2).cgPath)
        edgeColor.setFill()
        context.fillPath()
        
        // Appropriately inset & round corners to draw the main color
        var inset: (up: CGFloat, down: CGFloat, left: CGFloat, right: CGFloat) = (0, 0, 0, 0)
        
        if !adjacency.contains(.adjacencyUp)    { inset.up = 1 }
        if !adjacency.contains(.adjacencyDown)  { inset.down = 1 }
        if !adjacency.contains(.adjacencyLeft)  { inset.left = 1 }
        if !adjacency.contains(.adjacencyRight) { inset.right = 1 }

        /*
        let corners: UIRectCorner = []
        switch (adjacency.contains(.adjacencyUp), adjacency.contains(.adjacencyRight),
                adjacency.contains(.adjacencyDown), adjacency.contains(.adjacencyLeft)) {
        //      Top  Right   Down   Left
        case (false, false,     _,     _): corners.insert(.topRight)
        case (    _, false, false,     _): corners.insert(.bottomRight)
        case (    _,     _, false, false): corners.insert(.bottomLeft)
        case (false,     _,     _, false): corners.insert(.topLeft)
        default: break
        }
        let roundedRect = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 2, height: 2))
         */

        let rect = CGRect(x: inset.left,
                          y: inset.up,
                          width: side - inset.left - inset.right,
                          height: side - inset.up - inset.down)
        
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 2)

        context.addPath(roundedRect.cgPath)
        color.setFill()
        context.fillPath()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func layeredOnTop(of image: UIImage, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: rect)
        self.draw(in: rect, blendMode: .normal, alpha: alpha)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}






