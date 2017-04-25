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

    class func transparentRoundedRect(size: CGSize, strokeColor: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()!

        context.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5).offsetBy(dx: 1, dy: 1), cornerRadius: 4).cgPath)
        strokeColor.setStroke()
        context.strokePath()

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


