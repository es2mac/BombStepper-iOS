//
//  SprintViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/29/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class SprintViewController: UIViewController {

    var signalGamePrepare: (() -> Void)?    // GameModeController protocol
    var signalGameStart: (() -> Void)?
    var signalGameEnd: (() -> Void)?

    fileprivate var remainingLines = 40 {
        didSet { displayNode.showLinesRemaining(remainingLines) }
    }

    fileprivate var sprintStartTime: MachAbsTime = mach_absolute_time()
    fileprivate var isTimerRunning: Bool = false

    fileprivate var displayNode: SprintDisplayNode!
    fileprivate var timeElapsedNode: SKLabelNode!
    fileprivate var linesLeftNode: SKLabelNode!

    @IBOutlet var buttonsView: UIView!

    // These are just for taking attributes to make the SKLabelNodes
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var linesLeftLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNodes()
        presentGameScene()
    }

    override var shouldAutorotate: Bool { return false }

}


private extension SprintViewController {

    @IBAction func startGame() {

        signalGamePrepare?()
        remainingLines = 40

        UIView.animate(withDuration: 0.5, animations: {
            self.buttonsView.alpha = 0
        }, completion: { _ in
            self.buttonsView.isHidden = true
            self.buttonsView.alpha = 1
        })

        // TODO: A separate countdown node
        displayNode.startCountDown()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.signalGameStart?()
            self.sprintStartTime = mach_absolute_time()
            self.isTimerRunning = true
        }
    }

    func endGame(endTime: MachAbsTime) {
        isTimerRunning = false
        signalGameEnd?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.displayNode.showTimeElapsed(elapsed: endTime - self.sprintStartTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.buttonsView.isHidden = false
            self.buttonsView.alpha = 0
            UIView.animate(withDuration: 1) {
                self.buttonsView.alpha = 1
            }
        }
    }

    @IBAction func exit(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}


extension SprintViewController {

    func setupNodes() {
        timeElapsedLabel.isHidden = true
        linesLeftLabel.isHidden = true
        displayNode = SprintDisplayNode(sceneSize: UIScreen.main.bounds.size)
        displayNode.matchLinesLeftNodeStyle(with: linesLeftLabel)
        displayNode.matchTimeElapsedNodeStyle(with: timeElapsedLabel)
    }

    func presentGameScene() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = GameScene(size: UIScreen.main.bounds.size, modeController: self)
        scene.backgroundColor = .lightFlatBlack
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}


extension SprintViewController: GameSceneUpdatable {

    func update(_ currentTime: TimeInterval) {
        if isTimerRunning  {
            displayNode.showTimeElapsed(elapsed: mach_absolute_time() - sprintStartTime)
        }
    }
}


extension SprintViewController: GameModeController {

    var modeSpecificDisplayNode: SKNode? {
        return displayNode
    }

    var updateReceiver: GameSceneUpdatable? {
        return self
    }

    func linesCleared(_ lineClear: LineClear) {
        let time = mach_absolute_time()

        switch lineClear {
        case .normal(lines: let lines), .TSpin(lines: let lines):
            remainingLines = max(remainingLines - lines, 0)
        case .TSpinMini:
            remainingLines = max(remainingLines - 1, 0)
        }

        if remainingLines == 0 {
            endGame(endTime: time)
        }
    }

    func toppedOut() {
        endGame(endTime: mach_absolute_time())
    }

}










