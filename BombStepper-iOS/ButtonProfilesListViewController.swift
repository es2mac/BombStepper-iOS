//
//  ButtonProfilesListViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/3/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


class ButtonProfilesListViewController: UIViewController {

    private let profilesManager = ButtonProfilesManager()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!

    var selectedIndexPath: IndexPath? {
        didSet { enableEditButtons(selectedIndexPath != nil) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        print(profilesManager.profileNames)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func createOrCloneProfile(_ sender: UIBarButtonItem) {

        // Pass existing layout in for clone action



        var profile = ButtonLayoutProfile(name: "")

        askForValidName(title: "Enter a name for your new layout.", previousName: nil) { [unowned self] newName in
            profile.name = newName
            self.showButtonEditor(profile: profile)
        }
        

    }

    private func askForValidName(title: String, previousName: String? = nil, completion: @escaping (_ name: String) -> Void ) {

        guard let defaultName = profilesManager.nextGenericProfileName() else {
            let alertController = UIAlertController(title: "Can't create another profile", message: nil, preferredStyle: .alert)
            show(alertController, sender: nil)
            return
        }

        let name = previousName ?? defaultName

        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = name
            let range = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            textField.selectedTextRange = range
            textField.clearButtonMode = .always
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned alertController, unowned self] action in
            let newName = alertController.textFields![0].text ?? ""
            if newName.isEmpty {
                self.askForValidName(title: "The name cannot be empty. Please enter a new name for your layout.", previousName: newName, completion: completion)
            }
            else if self.profilesManager.isNameAvailable(newName) {
                completion(newName)
            }
            else {
                self.askForValidName(title: "This name is taken, please enter a new name for your layout.", previousName: newName, completion: completion)
            }

        }))

        show(alertController, sender: nil)
    }

    private func showButtonEditor(profile: ButtonLayoutProfile) {

        // Test

        switch profile.save() {
        case .duplicateName:
            print("duplicate name")
        case .success:
            print("success")
        case .failed:
            print("failed")
        }
    }




// TODO
    private func showLayoutEditor(layout: Int?) {

    }

}


extension ButtonProfilesListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonProfileCollectionViewCell", for: indexPath)
    }

}


extension ButtonProfilesListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.height - (4 * 2)
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == selectedIndexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedIndexPath = nil
        }
        else {
            selectedIndexPath = indexPath
        }
    }

    func enableEditButtons(_ isEnabled: Bool) {
        editButton.isEnabled = isEnabled
        trashButton.isEnabled = isEnabled
    }

}

