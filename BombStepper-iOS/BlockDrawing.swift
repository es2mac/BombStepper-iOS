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
            return UIImage.borderedSquare(side: side, color: .lightFlatBlack, edgeColor: .playfieldBorder)
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






