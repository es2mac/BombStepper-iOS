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
        didSet {
            DispatchQueue.main.async {
                self.linesLeftNode.text = String(self.remainingLines)
            }
        }
    }

    fileprivate var sprintStartTime: MachAbsTime = mach_absolute_time()
    fileprivate var isTimerRunning: Bool = false

    fileprivate let displayNode = SKNode()
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
        self.timeElapsedNode.text = "3"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.timeElapsedNode.text = "2"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.timeElapsedNode.text = "1"
        }
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
            self.updateTimeElapsedNode(elapsed: endTime - self.sprintStartTime)
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

    // TODO: Refactor this node to its own class
    
    func setupNodes() {
        timeElapsedLabel.isHidden = true
        linesLeftLabel.isHidden = true

        timeElapsedNode = SKLabelNode(fontNamed: timeElapsedLabel.font.fontName)
        timeElapsedNode.fontSize = timeElapsedLabel.font.pointSize
        timeElapsedNode.fontColor = timeElapsedLabel.textColor
        timeElapsedNode.text = timeElapsedLabel.text
        timeElapsedNode.position = CGPoint(x: -40 - view.bounds.size.width / 4, y: 0)
        timeElapsedNode.alpha = 0.5

        linesLeftNode = SKLabelNode(fontNamed: linesLeftLabel.font.fontName)
        linesLeftNode.fontSize = linesLeftLabel.font.pointSize
        linesLeftNode.fontColor = linesLeftLabel.textColor
        linesLeftNode.text = linesLeftLabel.text
        linesLeftNode.position = CGPoint(x: -40 - view.bounds.size.width / 4, y: -40)
        linesLeftNode.alpha = 0.5

        displayNode.addChild(timeElapsedNode)
        displayNode.addChild(linesLeftNode)
    }

    func presentGameScene() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = GameScene(size: view.bounds.size, modeController: self)
        scene.backgroundColor = .lightFlatBlack
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}


extension SprintViewController: GameSceneUpdatable {

    func update(_ currentTime: TimeInterval) {
        guard isTimerRunning else { return }
        updateTimeElapsedNode(elapsed: mach_absolute_time() - sprintStartTime)
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


private extension SprintViewController {
    
    func updateTimeElapsedNode(elapsed: MachAbsTime) {
        let interval: TimeInterval = absToMs(elapsed) / 1000
        let intInterval = Int(interval)
        let decimals = Int(interval * 100) - intInterval * 100
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60

        timeElapsedNode.text = String(format: "%02d:%02d.%02d", minutes, seconds, decimals)
    }
}










