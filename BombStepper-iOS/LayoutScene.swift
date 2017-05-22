//
//  LayoutScene.swift
//  ButtonCreator
//
//  Created by Paul on 5/2/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class LayoutScene: SKScene {

    var editButtonAction: ((_ buttonNode: ButtonPreviewNode) -> Void)?

    fileprivate let sceneSize: CGSize

    fileprivate var movingNode: ButtonPreviewNode?
    fileprivate var panStartTime: Date = Date()

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize

        super.init(size: sceneSize)
    }

    override func didMove(to view: SKView) {
        let panRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(panRecognizer)
        panRecognizer.addTarget(self, action: #selector(pan(_:)))

        let singleTapRecognizer = UITapGestureRecognizer()
        singleTapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapRecognizer)
        singleTapRecognizer.addTarget(self, action: #selector(singleTap(_:)))

        let doubleTapRecognizer = UITapGestureRecognizer()
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        doubleTapRecognizer.addTarget(self, action: #selector(doubleTap(_:)))

        singleTapRecognizer.require(toFail: panRecognizer)
        doubleTapRecognizer.require(toFail: panRecognizer)
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension LayoutScene {
    
    func addButton(with configuration: ButtonConfiguration) {
        let node = ButtonPreviewNode(configuration: configuration)
        addChild(node)
    }

    func buttonConfigurations() -> [ButtonConfiguration] {
        let buttonNodes = children.flatMap { $0 as? ButtonPreviewNode }
        return buttonNodes.map { $0.configuration }
    }

    func hideAllNodeDetails() {
        children
            .flatMap { $0 as? ButtonPreviewNode }
            .forEach { $0.showDetails(false, animated: false) }
    }
}


private extension LayoutScene {

    @objc func pan(_ recognizer: UIPanGestureRecognizer) {

        switch recognizer.state {

        case .began:
            let startLocation = locationInScene(viewLocation: recognizer.location(in: view), translation: recognizer.translation(in: view))
            movingNode = nodes(at: startLocation).first(where: { $0 is ButtonPreviewNode }) as? ButtonPreviewNode
            movingNode?.run(.move(to: startLocation.rounded(), duration: 0.1))
            panStartTime = Date()

        case .changed:
            let currentLocation = locationInScene(viewLocation: recognizer.location(in: view))
            let motionRemainingTime = max(0, 0.1 + panStartTime.timeIntervalSinceNow)
            movingNode?.run(.move(to: currentLocation.rounded(), duration: motionRemainingTime))

        case .ended:
            let currentLocation = locationInScene(viewLocation: recognizer.location(in: view))
            movingNode?.position = currentLocation.rounded()
            movingNode?.configuration.position = currentLocation.rounded()
            movingNode = nil

        default:
            break
        }
    }

    @objc func singleTap(_ recognizer: UITapGestureRecognizer) {
        let location = locationInScene(viewLocation: recognizer.location(in: view))
        if let node = nodes(at: location).first(where: { $0 is ButtonPreviewNode }) as? ButtonPreviewNode {
            node.toggleShowDetails()
        }
    }
    
    @objc func doubleTap(_ recognizer: UITapGestureRecognizer) {
        let location = locationInScene(viewLocation: recognizer.location(in: view))
        if let node = nodes(at: location).first(where: { $0 is ButtonPreviewNode }) as? ButtonPreviewNode {
            editButtonAction?(node)
        }
    }
    
    func locationInScene(viewLocation: CGPoint, translation: CGPoint = .zero) -> CGPoint {
        return CGPoint(x:   viewLocation.x - translation.x - size.width  / 2,
                       y: -(viewLocation.y - translation.y - size.height / 2))
    }

}


private extension CGPoint {
    func rounded() -> CGPoint {
        return CGPoint(x: x.rounded(), y: y.rounded())
    }
}






