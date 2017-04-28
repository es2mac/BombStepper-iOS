//
//  FieldManipulator.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/28/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/**
 A field manipulator handles the logic of how the playing piece behave on the
 field. It operates and reports on field changes.  For soft drop lock timing,
 call update for each scene tick.
 */
final class FieldManipulator {

    weak var delegate: FieldManipulatorDelegate?

    fileprivate let field: Field
    fileprivate var hideGhost = false

    // Put most operations on a serial queue to make access on the two properties above atomic
    fileprivate let queue = DispatchQueue(label: "net.mathemusician.BombStepper.Field")

    var activePiece: Piece? { return field.activePiece }

    init(field: Field) {
        self.field = field
    }

}


extension FieldManipulator {
    func startPiece(type: Tetromino) -> Bool { return field.startPiece(type: type) }
    func movePiece(_ direction: Direction, steps: Int = 1) { field.movePiece(direction, steps: steps) }
    func replacePieceWithFirstValidPiece(in candidates: [Piece]) { field.replacePieceWithFirstValidPiece(in: candidates) }
    func clearActivePiece() { field.clearActivePiece() }
    func hardDrop() { field.hardDrop() }
    func reset() { field.reset() }
}


extension FieldManipulator: SettingsNotificationTarget {
    func settingsDidUpdate(_ settings: SettingsManager) {
        hideGhost = settings.hideGhost
    }
}


private extension FieldManipulator {
    
}


private extension FieldManipulator {
    
}






