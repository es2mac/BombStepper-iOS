//
//  FieldManipulatorDelegate.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/28/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


/// FieldManipulator does work on a separate queue, so delegate might want to dispatch back to main
protocol FieldManipulatorDelegate: class {

    func updateField(blocks: [Block])
    func activePieceDidLock()
    func fieldDidTopOut()
    func activePieceLandingStatusChanged(landed: FieldManipulator.PieceLandingStatus)

    // Assume "covered T corners count" > 0 only for T-clears
    func linesCleared(_ count: Int, coveredTCornersCount: Int, isImmobile: Bool)
}


extension FieldManipulatorDelegate {
    func linesCleared(_ count: Int) {
        linesCleared(count, coveredTCornersCount: 0, isImmobile: false)
    }
}


