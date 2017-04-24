//
//  GameViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/17/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentGameScene()
    }

    func presentGameScene() {

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = SKScene(fileNamed: "GameScene")!
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    @IBAction func leaveGame(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool { return false }

}
