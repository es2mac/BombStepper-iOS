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
    fileprivate let tileWidth: CGFloat

    fileprivate let tileMapNode: SKTileMapNode
    fileprivate let cropNode: SKCropNode
    fileprivate let outerFrameNode: SKShapeNode
    fileprivate let innerFrameNode: SKShapeNode

    fileprivate let textureGenerationQueue = OperationQueue()
    fileprivate var blockTileGroupMap: BlockTileGroupMap = [:]

    fileprivate var ghostOpacity: CGFloat  = Alpha.ghostDefault

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        tileWidth = CGFloat((Int(sceneSize.height) - outerFrameWidth * 2)/20)
        (tileMapNode, innerFrameNode, outerFrameNode, cropNode) = PlayfieldNode.createNodes(tileWidth: tileWidth)

        super.init()

        cropNode.addChild(tileMapNode)
        [outerFrameNode, innerFrameNode, cropNode].forEach(addChild)

        let operation = GenerateTileSetOperation(tileWidth: tileWidth, ghostOpacity: ghostOpacity, doneTarget: self)
        textureGenerationQueue.addOperation(operation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fadeIn() {
        [outerFrameNode, innerFrameNode, tileMapNode].forEach { $0.alpha = 0 }
        self.alpha = 1
        tileMapNode.run(.fadeIn(withDuration: 1))
        innerFrameNode.run(.sequence([.wait(forDuration: 0.5), .fadeIn(withDuration: 1)]))
        outerFrameNode.run(.sequence([.wait(forDuration: 1), .fadeIn(withDuration: 1)])) {
            self.textureGenerationQueue.waitUntilAllOperationsAreFinished()
        }
    }

    func place(blocks: [Block], automapping: Bool = true)  {
        DispatchQueue.main.async { self.placeAsync(blocks: blocks) }
    }

    func clearField() { tileMapNode.fill(with: nil) }

}


extension PlayfieldNode: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        guard CGFloat(settings.ghostOpacity) != ghostOpacity, !blockTileGroupMap.isEmpty else { return }
        ghostOpacity = CGFloat(settings.ghostOpacity)
        let operation = UpdateGhostTexturesOperation(tileWidth: tileWidth, ghostOpacity: ghostOpacity, map: blockTileGroupMap)
        textureGenerationQueue.addOperation(operation)
    }
}


private extension PlayfieldNode {

    func placeAsync(blocks: [Block], automapping: Bool = true)  {

        if !automapping {
            // TODO: do a copy at top lines
            self.tileMapNode.enableAutomapping = false
            self.tileMapNode.enableAutomapping = true
        }
        
        blocks.forEach {
            
            // TODO: layer field on top of static background, blanks don't draw
            // TODO: setting for background gridline opacity
            
            if case .blank = $0.type {
                self.tileMapNode.setTileGroup(nil, forColumn: $0.x, row: $0.y)
            }
            else {
                self.tileMapNode.setTileGroup(self.tileGroup(for: $0.type), forColumn: $0.x, row: $0.y)
            }
        }
    }

    func tileGroup(for t: Block.BlockType) -> SKTileGroup {
        return blockTileGroupMap[t]!
    }

}


private extension PlayfieldNode {

    class func createNodes(tileWidth: CGFloat) -> (tileMap: SKTileMapNode, innerFrame: SKShapeNode, outerFrame: SKShapeNode, cropNode: SKCropNode) {

        // The tile map has 4 extra rows on top for auxiliary rendering, and is masked out.
        // Normal field update should happen in the lower 20 rows only.
        // Tile set is set after getting user settings back.
        let tileSize = CGSize(width: tileWidth, height: tileWidth)
        let tileMapNode = SKTileMapNode(tileSet: SKTileSet(tileGroups: []), columns: 10, rows: 24, tileSize: tileSize)
        tileMapNode.position.y = tileWidth * 2

        let fieldRect = CGRect(x: -tileWidth * 5, y: -tileWidth * 10,
                               width: tileWidth * 10, height: tileWidth * 20)
        let innerFrameRect = fieldRect.insetBy(dx: -CGFloat(innerFrameWidth), dy: -CGFloat(innerFrameWidth))
        let outerFrameRect = fieldRect.insetBy(dx: -CGFloat(outerFrameWidth), dy: -CGFloat(outerFrameWidth))

        let innerFrameNode = SKShapeNode(rect: innerFrameRect, cornerRadius: 2)
        innerFrameNode.fillColor = .playfieldBorder
        innerFrameNode.lineWidth = 0
        innerFrameNode.zPosition = ZPosition.playfieldInnerFrame

        let outerFrameNode = SKShapeNode(rect: outerFrameRect, cornerRadius: 4)
        outerFrameNode.fillColor = .playfieldOuterFrame
        outerFrameNode.lineWidth = 0
        outerFrameNode.zPosition = ZPosition.playfieldOuterFrame

        let maskNode = SKShapeNode(rect: fieldRect)
        maskNode.fillColor = #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1)
        maskNode.lineWidth = 0
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode

        return (tileMap: tileMapNode, innerFrame: innerFrameNode, outerFrame: outerFrameNode, cropNode: cropNode)
    }
}


private final class GenerateTileSetOperation: Operation {

    let tileWidth: CGFloat
    let ghostOpacity: CGFloat
    weak var target: PlayfieldNode?

    init(tileWidth: CGFloat, ghostOpacity: CGFloat, doneTarget target: PlayfieldNode) {
        self.tileWidth = tileWidth
        self.ghostOpacity = ghostOpacity
        self.target = target
        super.init()
    }

    override func main() {
        var map = BlockTileGroupMap()

        let allAdjacencies = allAdjacencyOptionSets()

        Block.BlockType.allCases.forEach { type in
            let rules: [SKTileGroupRule]
            switch type {
            case .blank:
                let image = type.defaultImage(side: tileWidth)
                let texture = SKTexture(image: image)
                let tileDefinition = SKTileDefinition(texture: texture)
                rules = [SKTileGroupRule(adjacency: [], tileDefinitions: [tileDefinition])]
            case .ghost:
                let image = type.ghostImage(side: tileWidth, alpha: ghostOpacity)
                let texture = SKTexture(image: image)
                let tileDefinition = SKTileDefinition(texture: texture)
                rules = [SKTileGroupRule(adjacency: [], tileDefinitions: [tileDefinition])]
            case .active, .locked:
                rules = allAdjacencies.map { adjacency in
                    let image = type.defaultImage(side: tileWidth, adjacency: adjacency)
                    let texture = SKTexture(image: image)
                    let definition = SKTileDefinition(texture: texture)
                    definition.userData = ["adjacency" : adjacency]

                    return SKTileGroupRule(adjacency: adjacency, tileDefinitions: [definition])
                }
            }
            let tileGroup = SKTileGroup(rules: rules)
            tileGroup.name = type.name
            map[type] = tileGroup
        }

        DispatchQueue.main.async {
            self.target?.blockTileGroupMap = map
            self.target?.tileMapNode.tileSet = SKTileSet(tileGroups: Array(map.values))
        }
    }
}


private final class UpdateGhostTexturesOperation: Operation {
    
    let tileWidth: CGFloat
    let ghostOpacity: CGFloat
    let map: BlockTileGroupMap
    
    init(tileWidth: CGFloat, ghostOpacity: CGFloat, map: BlockTileGroupMap) {
        self.tileWidth = tileWidth
        self.ghostOpacity = ghostOpacity
        self.map = map
        super.init()
    }
    
    override func main() {
        let textures = Tetromino.allCases.map(Block.BlockType.ghost).map {
            SKTexture(image: $0.ghostImage(side: tileWidth, alpha: ghostOpacity))
        }
        let definitions = Tetromino.allCases.map(Block.BlockType.ghost).map {
            map[$0]!.rules[0].tileDefinitions[0]
        }
        DispatchQueue.main.async {
            for (definition, texture) in zip(definitions, textures) {
                definition.textures = [texture]
            }
        }
    }
}


private func allAdjacencyOptionSets() -> [SKTileAdjacencyMask] {
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
}













