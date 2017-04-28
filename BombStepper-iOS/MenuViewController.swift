//
//  MenuViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {


    @IBOutlet var stackView: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func linkToSettings(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

}


final class FreePlaySegue: UIStoryboardSegue {

    override func perform() {
        guard let gameViewController = destination as? GameViewController else {
            assertionFailure("Segue destination should be GameViewController")
            return
        }
        gameViewController.gameMode = .freePlay
        super.perform()
    }
    
}


