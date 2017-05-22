//
//  ButtonLayoutDrawing.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/22/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


// Work in progress, but potentially unused
extension UIImage {
    
    class func buttonLayoutImage(profile: ButtonLayoutProfile, dummyView: UIView) -> UIImage {

        let size = UIScreen.main.bounds.size
        let rect = CGRect(origin: .zero, size: size)

        let view = SKView(frame: rect)
        view.backgroundColor = .red
        dummyView.addSubview(view)

        defer { view.removeFromSuperview() }
        
        let scene = LayoutScene(sceneSize: size)
        view.presentScene(scene)
        
        profile.buttons.forEach(scene.addButton)

        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        view.drawHierarchy(in: rect, afterScreenUpdates: true)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
}



