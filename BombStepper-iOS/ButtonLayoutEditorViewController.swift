//
//  ButtonLayoutEditorViewController.swift
//  ButtonCreator
//
//  Created by Paul on 5/2/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import SpriteKit


final class ButtonLayoutEditorViewController: UIViewController {

    var profile: ButtonLayoutProfile!   // Whoever shows the editor should set this

    var saveProfileAction: ((_ profile: ButtonLayoutProfile?) -> Void)?

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

    @IBAction func done() {

        let newButtons = layoutScene.buttonConfigurations()
        
        if profile.buttons == newButtons {
            self.saveProfileAction?(nil)
        }
        else {
            profile.buttons = newButtons
            
            let alertController = UIAlertController(title: "Save this layout?", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [unowned self] _ in
                self.saveProfileAction?(self.profile)
            }))
            alertController.addAction(UIAlertAction(title: "Don't Save", style: .destructive, handler: { [unowned self] _ in
                self.saveProfileAction?(nil)
            }))
            
            present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func create() {
        layoutScene.addButton(with: .standard)
    }
    
    func editButton(buttonNode: ButtonPreviewNode?) {
        // This is unfortunately rather confusing.
        // The button tap gesture is handled by the layout scene
        // Layout scene sends the button this way via action closure
        // The button is trapped in the closure given to the button editor
        // So when the button editor's done editing,
        // We know which node needs to be replaced or removed
        performSegue(withIdentifier: "Edit Button", sender: buttonNode)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editorViewController = segue.destination as? ButtonEditorViewController else { return }

        let buttonNode = sender as? ButtonPreviewNode

        if let configuration = buttonNode?.configuration {
            editorViewController.configuration = configuration
        }

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

        profile.buttons.forEach(layoutScene.addButton)
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





