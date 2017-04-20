//
//  MenuViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {


    @IBOutlet var stackView: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(UIImageView(image: Tetromino.blank.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.I.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.J.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.L.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.O.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.S.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.Z.pixelImage()))
        stackView.addArrangedSubview(UIImageView(image: Tetromino.T.pixelImage()))
    }

    @IBAction func linkToSettings(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}
