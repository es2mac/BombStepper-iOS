//
//  ButtonProfilesListViewController.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/3/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


// TODO: Use the selected profile (or default profile) for playing

class ButtonProfilesListViewController: UIViewController {

    fileprivate let profilesManager = ButtonProfilesManager()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!

    var selectedIndexPath: IndexPath? {
        didSet { enableEditButtons(selectedIndexPath != nil) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func createOrCloneProfile(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "New Layout", message: nil, preferredStyle: .alert)
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first,
            let existingProfile = profilesManager.loadProfile(at: indexPath.item) {
            alertController.addAction(UIAlertAction(title: "Duplicate \"\(existingProfile.name)\"", style: .default, handler: { _ in

            }))
        }
        else if !profilesManager.profileNames.isEmpty {
            alertController.addAction(UIAlertAction(title: "Duplicate...", style: .default, handler: { _ in
                // TODO
            }))
        }
        alertController.addAction(UIAlertAction(title: "Preset 1", style: .default, handler: { _ in
            // TODO
        }))
        alertController.addAction(UIAlertAction(title: "Preset 2", style: .default, handler: { _ in
            // TODO
        }))
        alertController.addAction(UIAlertAction(title: "Preset 3", style: .default, handler: { _ in
            // TODO
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            // TODO
        }))

        present(alertController, animated: true, completion: nil)
        

        // TODO: show option to clone selected profile or use preset
        // If selected something, "clone that one" is an option
        // otherwise, "choose what to clone" is an option



        /*
        let profile: ButtonLayoutProfile
        if let indexPath = self.collectionView.indexPathsForSelectedItems?.first,
            let existingProfile = self.profilesManager.loadProfile(at: indexPath.item) {
            profile = existingProfile
        }
        else {
            profile = ButtonLayoutProfile.presetLayout3()
        }

        let previousName: String?
        
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            previousName = profilesManager.profileNames[indexPath.item]
        }
        else {
            previousName = nil
        }
        
        askForValidNewName(title: "Enter a name for your new layout.", previousName: previousName, completion: { [unowned self] newName in
            self.saveAndShowNewProfile(name: newName)
        })
         */
    }

    @IBAction func editProfile(_ sender: UIBarButtonItem) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
            let profile = profilesManager.loadProfile(at: indexPath.item) else { return }

        showLayoutEditor(profile: profile)
    }

    @IBAction func deleteProfile(_ sender: UIBarButtonItem) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        let name = profilesManager.profileNames[indexPath.item]

        let alertController = UIAlertController(title: "Are you sure you want to delete the profile \"\(name)\"?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] _ in
            if self.profilesManager.deleteProfile(at: indexPath.item) {
                self.collectionView.deleteItems(at: [indexPath])
                self.selectedIndexPath = nil
            }
            else { assertionFailure() }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func askForValidNewName(title: String, previousName: String? = nil, completion: @escaping (_ name: String) -> Void ) {

        guard let name = profilesManager.nextProfileName(from: previousName) else {
            let count = profilesManager.profileNames.count
            let alertController = UIAlertController(title: "Can't create more profiles\n(max \(count))", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { [unowned self] textField in
            textField.delegate = self
            textField.text = name
            let range = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            textField.selectedTextRange = range
            textField.clearButtonMode = .always
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned alertController, unowned self] action in
            let newName = alertController.textFields![0].text ?? ""
            if newName.isEmpty {
                self.askForValidNewName(title: "The name cannot be empty. Please enter a new name for your layout.", previousName: nil, completion: completion)
            }
            else if self.profilesManager.isNameAvailable(newName) {
                completion(newName)
            }
            else {
                self.askForValidNewName(title: "This name is taken, please enter a new name for your layout.", previousName: newName, completion: completion)
            }

        }))

        present(alertController, animated: true, completion: nil)
    }

    private func saveAndShowNewProfile(name: String) {

        // TODO: This profile creation should be passed in instead
        let profile: ButtonLayoutProfile = {
            if let indexPath = self.collectionView.indexPathsForSelectedItems?.first,
                var profile = self.profilesManager.loadProfile(at: indexPath.item) {
                profile.name = name
                return profile
            }
            else {
                return ButtonLayoutProfile.presetLayout3(name: name)
            }
        }()

        if case .success = self.profilesManager.save(profile), let index = self.profilesManager.profileNames.index(of: profile.name) {

            let indexPath = IndexPath(item: index, section: 0)

            self.collectionView.insertItems(at: [indexPath])

            self.collectionView.performBatchUpdates({

                self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.selectedIndexPath = indexPath

            }, completion: { _ in

                self.showLayoutEditor(profile: profile)

            })

        }
        else { assertionFailure() }
    }

    private func showLayoutEditor(profile: ButtonLayoutProfile) {
        performSegue(withIdentifier: "Show Layout Editor", sender: profile)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ButtonLayoutEditorViewController,
            let profile = sender as? ButtonLayoutProfile {

            controller.profile = profile
            let hasImage = (profilesManager.loadImage(named: profile.name) != nil)
            controller.takeInitialSnapshot = !hasImage

            controller.saveProfileAction = { [unowned self] (newProfile, image) in
                
                if let newProfile = newProfile {
                    if case .success = self.profilesManager.save(newProfile) { /* Defer update to after saving image */ }
                    else { assertionFailure() }
                }

                if let image = image {
                    self.profilesManager.saveImage(image: image, name: profile.name)
                }

                if (newProfile != nil || image != nil), let index = self.profilesManager.profileNames.index(of: profile.name) {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.reloadData()
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                }

                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}


extension ButtonProfilesListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilesManager.profileNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonProfileCollectionViewCell", for: indexPath) as! ButtonProfileCollectionViewCell
        
        let name = profilesManager.profileNames[indexPath.item]
        
        cell.label.text = name
        cell.setImageAndAdjustAspectRatio(profilesManager.loadImage(named: name))
        cell.selectionSwitch.isOn = profilesManager.selectedProfileName == name
        
        cell.selectionAction = { [unowned self] isSelected in
            self.changeSelection(name: name, isSelected: isSelected)
        }
        return cell
    }

    private func changeSelection(name: String, isSelected: Bool) {

        let previousName = profilesManager.selectedProfileName
        
        switch (name == previousName, isSelected) {
        case (true, false):
            profilesManager.selectedProfileName = nil
        case (false, true):
            profilesManager.selectedProfileName = name
            if let previousName = previousName, let previousIndex = profilesManager.profileNames.index(of: previousName) {
                let indexPath = IndexPath(item: previousIndex, section: 0)
                collectionView.reloadItems(at: [indexPath])
            }
        default:
            break
        }

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


extension ButtonProfilesListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textLength = textField.text?.characters.count ?? 0
        return (textLength - range.length + string.characters.count) <= 24
    }
}

