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

        collectionView.dataSource = profilesManager
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func createOrCloneProfile(_ sender: UIBarButtonItem) {

        // Pass existing layout in for clone action

        let previousName: String?

        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            previousName = profilesManager.profileNames[indexPath.item]
        }
        else {
            previousName = nil
        }



        var profile = ButtonLayoutProfile(name: "")

        askForValidName(title: "Enter a name for your new layout.", previousName: previousName) { [unowned self] newName in
            profile.name = newName

            if case .success = self.profilesManager.save(profile), let index = self.profilesManager.profileNames.index(of: profile.name) {

                let indexPath = IndexPath(item: index, section: 0)

                self.collectionView.insertItems(at: [indexPath])

                self.collectionView.performBatchUpdates({

                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.selectedIndexPath = indexPath

                }, completion: { _ in
                    
                    self.showButtonEditor(profile: profile)
                    
                })

            }
            else { assertionFailure() }
            
        }
    }

    @IBAction func deleteProfile(_ sender: UIBarButtonItem) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        let name = profilesManager.profileNames[indexPath.item]

        let alertController = UIAlertController(title: "Are you sure you want to delete the profile \"\(name)\"?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
            if self.profilesManager.deleteProfile(at: indexPath.item) {
                self.collectionView.deleteItems(at: [indexPath])
                self.selectedIndexPath = nil
            }
            else { assertionFailure() }
        }))

        show(alertController, sender: nil)
    }

    private func askForValidName(title: String, previousName: String? = nil, completion: @escaping (_ name: String) -> Void ) {

        guard let name = profilesManager.nextProfileName(from: previousName) else {
            let count = profilesManager.profileNames.count
            let alertController = UIAlertController(title: "Can't create more profiles\n(max \(count))", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            show(alertController, sender: nil)
            return
        }

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
                self.askForValidName(title: "The name cannot be empty. Please enter a new name for your layout.", previousName: nil, completion: completion)
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
//        switch profile.save() {
//        case .duplicateName:
//            print("duplicate name")
//        case .success:
//            print("success")
//        case .failed:
//            print("failed")
//        }
    }




// TODO
    private func showLayoutEditor(layout: Int?) {

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

