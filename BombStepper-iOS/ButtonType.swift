//
//  ButtonType.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/16/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import Foundation


enum ButtonType: String {

    case moveLeft
    case moveRight
    case rotateLeft
    case rotateRight
    case hardDrop
    case softDrop
    case hold
    case none

    var displayText: String {
        switch self {
        case .moveLeft:    return "Move Left"
        case .moveRight:   return "Move Right"
        case .rotateLeft:  return "Rotate Left"
        case .rotateRight: return "Rotate Right"
        case .hardDrop:    return "Hard Drop"
        case .softDrop:    return "Soft Drop"
        case .hold:        return "Hold"
        case .none:        return "None"
        }
    }

    static var allTypes: [ButtonType] = [ .moveLeft, .moveRight, .hardDrop, .softDrop, .hold, .rotateLeft, .rotateRight, .none ]
}


