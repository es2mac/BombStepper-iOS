//
//  PlayfieldNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/21/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


private let outerFrameWidth = 4
private let innerFrameWidth = 1


final class PlayfieldNode: SKNode {

    let sceneSize: CGSize

    let tileMapNode: SKTileMapNode
    private let outerFrameNode: SKShapeNode
    private let innerFrameNode: SKShapeNode

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        let blockHeight = CGFloat((Int(sceneSize.height) - outerFrameWidth * 2)/20)
        let fieldRect = CGRect(x: -blockHeight * 5, y: -blockHeight * 10,
                               width: blockHeight * 10, height: blockHeight * 20)
        let innerFrameRect = fieldRect.insetBy(dx: -CGFloat(innerFrameWidth), dy: -CGFloat(innerFrameWidth))
        let outerFrameRect = fieldRect.insetBy(dx: -CGFloat(outerFrameWidth), dy: -CGFloat(outerFrameWidth))

        innerFrameNode = SKShapeNode(rect: innerFrameRect, cornerRadius: 2)
        innerFrameNode.fillColor = .playfieldBorder
        innerFrameNode.lineWidth = 0
        innerFrameNode.zPosition = -1

        outerFrameNode = SKShapeNode(rect: outerFrameRect, cornerRadius: 4)
        outerFrameNode.fillColor = .playfieldOuterFrame
        outerFrameNode.lineWidth = 0
        outerFrameNode.zPosition = -2

        tileMapNode = PlayfieldNode.makeTileMapNode(tileWidth: CGFloat(blockHeight))

        super.init()

        [outerFrameNode, innerFrameNode, tileMapNode].forEach(addChild)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


private extension PlayfieldNode {
    
    class func makeTileMapNode(tileWidth: CGFloat) -> SKTileMapNode {

        // TODO: extract tile groups to be referred to when changing tiles

        // [.I, .J, .L, .O, .S, .Z, .T, .blank]
        let tileGroups = Tetromino.allCases
            .map { $0.minoImage(side: tileWidth) }    // add border
            .map(SKTexture.init)
            .map(SKTileDefinition.init)
            .map(SKTileGroup.init)

        for (group, name) in zip(tileGroups, ["I", "J", "L", "O", "S", "Z", "T", "blank"]) {
            group.name = name
        }

        let tileSet = SKTileSet(tileGroups: tileGroups)
        let tileSize = CGSize(width: tileWidth, height: tileWidth)
        let tileMapNode = SKTileMapNode(tileSet: tileSet, columns: 10, rows: 20, tileSize: tileSize, fillWith: tileGroups.last!)

        return tileMapNode
    }

}













