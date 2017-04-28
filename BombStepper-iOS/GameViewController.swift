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


// TODO: Consider having view controllers as game coordinator


final class GameViewController: UIViewController {

    var gameMode: GameMode!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Setup the system for game scene here
        timeElapsedLabel.alpha = 0
        linesLeftLabel.alpha = 0

        presentGameScene()
    }

    func presentGameScene() {

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = GameScene(size: view.bounds.size, eventDelegate: self)
        scene.backgroundColor = .lightFlatBlack
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    @IBAction func leaveGame(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool { return false }





    // Experimental game coordinator

    var sprintStartTime: MachAbsTime = 0
    var displayLink: CADisplayLink!

    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var linesLeftLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        let fontFeatures = [
            [UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
             UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector]
        ]
        let descriptorWithFeatures = timeElapsedLabel.font.fontDescriptor
            .addingAttributes([UIFontDescriptorFeatureSettingsAttribute: fontFeatures])

        timeElapsedLabel.font = UIFont(descriptor: descriptorWithFeatures, size: 0)

        UIView.animate(withDuration: 3) {
            self.timeElapsedLabel.alpha = 1
            self.linesLeftLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
            self.gameStartAction?()
            self.sprintStartTime = mach_absolute_time()

            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateLabel(sender:)))
            self.displayLink.add(to: .main, forMode: .defaultRunLoopMode)
        }
    }

    func updateLabel(sender: CADisplayLink) {
        showElapsedTime(endTime: mach_absolute_time())
    }

    func showElapsedTime(endTime: MachAbsTime) {

        let duration: TimeInterval = absToMs(endTime - sprintStartTime) / 1000

        timeElapsedLabel.text = stringFromTimeInterval(interval: duration)


        
        
//        let elapsed = absToMs(endTime - sprintStartTime)
//
//        let minutes = (elapsed / (60 * 1000)).rounded(.towardZero)
//        let seconds = (elapsed / 1000) - minutes * 60
//
//        timeElapsedLabel.text = String(format: "%2.0f : %2.2f", minutes, seconds)
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let intInterval = Int(interval)
        let decimals = Int(interval * 100) - intInterval * 100
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60
        return String(format: "%02d:%02d.%02d", minutes, seconds, decimals)
    }

    var gameEndAction: (() -> Void)?
    var gameStartAction: (() -> Void)?

    private var remainingLines = 40 {
        didSet {
            DispatchQueue.main.async {
                self.linesLeftLabel.text = String(self.remainingLines)
            }
        }
    }

    func modeSpecificNodes() -> [SKNode] { return [] }

    func linesCleared(_ lineClear: LineClear) {
        switch lineClear {
        case .normal(lines: let lines), .TSpin(lines: let lines):
            remainingLines -= lines
        case .TSpinMini:
            remainingLines -= 1
        }

        if remainingLines <= 0 {
            remainingLines = 0
            endGame()
        }
    }

    func toppedOut() {
        
    }

    private func endGame() {

        // display and stuff

        let endTime = mach_absolute_time()

        displayLink.remove(from: .main, forMode: .defaultRunLoopMode)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showElapsedTime(endTime: endTime)
        }


        
        gameEndAction?()
    }

}


extension GameViewController: GameEventDelegate { }
