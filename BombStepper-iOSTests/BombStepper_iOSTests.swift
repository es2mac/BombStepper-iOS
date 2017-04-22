//
//  BombStepper_iOSTests.swift
//  BombStepper-iOSTests
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import XCTest
@testable import BombStepper

class FieldModelPieceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRotatedLeft() {
        let piece = FieldModel.Piece(type: .T, x: 5, y: 8, orientation: .left)
        let leftRotatedPiece = FieldModel.Piece(type: .T, x: 5, y: 8, orientation: .down)
        XCTAssert(piece.rotatedLeft() == leftRotatedPiece)
    }
    
    func testRotatedRight() {
        let piece = FieldModel.Piece(type: .T, x: 5, y: 8, orientation: .up)
        let rightRotatedPiece = FieldModel.Piece(type: .T, x: 5, y: 8, orientation: .right)
        XCTAssert(piece.rotatedRight() == rightRotatedPiece)
    }

    func testKickStates() {
        let piece = FieldModel.Piece(type: .T, x: 3, y: 3, orientation: .right)
        let states = [piece,
                      FieldModel.Piece(type: .T, x: 4, y: 3, orientation: .right),
                      FieldModel.Piece(type: .T, x: 4, y: 2, orientation: .right),
                      FieldModel.Piece(type: .T, x: 3, y: 5, orientation: .right),
                      FieldModel.Piece(type: .T, x: 4, y: 5, orientation: .right)]

        var count = 0
        for (i, p) in piece.kickStates.enumerated() {
            count += 1
            XCTAssertEqual(p, states[i])
        }

        XCTAssertEqual(count, 5)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

extension FieldModel.Piece: Equatable {
    static public func ==(lhs: FieldModel.Piece, rhs: FieldModel.Piece) -> Bool {
        if lhs.type == rhs.type,
            lhs.x == rhs.x,
            lhs.y == rhs.y,
            lhs.orientation == rhs.orientation { return true }
        else { return false }
    }
}
