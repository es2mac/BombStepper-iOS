//
//  ButtonEditorViewController.swift
//  ButtonCreator
//
//  Created by Paul on 4/30/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


final class ButtonEditorViewController: UIViewController {


    var editingDoneAction: ((_ configuration: ButtonConfiguration) -> Void)?
    var deleteButtonAction: (() -> Void)?
    var configuration: ButtonConfiguration = .standard {
        didSet { updatePreview() }
    }

    @IBOutlet fileprivate var optionsBackgroundView: UIView!
    @IBOutlet fileprivate var shapeOptionsStackView: UIStackView!
    @IBOutlet fileprivate var swipeOptionsStackView: UIStackView!

    @IBOutlet fileprivate var previewBackgroundView: UIView!
    @IBOutlet fileprivate var shapeView: UIView!
    @IBOutlet fileprivate var pickTypeButton: UIButton!
    @IBOutlet fileprivate var swipeAxisView: UIView!
    @IBOutlet fileprivate var axisOverlayView: AxisOverlayView!

    @IBOutlet fileprivate var widthLabel: UILabel!
    @IBOutlet fileprivate var widthSlider: UISlider!
    
    @IBOutlet fileprivate var heightLabel: UILabel!
    @IBOutlet fileprivate var heightSlider: UISlider!

    @IBOutlet fileprivate var cornerLabel: UILabel!
    @IBOutlet fileprivate var cornerSlider: UISlider!

    @IBOutlet fileprivate var tiltLabel: UILabel!
    @IBOutlet fileprivate var tiltSlider: UISlider!

    @IBOutlet fileprivate var distanceLabel: UILabel!
    @IBOutlet fileprivate var distanceSlider: UISlider!

    @IBOutlet fileprivate var swipeAxisTiltLabel: UILabel!
    @IBOutlet fileprivate var swipeAxisTiltSlider: UISlider!

    @IBOutlet fileprivate var leftRightSwipewitch: UISwitch!

    @IBOutlet fileprivate var downSwipeSwitch: UISwitch!

    @IBOutlet fileprivate var comboSwipeSwitch: UISwitch!
    
    @IBOutlet fileprivate var upSwipeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        updatePreview()
        repositionSlidersAndSwitches()
        swipeAxisView.alpha = 0
        pickTypeButton.titleLabel!.adjustsFontSizeToFitWidth = true
        pickTypeButton.titleLabel!.minimumScaleFactor = 0.1
        moveSwipeOptionsInplace()
    }

    @IBAction fileprivate func widthChanged(_ sender: UISlider) {
        configuration.width = CGFloat(sender.value)
        cornerSlider.value = Float(configuration.corner)
    }

    @IBAction fileprivate func heightChanged(_ sender: UISlider) {
        configuration.height = CGFloat(sender.value)
        cornerSlider.value = Float(configuration.corner)
    }

    @IBAction fileprivate func cornerChanged(_ sender: UISlider) {
        configuration.corner = CGFloat(sender.value)
        widthSlider.value = Float(configuration.width)
        heightSlider.value = Float(configuration.height)
    }

    @IBAction fileprivate func tiltChanged(_ sender: UISlider) {
        configuration.tilt = CGFloat(sender.value)
    }
    
    @IBAction fileprivate func swipeDistanceChanged(_ sender: UISlider) {
        configuration.swipeDistance = CGFloat(sender.value)
    }
    
    @IBAction fileprivate func swipeAxisTiltChanged(_ sender: UISlider) {
        configuration.swipeAxisTilt = CGFloat(sender.value)
    }

    @IBAction fileprivate func leftRightEnableChanged(_ sender: UISwitch) {
        configuration.leftRightSwipeEnabled = sender.isOn
        comboSwipeSwitch.isOn = configuration.comboSwipeEnabled
    }
    
    @IBAction fileprivate func downEnableChanged(_ sender: UISwitch) {
        configuration.downSwipeEnabled = sender.isOn
    }
    
    @IBAction fileprivate func comboEnableChanged(_ sender: UISwitch) {
        configuration.comboSwipeEnabled = sender.isOn
        leftRightSwipewitch.isOn = configuration.leftRightSwipeEnabled
    }

    @IBAction fileprivate func upEnableChanged(_ sender: UISwitch) {
        configuration.upSwipeEnabled = sender.isOn
    }

    @IBAction fileprivate func typeTapped(_ sender: UIButton) {
        let controller = UIAlertController(title: "Choose Button Type", message: nil, preferredStyle: .actionSheet)

        func handler(type: ButtonType) -> (UIAlertAction) -> Void {
            return { action in
                self.configuration.type = type
                self.pickTypeButton.setTitle(action.title, for: .normal)
            }
        }
        
        for type in ButtonType.allTypes {
            controller.addAction(.init(title: type.displayText, style: .default, handler: handler(type: type)))
        }

        controller.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction fileprivate func shapeSwipePaneChanged(_ sender: UISegmentedControl) {

        let showingOptionsView, hidingOptionsView: UIView
        let showingPreviewView, hidingPreviewView: UIView

        if sender.selectedSegmentIndex == 0 {
            (showingOptionsView, hidingOptionsView) = (shapeOptionsStackView, swipeOptionsStackView)
            (showingPreviewView, hidingPreviewView) = (shapeView, swipeAxisView)
        }
        else {
            (showingOptionsView, hidingOptionsView) = (swipeOptionsStackView, shapeOptionsStackView)
            (showingPreviewView, hidingPreviewView) = (swipeAxisView, shapeView)
        }

        UIView.animate(withDuration: 0.2) {
            hidingOptionsView.alpha = 0
            hidingPreviewView.alpha = 0
            showingOptionsView.alpha = 1
            showingPreviewView.alpha = 1
        }
    }

    @IBAction fileprivate func deleteTapped(_ sender: UIButton) {
        let controller = UIAlertController(title: "Remove this button?", message: nil, preferredStyle: .alert)
        controller.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(.init(title: "Yes", style: .destructive, handler: { [unowned self] _ in
            self.deleteButtonAction?()
        }))
        present(controller, animated: true, completion: nil)
    }

    @IBAction fileprivate func done(_ sender: UIButton) {
        editingDoneAction?(configuration)
    }

    override func viewDidLayoutSubviews() {
        let backgroundCenter = CGPoint(x: previewBackgroundView.bounds.midX, y: previewBackgroundView.bounds.midY)
        shapeView.center = backgroundCenter
        swipeAxisView.center = backgroundCenter
        axisOverlayView.center = CGPoint(x: swipeAxisView.bounds.midX, y: swipeAxisView.bounds.midY)

        super.viewDidLayoutSubviews()
    }

}


private extension ButtonEditorViewController {

    func moveSwipeOptionsInplace() {
        if swipeOptionsStackView.superview != nil {
            swipeOptionsStackView.removeFromSuperview()
        }

        optionsBackgroundView.addSubview(swipeOptionsStackView)
        swipeOptionsStackView.alpha = 0

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view" : swipeOptionsStackView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]-(>=0)-|", options: [], metrics: nil, views: ["view" : swipeOptionsStackView])
        )
    }
    
    func updatePreview() {
        guard shapeView != nil else { return }

        shapeView.configure(with: configuration)
        swipeAxisView.configure(with: configuration)
        axisOverlayView.configuration = configuration
        
        pickTypeButton.setTitle(configuration.type.displayText, for: .normal)

        widthLabel.text = "Width: \(Int(configuration.width))"
        heightLabel.text = "Height: \(Int(configuration.height))"
        cornerLabel.text = "Corner: \(Int(configuration.corner))"
        tiltLabel.text = "Tilt: \(Int(configuration.tilt))°"
        distanceLabel.text = "Activation Distance: \(Int(configuration.swipeDistance))"
        swipeAxisTiltLabel.text = "Swipe Direction Tilt: \(Int(configuration.swipeAxisTilt))°"
    }

    func repositionSlidersAndSwitches() {
        widthSlider.value = Float(configuration.width)
        heightSlider.value = Float(configuration.height)
        cornerSlider.value = Float(configuration.corner)
        tiltSlider.value = Float(configuration.tilt)

        distanceSlider.value = Float(configuration.swipeDistance)
        swipeAxisTiltSlider.value = Float(configuration.swipeAxisTilt)
        leftRightSwipewitch.isOn = configuration.leftRightSwipeEnabled
        downSwipeSwitch.isOn = configuration.downSwipeEnabled
        comboSwipeSwitch.isOn = configuration.comboSwipeEnabled
        upSwipeSwitch.isOn = configuration.upSwipeEnabled
    }

}


private extension UIView {

    func configure(with configuration: ButtonConfiguration) {
        bounds.size = CGSize(width: configuration.width, height: configuration.height)
        layer.cornerRadius = configuration.corner
        transform = CGAffineTransform(rotationAngle: -configuration.tilt * .pi / 180)
    }
    
}



