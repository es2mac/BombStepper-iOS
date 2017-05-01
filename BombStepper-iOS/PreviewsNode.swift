//
//  PreviewsNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/26/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


// Assume 5 previews for now
// WISHLIST: Adjustable number of previews

// Put each piece in a hypothetical 4x3, and shifted for type
final class PreviewsNode: SKNode {

    private var pieceNodes: [SinglePieceNode]
    private let tileWidth: CGFloat
    private var previousTypes: [Tetromino] = []

    init(tileWidth: CGFloat) {

        self.tileWidth = tileWidth

        let tileGroupMap = SinglePieceNode.generateTileGroupMap(tileWidth: tileWidth)
        self.pieceNodes = (0 ..< 5).map {
            let node = SinglePieceNode(tileWidth: tileWidth, blockTileGroupMap: tileGroupMap)
            node.position.y = (tileWidth * 3) * CGFloat(2 - $0)
            return node
        }
        
        super.init()
        
        pieceNodes.forEach(self.addChild)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ types: [Tetromino]) {

        let animate = typesAreAdvancedFromLastSet(types)
        let rotated = pieceNodes.removeFirst()
        pieceNodes.append(rotated)
        rotated.position = CGPoint(x: 0, y: (tileWidth * 3) * CGFloat(2 - types.count))
        rotated.shiftPositionForType(types.last!)
        rotated.removeAllActions()

        let animateDuration = animate ? 0.1 : 0
        if animate {
            rotated.alpha = 0
            rotated.run(.fadeIn(withDuration: animateDuration))
        }

        for (index, (node, type)) in zip(pieceNodes, types).enumerated() {
            node.show(type)

            var position = CGPoint(x: 0, y: (tileWidth * 3) * CGFloat(2 - index))

            switch type {
            case .I:
                position.y += tileWidth / 2
            case .O:
                break
            case .J, .L, .S, .T, .Z:
                position.x += tileWidth / 2
            }

            node.run(.move(to: position, duration: animateDuration))
        }
    }

    func typesAreAdvancedFromLastSet(_ types: [Tetromino]) -> Bool {
        defer { previousTypes = types }
        if types.count != previousTypes.count { return false }
        for (t1, t2) in zip(types.dropLast(), previousTypes.dropFirst()) {
            if t1 != t2 { return false }
        }
        return true
    }
}




