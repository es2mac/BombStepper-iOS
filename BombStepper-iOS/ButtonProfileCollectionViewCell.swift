//
//  ButtonProfileCollectionViewCell.swift
//  BombStepper-iOS
//
//  Created by Paul on 5/3/17.
//  Copyright © 2017 Mathemusician.net. All rights reserved.
//

import UIKit


final class ButtonProfileCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundView = UIView()
    }

    override var isSelected: Bool {
        didSet {
            backgroundView!.backgroundColor = isSelected ? .green : .clear
        }
    }

}





