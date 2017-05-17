//
//  UIImageDrawing.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/26/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


extension UIImage {

    class func borderedSquare(side: CGFloat, color: UIColor, edgeColor: UIColor, adjacency: SKTileAdjacencyMask = []) -> UIImage {

        let drawSize = CGSize(width: side, height: side)

        UIGraphicsBeginImageContextWithOptions(drawSize, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        // Fill background with background edge color first
        let fullRect = CGRect(origin: .zero, size: drawSize)
        UIColor.playfieldBorder.setFill()
        context.fill(fullRect)

        // Fill background with edge color
        context.addPath(UIBezierPath(roundedRect: fullRect, cornerRadius: 2).cgPath)
        edgeColor.setFill()
        context.fillPath()

        // Appropriately inset & round corners to draw the main color
        var inset: (up: CGFloat, down: CGFloat, left: CGFloat, right: CGFloat) = (0, 0, 0, 0)

        if !adjacency.contains(.adjacencyUp)    { inset.up = 1 }
        if !adjacency.contains(.adjacencyDown)  { inset.down = 1 }
        if !adjacency.contains(.adjacencyLeft)  { inset.left = 1 }
        if !adjacency.contains(.adjacencyRight) { inset.right = 1 }

        /*
         // Note: This style has a tiny issue with "inner corner" pieces
         let corners: UIRectCorner = []
         switch (adjacency.contains(.adjacencyUp), adjacency.contains(.adjacencyRight),
         adjacency.contains(.adjacencyDown), adjacency.contains(.adjacencyLeft)) {
         //      Top  Right   Down   Left
         case (false, false,     _,     _): corners.insert(.topRight)
         case (    _, false, false,     _): corners.insert(.bottomRight)
         case (    _,     _, false, false): corners.insert(.bottomLeft)
         case (false,     _,     _, false): corners.insert(.topLeft)
         default: break
         }
         let roundedRect = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 2, height: 2))
         */

        let rect = CGRect(x: inset.left,
                          y: inset.up,
                          width: side - inset.left - inset.right,
                          height: side - inset.up - inset.down)

        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 2)

        context.addPath(roundedRect.cgPath)
        color.setFill()
        context.fillPath()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    class func roundedRect(size: CGSize, cornerRadius: CGFloat, color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        context.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5).offsetBy(dx: 1, dy: 1), cornerRadius: cornerRadius).cgPath)
        color.setFill()
        context.fillPath()

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}


extension UIImage {

    func layeredOnTop(of image: UIImage, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: rect)
        self.draw(in: rect, blendMode: .normal, alpha: alpha)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}


extension UIImage {

    class func image(from configuration: ButtonConfiguration) -> UIImage {

        let side = (configuration.swipeDistance + 4) * 2

        UIGraphicsBeginImageContextWithOptions(CGSize(width: side, height: side), false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        let centerX = side / 2
        let centerY = side / 2
        let distance = configuration.swipeDistance

        let centerPoint    = CGPoint(x: centerX,            y: centerY)
        let leftPoint      = CGPoint(x: centerX - distance, y: centerY)
        let rightPoint     = CGPoint(x: centerX + distance, y: centerY)
        let downPoint      = CGPoint(x: centerX,            y: centerY + distance)
        let leftDownPoint  = CGPoint(x: centerX - distance, y: centerY + distance)
        let rightDownPoint = CGPoint(x: centerX + distance, y: centerY + distance)
        let upPoint        = CGPoint(x: centerX,            y: centerY - distance)

        let color = #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 1)
        color.set()

        let dash: [CGFloat] = [3, 2]
        context.setLineDash(phase: 0, lengths: dash)

        func dotPath(at center: CGPoint) -> CGPath {
            return UIBezierPath(arcCenter: center, radius: 3, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        }

        func dashedLinePath(from point1: CGPoint, to point2: CGPoint) -> CGPath {
            let path = UIBezierPath()
            path.move(to: point1)
            path.addLine(to: point2)
            return path.cgPath
        }

        func fillPaths(_ paths: [CGPath]) {
            context.beginPath()
            paths.forEach(context.addPath)
            context.fillPath()
        }

        func strokePaths(_ paths: [CGPath]) {
            context.beginPath()
            paths.forEach(context.addPath)
            context.strokePath()
        }

        fillPaths([dotPath(at: centerPoint)])

        if configuration.leftRightSwipeEnabled {
            fillPaths([ dotPath(at: leftPoint),
                        dotPath(at: rightPoint) ])
            strokePaths([ dashedLinePath(from: centerPoint, to: leftPoint),
                          dashedLinePath(from: centerPoint, to: rightPoint) ])
        }

        if configuration.downSwipeEnabled {
            fillPaths([ dotPath(at: downPoint) ])
            strokePaths([ dashedLinePath(from: centerPoint, to: downPoint) ])
        }

        if configuration.comboSwipeEnabled {
            fillPaths([ dotPath(at: leftDownPoint),
                        dotPath(at: rightDownPoint) ])
            strokePaths([ dashedLinePath(from: leftPoint, to: leftDownPoint),
                          dashedLinePath(from: rightPoint, to: rightDownPoint) ])
        }

        if configuration.upSwipeEnabled {
            fillPaths([ dotPath(at: upPoint) ])
            strokePaths([ dashedLinePath(from: centerPoint, to: upPoint) ])
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

