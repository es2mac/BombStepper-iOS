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


enum GameMode {
    case sprint
    case bombStepper
    case freePlay
}


class GameViewController: UIViewController {

    var gameMode: GameMode!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Setup the system for game scene here

        let coordinator: GameCoordinator = DummyCoordinator()
        presentGameScene(with: coordinator)
    }

    func presentGameScene(with coordinator: GameCoordinator) {

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = GameScene(size: view.bounds.size, coordinator: coordinator)
        scene.backgroundColor = .lightFlatBlack
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    @IBAction func leaveGame(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool { return false }

}
