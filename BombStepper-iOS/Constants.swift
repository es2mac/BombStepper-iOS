//
//  Constants.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


extension UIColor {
    static let tileT = #colorLiteral(red: 0.5975912213, green: 0.3411847949, blue: 0.7378113866, alpha: 1)
    static let tileJ = #colorLiteral(red: 0.3169852495, green: 0.3903964162, blue: 0.6502153277, alpha: 1)
    static let tileZ = #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)
    static let tileS = #colorLiteral(red: 0.262835294, green: 0.8022480607, blue: 0.3886030316, alpha: 1)
    static let tileO = #colorLiteral(red: 0.9925034642, green: 0.8121734858, blue: 0, alpha: 1)
    static let tileI = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
    static let tileL = #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
    static let playfieldOuterFrame = #colorLiteral(red: 0.7242990732, green: 0.7850584388, blue: 0.9598841071, alpha: 1)
    static let playfieldBorder = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    static let lightFlatBlack = #colorLiteral(red: 0.1686089337, green: 0.1686392725, blue: 0.1686022878, alpha: 1)
}


enum Dimension {
    static let outerFrameWidth = 4
    static let innerFrameWidth = 1
}


enum ZPosition {
    static let gameModeOverlay: CGFloat = 20
    static let controls: CGFloat = 10
    static let playfieldGrids: CGFloat = -1
    static let playfieldInnerFrame: CGFloat = -2
    static let playfieldOuterFrame: CGFloat = -3
}


// WISHLIST: Optionize all the things?
enum Alpha {
    static let pressedButton: CGFloat = 0.15
    static let releasedButton: CGFloat = 0.04
    static let maxButtonWarning: CGFloat = 0.2
    static let ghostDefault: CGFloat = 0.25
}


enum Timing {
    static let lockDelay: TimeInterval = 0.5
    static let lockDelayExtension: TimeInterval = 4.0
    static let buttonFlipDownDuration: TimeInterval = 0
    static let buttonFlipUpDuration: TimeInterval = 0.1
}


enum DirectoryName {
    static let buttonLayouts = "ButtonLayouts"
}



