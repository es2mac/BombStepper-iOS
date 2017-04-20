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
        presentMenuScene()
    }

    func presentMenuScene() {

        let view = self.view as! SKView
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true

        // TODO: Change to MenuScene
        let scene = GKScene(fileNamed: "GameScene")!
        let sceneNode = scene.rootNode as! GameScene
        sceneNode.size = view.bounds.size
        sceneNode.scaleMode = .aspectFill

        view.presentScene(sceneNode)
    }
    
    @IBAction func leaveGame(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool { return false }

}
