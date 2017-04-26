//
//  HeldPieceNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/26/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


class HeldPieceNode: SKNode {

    fileprivate let pieceNode: SinglePieceNode

    init(tileWidth: CGFloat) {
        pieceNode = SinglePieceNode(tileWidth: tileWidth)
        super.init()
        addChild(pieceNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ tetromino: Tetromino?) {
        pieceNode.show(tetromino)
        pieceNode.position = .zero
        if let tetromino = tetromino {
            pieceNode.shiftPositionForType(tetromino)
        }
    }

}



