//
//  ControllerNode.swift
//  BombStepper-iOS
//
//  Created by Paul on 4/20/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


protocol ControllerDelegate: class {
    func buttonDown(_ button: ButtonType)
    func buttonUp(_ button: ButtonType)
}


final class ControllerNode: SKNode {

    let sceneSize: CGSize
    weak var delegate: ControllerDelegate? {
        didSet { buttonNodes.forEach { $0.delegate = delegate } }
    }
    
    fileprivate let buttonNodes: [ButtonNode]

    init(sceneSize: CGSize, delegate: ControllerDelegate? = nil) {
        self.sceneSize = sceneSize
        self.delegate = delegate

        // TODO: create buttons using config
        let layoutProfile = ButtonProfilesManager().loadSelectedProfile()
        buttonNodes = layoutProfile.buttons.map(ButtonNode.init)

        super.init()

        buttonNodes.forEach {
            addChild($0)
            $0.delegate = delegate
        }

        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
            self?.stopAllTouches()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


private extension ControllerNode {

    func stopAllTouches() {
        // TODO: Implement cancellation on Button nodes
    }
}





