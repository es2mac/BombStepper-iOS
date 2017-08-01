//
//  ButtonLayoutPresets.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/23/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit
import simd


extension ButtonLayoutProfile {
    
    static func presetLayout1(name: String = "Default") -> ButtonLayoutProfile {
        var profile = ButtonLayoutProfile(name: name)

        let halfWidth: Double = 60
        let height: Double = 90

        let screenSize = { () -> double2 in 
            let size = UIScreen.main.bounds.size
            return double2(Double(size.width), Double(size.height))
        }()

        let tiltAngle = Double.pi * 22 / 180
        let tiltRotation = double2x2( [ double2(cos(tiltAngle), -sin(tiltAngle)),
                                        double2(sin(tiltAngle),  cos(tiltAngle)) ])
        
        let right = tiltRotation * double2(halfWidth + 0.5, 0)
        let up = tiltRotation * double2(0, height + 1)

        let prototype = ButtonConfiguration(type: .none,
                                            x: 0,
                                            y: 0,
                                            width: CGFloat(halfWidth * 2),
                                            height: CGFloat(height),
                                            corner: 20,
                                            tilt: 0,
                                            swipeDistance: 50,
                                            swipeAxisTilt: 0,
                                            leftRightSwipeEnabled: true,
                                            downSwipeEnabled: true,
                                            comboSwipeEnabled: true,
                                            upSwipeEnabled: true)

        // Soft Drop
        // Start by putting soft drop at (90, 50) from left bottom corner
        let softDropPosition = -(screenSize * 0.5) + double2(90, 50)
        let softDropButton = { () -> ButtonConfiguration in 
            var button = prototype
            button.type = .softDrop
            button.position = softDropPosition.toPoint
            button.tilt = -22
            button.swipeAxisTilt = -12
            return button
        }()

        // Move Right
        let moveRightPosition = softDropPosition + right + up
        let moveRightButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .moveRight
            button.position = moveRightPosition.toPoint
            button.tilt = -22
            button.swipeAxisTilt = -12
            return button
        }()

        // Move Left
        let moveLeftPosition = moveRightPosition - (2 * right)
        let moveLeftButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .moveLeft
            button.position = moveLeftPosition.toPoint
            button.tilt = -22
            button.swipeAxisTilt = -12
            return button
        }()

        // Hard Drop
        let hardDropPosition = softDropPosition + (2 * up)
        let hardDropButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .hardDrop
            button.position = hardDropPosition.toPoint
            button.tilt = -22
            button.swipeAxisTilt = -12
            button.leftRightSwipeEnabled = false
            button.downSwipeEnabled = false
            button.comboSwipeEnabled = false
            button.upSwipeEnabled = false
            return button
        }()

        // Rotate Left
        let rotateLeftPosition = moveRightPosition * double2(-1, 1) - double2(0, 30)
        let rotateLeftButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .rotateLeft
            button.position = rotateLeftPosition.toPoint
            button.tilt = 22
            button.swipeAxisTilt = 12
            return button
        }()

        // Rotate Right
        let rotateRightPosition = moveLeftPosition * double2(-1, 1) - double2(0, 30)
        let rotateRightButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .rotateRight
            button.position = rotateRightPosition.toPoint
            button.tilt = 22
            button.swipeAxisTilt = 12
            return button
        }()

        // Hold
        let holdPosition = hardDropPosition * double2(-1, 1) - double2(0, 30)
        let holdButton = { () -> ButtonConfiguration in
            var button = prototype
            button.type = .hold
            button.position = holdPosition.toPoint
            button.tilt = 22
            button.swipeAxisTilt = 12
            button.leftRightSwipeEnabled = false
            button.downSwipeEnabled = false
            button.comboSwipeEnabled = false
            button.upSwipeEnabled = false
            return button
        }()

        profile.buttons = [ hardDropButton, moveLeftButton, moveRightButton, softDropButton,
                            holdButton, rotateLeftButton, rotateRightButton ]

        return profile
    }

    // Mirror image of layout 1
    static func presetLayout2(name: String = "Default") -> ButtonLayoutProfile {
        
        var profile = presetLayout1(name:name)
        
        profile.buttons = profile.buttons.map {
            var button = $0
            button.position.x *= -1
            button.tilt *= -1
            button.swipeAxisTilt *= -1
            return button
        }
        
        return profile
    }

    // 8-Buttons variant
    static func presetLayout3(name: String = "Default") -> ButtonLayoutProfile {

        var profile = presetLayout1(name: name)

        var newButtons = Array(profile.buttons[0 ..< 4])
        newButtons.append(contentsOf: newButtons.map {
            var button = $0
            button.position.x *= -1
            button.tilt *= -1
            button.swipeAxisTilt *= -1
            return button
        })
        newButtons.swapAt(5, 6)
        newButtons[1].type = .rotateLeft
        newButtons[2].type = .rotateRight
        newButtons[3].type = .none
        newButtons[4].type = .hold
        newButtons[5].type = .moveLeft
        newButtons[6].type = .moveRight
        
        profile.buttons = newButtons

        return profile
    }
    
}


private extension double2 {
    var toPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}


