//
//  ButtonConfiguration.swift
//  ButtonCreator
//
//  Created by Paul on 5/1/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


// Configuration data for a single button
struct ButtonConfiguration {

    var type: ButtonType

    var x: CGFloat
    var y: CGFloat

    var position: CGPoint {
        get {
            return CGPoint(x: x, y: y)
        }
        set {
            x = newValue.x
            y = newValue.y
        }
    }

    var width: CGFloat {
        didSet {
            width.round()
            if corner > width / 2 {
                corner = (width / 2).rounded(.down)
            }
        }
    }

    var height: CGFloat {
        didSet {
            height.round()
            if corner > height / 2 {
                corner = (height / 2).rounded(.down)
            }
        }
    }

    var size: CGSize {
        get {
            return CGSize(width: width, height: height)
        }
        set {
            width = size.width
            height = size.height
        }
    }

    var corner: CGFloat {
        didSet {
            corner.round()
            if corner > width / 2 {
                width = corner * 2
            }
            if corner > height / 2 {
                height = corner * 2
            }
        }
    }

    var tilt: CGFloat {
        didSet {
            tilt.round()
        }
    }

    var swipeDistance: CGFloat {
        didSet {
            swipeDistance.round()
        }
    }

    var swipeAxisTilt: CGFloat {
        didSet {
            swipeAxisTilt.round()
        }
    }

    var leftRightSwipeEnabled: Bool {
        didSet {
            if !leftRightSwipeEnabled, comboSwipeEnabled {
                comboSwipeEnabled = false
            }
        }
    }
    var downSwipeEnabled: Bool

    var comboSwipeEnabled: Bool {
        didSet {
            if comboSwipeEnabled, !leftRightSwipeEnabled {
                leftRightSwipeEnabled = true
            }
        }
    }
    
    var upSwipeEnabled: Bool
}


extension ButtonConfiguration {

    static let standard = ButtonConfiguration(type: .moveLeft,
                                              x: 0,
                                              y: 0,
                                              width: 100,
                                              height: 100,
                                              corner: 4,
                                              tilt: 0,
                                              swipeDistance: 50,
                                              swipeAxisTilt: 0,
                                              leftRightSwipeEnabled: true,
                                              downSwipeEnabled: true,
                                              comboSwipeEnabled: true,
                                              upSwipeEnabled: true)

}


extension ButtonConfiguration {

    private enum Keys: String {
        case type, x, y, width, height, corner, tilt, swipeDistance, swipeAxisTilt, leftRightSwipeEnabled, downSwipeEnabled, comboSwipeEnabled, upSwipeEnabled
    }

    func encodeAsDictionary() -> [String : Any] {
        return [ Keys.type.rawValue : type.rawValue,
                 Keys.x.rawValue : x,
                 Keys.y.rawValue : y,
                 Keys.width.rawValue : width,
                 Keys.height.rawValue : height,
                 Keys.corner.rawValue : corner,
                 Keys.tilt.rawValue : tilt,
                 Keys.swipeDistance.rawValue : swipeDistance,
                 Keys.swipeAxisTilt.rawValue : swipeAxisTilt,
                 Keys.leftRightSwipeEnabled.rawValue : leftRightSwipeEnabled,
                 Keys.downSwipeEnabled.rawValue : downSwipeEnabled,
                 Keys.comboSwipeEnabled.rawValue : comboSwipeEnabled,
                 Keys.upSwipeEnabled.rawValue : upSwipeEnabled ]
    }

    init?(dictionary: [String : Any]) {
        guard let typeString = dictionary[Keys.type.rawValue] as? String,
            let type = ButtonType(rawValue: typeString),
            let x = dictionary[Keys.x.rawValue] as? CGFloat,
            let y = dictionary[Keys.y.rawValue] as? CGFloat,
            let width = dictionary[Keys.width.rawValue] as? CGFloat,
            let height = dictionary[Keys.height.rawValue] as? CGFloat,
            let corner = dictionary[Keys.corner.rawValue] as? CGFloat,
            let tilt = dictionary[Keys.tilt.rawValue] as? CGFloat,
            let swipeDistance = dictionary[Keys.swipeDistance.rawValue] as? CGFloat,
            let swipeAxisTilt = dictionary[Keys.swipeAxisTilt.rawValue] as? CGFloat,
            let leftRightSwipeEnabled = dictionary[Keys.leftRightSwipeEnabled.rawValue] as? Bool,
            let downSwipeEnabled = dictionary[Keys.downSwipeEnabled.rawValue] as? Bool,
            let comboSwipeEnabled = dictionary[Keys.comboSwipeEnabled.rawValue] as? Bool,
            let upSwipeEnabled = dictionary[Keys.upSwipeEnabled.rawValue] as? Bool else { return nil }

        self.type = type
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.corner = corner
        self.tilt = tilt
        self.swipeDistance = swipeDistance
        self.swipeAxisTilt = swipeAxisTilt
        self.leftRightSwipeEnabled = leftRightSwipeEnabled
        self.downSwipeEnabled = downSwipeEnabled
        self.comboSwipeEnabled = comboSwipeEnabled
        self.upSwipeEnabled = upSwipeEnabled
    }
    
}

extension ButtonConfiguration: Hashable {
    
    static func ==(lhs: ButtonConfiguration, rhs: ButtonConfiguration) -> Bool {
        return lhs.type                  == rhs.type &&
               lhs.x                     == rhs.x &&
               lhs.y                     == rhs.y &&
               lhs.width                 == rhs.width &&
               lhs.height                == rhs.height &&
               lhs.corner                == rhs.corner &&
               lhs.tilt                  == rhs.tilt &&
               lhs.swipeDistance         == rhs.swipeDistance &&
               lhs.swipeAxisTilt         == rhs.swipeAxisTilt &&
               lhs.leftRightSwipeEnabled == rhs.leftRightSwipeEnabled &&
               lhs.downSwipeEnabled      == rhs.downSwipeEnabled &&
               lhs.comboSwipeEnabled     == rhs.comboSwipeEnabled &&
               lhs.upSwipeEnabled        == rhs.upSwipeEnabled
    }

    var hashValue: Int {
        return Int(x * 1000 + y)
    }
}


