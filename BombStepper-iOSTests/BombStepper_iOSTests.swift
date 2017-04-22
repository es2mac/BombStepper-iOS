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
        let piece = Piece(type: .T, x: 5, y: 8, orientation: .left)
        let leftRotatedPiece = Piece(type: .T, x: 5, y: 8, orientation: .down)
        XCTAssert(piece.rotatedLeft() == leftRotatedPiece)
    }
    
    func testRotatedRight() {
        let piece = Piece(type: .T, x: 5, y: 8, orientation: .up)
        let rightRotatedPiece = Piece(type: .T, x: 5, y: 8, orientation: .right)
        XCTAssert(piece.rotatedRight() == rightRotatedPiece)
    }

    func testKickStates() {
        let piece = Piece(type: .T, x: 3, y: 3, orientation: .right)
        let states = [piece,
                      Piece(type: .T, x: 4, y: 3, orientation: .right),
                      Piece(type: .T, x: 4, y: 2, orientation: .right),
                      Piece(type: .T, x: 3, y: 5, orientation: .right),
                      Piece(type: .T, x: 4, y: 5, orientation: .right)]

        var count = 0
        for (i, p) in piece.type.offsets(for: piece.orientation).enumerated() {
            count += 1
            XCTAssertEqual(piece.offsetBy(p), states[i])
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

