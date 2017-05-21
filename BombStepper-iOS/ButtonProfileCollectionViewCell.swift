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

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .green
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
    }

}





