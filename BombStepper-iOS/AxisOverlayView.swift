//
//  AxisOverlayView.swift
//  ButtonCreator
//
//  Created by Paul on 5/1/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


final class AxisOverlayView: UIImageView {

    var configuration: ButtonConfiguration = .standard {
        didSet {
            image = UIImage.image(from: configuration)
            transform = CGAffineTransform(rotationAngle: -(configuration.swipeAxisTilt - configuration.tilt) * .pi / 180)
        }
    }

}


extension AxisOverlayView {


}
