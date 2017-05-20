//
//  ButtonLayoutEditorViewController.swift
//  ButtonCreator
//
//  Created by Paul on 5/2/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonLayoutEditorViewController: UIViewController {

    var layoutScene: LayoutScene!

    fileprivate var viewSize: CGSize? {
        didSet {
            guard oldValue == nil, viewSize != nil else {
                assertionFailure("Should only be set once")
                return
            }
            presentLayoutScene()
        }
    }
    

    @IBAction func create() {
        layoutScene.addButton(with: .standard)
    }
    
    func editButton(buttonNode: ButtonPreviewNode?) {
        performSegue(withIdentifier: "Edit Button", sender: buttonNode)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editorViewController = segue.destination as? ButtonEditorViewController else { return }

        let buttonNode = sender as? ButtonPreviewNode
        (buttonNode?.configuration).map { editorViewController.configuration = $0 }

        editorViewController.deleteButtonAction = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
            buttonNode?.removeFromParent()
        }
        editorViewController.editingDoneAction = { [unowned self] configuration in
            self.layoutScene.addButton(with: configuration)
            self.navigationController?.popViewController(animated: true)
            buttonNode?.removeFromParent()
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewSize == nil { viewSize = view.bounds.size }
    }

}


private extension ButtonLayoutEditorViewController {

    func presentLayoutScene() {
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true

        let scene = LayoutScene(sceneSize: viewSize!)
        scene.backgroundColor = .lightFlatBlack
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        self.layoutScene = scene
        layoutScene.editButtonAction = { [unowned self] node in
            self.editButton(buttonNode: node)
        }
    }
}


//extension UIColor {
//    static let lightFlatBlack = #colorLiteral(red: 0.1686089337, green: 0.1686392725, blue: 0.1686022878, alpha: 1)
//    static let playfieldBorder = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//}
//
//
//enum Alpha {
//    static let pressedButton: CGFloat = 0.15
//    static let releasedButton: CGFloat = 0.04
//}





