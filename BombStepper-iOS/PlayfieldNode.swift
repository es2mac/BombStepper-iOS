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


private typealias BlockTileGroupMap = [Block.BlockType : SKTileGroup]


final class PlayfieldNode: SKNode {

    let sceneSize: CGSize
    private let blockHeight: CGFloat

    private let tileMapNode: SKTileMapNode
    private let outerFrameNode: SKShapeNode
    private let innerFrameNode: SKShapeNode
    private let blockTileGroupMap: BlockTileGroupMap

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        blockHeight = CGFloat((Int(sceneSize.height) - outerFrameWidth * 2)/20)
        let fieldRect = CGRect(x: -blockHeight * 5, y: -blockHeight * 10,
                               width: blockHeight * 10, height: blockHeight * 20)
        let innerFrameRect = fieldRect.insetBy(dx: -CGFloat(innerFrameWidth), dy: -CGFloat(innerFrameWidth))
        let outerFrameRect = fieldRect.insetBy(dx: -CGFloat(outerFrameWidth), dy: -CGFloat(outerFrameWidth))

        innerFrameNode = SKShapeNode(rect: innerFrameRect, cornerRadius: 2)
        innerFrameNode.fillColor = .playfieldBorder
        innerFrameNode.lineWidth = 0
        innerFrameNode.zPosition = ZPosition.playfieldInnerFrame

        outerFrameNode = SKShapeNode(rect: outerFrameRect, cornerRadius: 4)
        outerFrameNode.fillColor = .playfieldOuterFrame
        outerFrameNode.lineWidth = 0
        outerFrameNode.zPosition = ZPosition.playfieldOuterFrame

        blockTileGroupMap = PlayfieldNode.makeTileGroupMap(tileWidth: CGFloat(blockHeight))

        let tileSet = SKTileSet(tileGroups: Array(blockTileGroupMap.values))
        let tileSize = CGSize(width: blockHeight, height: blockHeight)
        tileMapNode = SKTileMapNode(tileSet: tileSet, columns: 10, rows: 20, tileSize: tileSize, fillWith: blockTileGroupMap[.blank]!)

        super.init()

        [outerFrameNode, innerFrameNode, tileMapNode].forEach(addChild)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fadeIn() {
        [outerFrameNode, innerFrameNode, tileMapNode].forEach { $0.alpha = 0 }
        self.alpha = 1
        tileMapNode.run(.fadeIn(withDuration: 1))
        innerFrameNode.run(.sequence([.wait(forDuration: 0.5),
                                      .fadeIn(withDuration: 1)]))
        outerFrameNode.run(.sequence([.wait(forDuration: 1),
                                      .fadeIn(withDuration: 1)]))
    }

    func clearField() {
        tileMapNode.fill(with: tileGroup(for: .blank))
    }

    func place(blocks: [Block])  {
        DispatchQueue.main.async {
            blocks.forEach {
                self.tileMapNode.setTileGroup(self.tileGroup(for: $0.type), forColumn: $0.x, row: $0.y)
            }
        }
        
    }

    private func tileGroup(for t: Block.BlockType) -> SKTileGroup {
        return blockTileGroupMap[t]!
    }

}


private extension PlayfieldNode {

    class func makeTileGroupMap(tileWidth: CGFloat) -> BlockTileGroupMap {

        var map = BlockTileGroupMap()

        Block.BlockType.allCases.forEach { type in
            let image = type.squareImage(side: tileWidth)
            let texture = SKTexture(image: image)
            let tileDefinition = SKTileDefinition(texture: texture)
            let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
            map[type] = tileGroup
        }
        
        return map
    }

}













