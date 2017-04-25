//
//  BlockDrawing.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/25/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


private let allAdjacencyOptionSets: [SKTileAdjacencyMask] = {
    let none: SKTileAdjacencyMask = []
    var sets = [none]
    for adjacency in [SKTileAdjacencyMask.adjacencyUp, .adjacencyDown, .adjacencyLeft, .adjacencyRight] {
        sets = sets + sets.map {
            var new = $0
            new.insert(adjacency)
            return new
        }
    }
    return sets
}()


extension Block.BlockType {
    
    func tileGroup(tileWidth: CGFloat, ghostOpacity: CGFloat = 0.25) -> SKTileGroup {
        
        let rules: [SKTileGroupRule]

        switch self {
        case .blank:
            let tileDefinition = SKTileDefinition(texture: texture(tileWidth: tileWidth))
            rules = [SKTileGroupRule(adjacency: [], tileDefinitions: [tileDefinition])]
        case .ghost:
            let tileDefinition = SKTileDefinition(texture: texture(tileWidth: tileWidth, ghostOpacity: ghostOpacity))
            rules = [SKTileGroupRule(adjacency: [], tileDefinitions: [tileDefinition])]
        case .active, .locked:
            rules = allAdjacencyOptionSets.map { adjacency in
                let definition = SKTileDefinition(texture: texture(tileWidth: tileWidth, adjacency: adjacency))
                definition.userData = ["adjacency" : adjacency]
                return SKTileGroupRule(adjacency: adjacency, tileDefinitions: [definition])
            }
        }
        let group = SKTileGroup(rules: rules)
        group.name = name
        return group
    }
    
    func texture(tileWidth: CGFloat, ghostOpacity: CGFloat = 0.25, adjacency: SKTileAdjacencyMask = []) -> SKTexture {
        switch self {
        case .blank, .active, .locked:
            return SKTexture(image: defaultImage(side: tileWidth, adjacency: adjacency))
        case .ghost:
            return SKTexture(image: ghostImage(side: tileWidth, alpha: ghostOpacity))
        }
    }
}


extension Block.BlockType {

    /// This gives an image to be used on the playfield.  It's a rounded rect
    /// that's offset by 1 point from each edge, giving it a border.
    /// Ghost piece should use ghostImage() with specified alpha instead.
    func defaultImage(side: CGFloat, adjacency: SKTileAdjacencyMask = []) -> UIImage {
        switch self {
        case .blank:
            return UIImage.borderedSquare(side: side, color: .blankTile, edgeColor: .playfieldBorder)
        case .active(let t), .locked(let t):
            return UIImage.borderedSquare(side: side, color: t.color, edgeColor: t.edgeColor, adjacency: adjacency)
        case .ghost:
            assertionFailure("Use ghostImage() with specified alpha")
            return UIImage.borderedSquare(side: side, color: .black, edgeColor: .black)
        }
    }

    /// Specialized drawing for ghost pieces.  Non-ghost pieces should not use this.
    func ghostImage(side: CGFloat, alpha: CGFloat, adjacency: SKTileAdjacencyMask = []) -> UIImage {
        guard case .ghost(let t) = self else {
            assertionFailure("Use defaultImage()")
            return UIImage.borderedSquare(side: side, color: .black, edgeColor: .black)
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
         // Note: This style has a tiny issue with "inner corner" pieces
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




