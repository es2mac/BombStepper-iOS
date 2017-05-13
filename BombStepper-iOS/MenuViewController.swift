//
//  MenuViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/19/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit
import SafariServices


final class MenuViewController: UIViewController {


    @IBOutlet var stackView: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func showSettings(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }

    @IBAction func showAbout(_ sender: UIButton) {
        let browser = SFSafariViewController(url: URL(string: "http://mathemusician.net/about/")!)
        show(browser, sender: nil)
    }

}


