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

        let profile = self.collectionView.indexPathsForSelectedItems?.first.flatMap { indexPath in
            profilesManager.loadProfile(at: indexPath.item)
        }

        askForValidNewName(title: "Name your new layout.", previousName: nil, profile: profile)
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

    /// This is the intermediate step between clicking the plus button, and segue to layout editor
    /// Which profile to create/clone is selected at the same time as asking for the name, that's why it's handled here
    /// First time calling this should have no name, and generate a default name
    /// If passing in a profile, then present the choice of cloning this profile
    /// Otherwise, the preset profiles are always available choices
    private func askForValidNewName(title: String, previousName: String? = nil, profile: ButtonLayoutProfile? = nil) {

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
            textField.isUserInteractionEnabled = false
        })

        func alertHandler(with profile: ButtonLayoutProfile, isPreset: Bool) -> (UIAlertAction) -> Void {
            return { [unowned alertController, unowned self] action in
                let newName = alertController.textFields![0].text ?? ""
                if newName.isEmpty {
                    self.askForValidNewName(title: "The name cannot be empty. Please enter a new name for your layout.", previousName: nil, profile: isPreset ? nil : profile)
                }
                else if !self.profilesManager.isNameAvailable(newName) {
                    self.askForValidNewName(title: "This name is taken, please enter a new name for your layout.", previousName: newName, profile: isPreset ? nil : profile)
                }
                else {
                    var newProfile = profile
                    newProfile.name = newName
                    self.saveAndShowNewProfile(newProfile)
                }
            }
        }

        if let profile = profile {
            alertController.addAction(UIAlertAction(title: "Duplicate \"\(profile.name)\"", style: .default, handler: alertHandler(with: profile, isPreset: false)))
        }
        alertController.addAction(UIAlertAction(title: "Create Preset 1", style: .default, handler: alertHandler(with: ButtonLayoutProfile.presetLayout1(), isPreset: true)))
        alertController.addAction(UIAlertAction(title: "Create Preset 2", style: .default, handler: alertHandler(with: ButtonLayoutProfile.presetLayout2(), isPreset: true)))
        alertController.addAction(UIAlertAction(title: "Create Preset 3", style: .default, handler: alertHandler(with: ButtonLayoutProfile.presetLayout3(), isPreset: true)))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: { _ in
            alertController.textFields?.first?.isUserInteractionEnabled = true
        })
    }

    private func saveAndShowNewProfile(_ profile: ButtonLayoutProfile) {

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

