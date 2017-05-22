//
//  ButtonProfileCollectionViewCell.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/3/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


final class ButtonProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!   // Don't set image directly on this, use the specialized function instead
    @IBOutlet var selectionSwitch: UISwitch!
    private var imageAspectRatio: NSLayoutConstraint?

    var selectionAction: ((_ isSelected: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.yellow.withAlphaComponent(0.15)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
        imageView.image = nil
    }

    @IBAction func selectionSwitchChanged(_ sender: UISwitch) {
        selectionAction?(sender.isOn)
    }

    func setImageAndAdjustAspectRatio(_ image: UIImage?) {
        imageView.image = image
        imageAspectRatio?.isActive = false
        if let image = image {
            let ratio = image.size.width / image.size.height
            imageAspectRatio = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: ratio)
            imageAspectRatio?.isActive = true
        }
    }

}





