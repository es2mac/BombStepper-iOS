//
//  SprintViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/29/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


class SprintViewController: UIViewController {
    
    var sprintStartTime: MachAbsTime = 0
    var gameEndAction: (() -> Void)?
    var gameStartAction: (() -> Void)?

    var remainingLines = 40 {
        didSet {
            DispatchQueue.main.async {
                self.linesLeftLabel.text = String(self.remainingLines)
                self.showElapsedTime(endTime: mach_absolute_time())
            }
        }
    }

    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var linesLeftLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        presentGameScene()
    }

    func setupLabels() {
        timeElapsedLabel.alpha = 0
        linesLeftLabel.alpha = 0

        let fontFeatures = [ [UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
             UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector] ]
        let descriptorWithFeatures = timeElapsedLabel.font.fontDescriptor
            .addingAttributes([UIFontDescriptorFeatureSettingsAttribute: fontFeatures])

        timeElapsedLabel.font = UIFont(descriptor: descriptorWithFeatures, size: 0)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 3) {
            self.timeElapsedLabel.alpha = 1
            self.linesLeftLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { 
            self.gameStartAction?()
            self.sprintStartTime = mach_absolute_time()

        }
    }

    @IBAction func leaveGame(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool { return false }

}


extension SprintViewController: GameSceneUpdatable {
    func update(_ currentTime: TimeInterval) {

    }
}


extension SprintViewController: GameEventDelegate {

    func modeSpecificNodes() -> [SKNode] { return [] }


    func updateLabel(sender: CADisplayLink) {
        showElapsedTime(endTime: mach_absolute_time())
    }

    func showElapsedTime(endTime: MachAbsTime) {

        let duration: TimeInterval = absToMs(endTime - sprintStartTime) / 1000

        timeElapsedLabel.text = stringFromTimeInterval(interval: duration)
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let intInterval = Int(interval)
        let decimals = Int(interval * 100) - intInterval * 100
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60
        return String(format: "%02d:%02d.%02d", minutes, seconds, decimals)
    }


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

    func toppedOut() { }

    private func endGame() {
        let endTime = mach_absolute_time()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showElapsedTime(endTime: endTime)
        }
        gameEndAction?()
    }

}










