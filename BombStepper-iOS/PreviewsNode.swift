//
//  PreviewsNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/26/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


// Assume 5 previews for now
// TODO: Adjustable number of previews

// Put each piece in a hypothetical 4x3, and shifted for type
final class PreviewsNode: SKNode {

    private let pieceNodes: [SinglePieceNode]
    private let tileWidth: CGFloat

    init(tileWidth: CGFloat) {

        self.tileWidth = tileWidth

        let tileGroupMap = SinglePieceNode.generateTileGroupMap(tileWidth: tileWidth)
        self.pieceNodes = (0 ..< 5).map {
            let node = SinglePieceNode(tileWidth: tileWidth, blockTileGroupMap: tileGroupMap)
            node.position.y = (tileWidth * 3) * CGFloat(2 - $0)
            return node
        }
        
        super.init()
        
        pieceNodes.forEach(addChild)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ types: [Tetromino]) {
        for (index, (node, type)) in zip(pieceNodes, types).enumerated() {

            node.show(type)

            var x = CGFloat(0)
            var y = (tileWidth * 3) * CGFloat(2 - index)

            switch type {
            case .I:
                y += tileWidth / 2
            case .O:
                break
            case .J, .L, .S, .T, .Z:
                x = tileWidth / 2
            }
            node.position = CGPoint(x: x, y: y)
        }
    }
}




