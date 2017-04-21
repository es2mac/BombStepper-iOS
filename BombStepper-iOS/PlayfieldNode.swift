//
//  PlayfieldNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/21/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


typealias BlockPlacement = (tetromino: Tetromino, column: Int, row: Int)


private let outerFrameWidth = 4
private let innerFrameWidth = 1


final class PlayfieldNode: SKNode {

    let sceneSize: CGSize

    private let tileMapNode: SKTileMapNode
    private let outerFrameNode: SKShapeNode
    private let innerFrameNode: SKShapeNode
    private let tetrominoTileGroupMap: [Tetromino : SKTileGroup]

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

        tetrominoTileGroupMap = PlayfieldNode.makeTileGroupMap(tileWidth: CGFloat(blockHeight))

        let tileSet = SKTileSet(tileGroups: Array(tetrominoTileGroupMap.values))
        let tileSize = CGSize(width: blockHeight, height: blockHeight)
        tileMapNode = SKTileMapNode(tileSet: tileSet, columns: 10, rows: 20, tileSize: tileSize, fillWith: tetrominoTileGroupMap[.blank]!)

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

    func update(placements: [BlockPlacement])  {
        DispatchQueue.main.async {
            placements.forEach {
                self.tileMapNode.setTileGroup(self.tileGroup(for: $0.tetromino), forColumn: $0.column, row: $0.row)
            }
        }
        
    }

    private func tileGroup(for t: Tetromino) -> SKTileGroup {
        return tetrominoTileGroupMap[t]!
    }

}


private extension PlayfieldNode {

    class func makeTileGroupMap(tileWidth: CGFloat) -> [Tetromino : SKTileGroup] {

        var map = [Tetromino : SKTileGroup]()
        
        for (tetromino, name) in zip(Tetromino.allCases, ["blank", "I", "J", "L", "O", "S", "T", "Z"]) {
            let image = tetromino.minoImage(side: tileWidth)
            let texture = SKTexture(image: image)
            let tileDefinition = SKTileDefinition(texture: texture)
            let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
            tileGroup.name = name
            map[tetromino] = tileGroup
        }

        return map
    }

}













