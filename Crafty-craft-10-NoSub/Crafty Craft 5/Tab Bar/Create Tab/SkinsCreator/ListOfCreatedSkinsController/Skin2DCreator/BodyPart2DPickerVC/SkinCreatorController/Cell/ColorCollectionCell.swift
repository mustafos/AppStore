//
//  ColorCollectionCell.swift
//  Crafty Craft 5
//
//  Created by 1 on 31.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class ColorCollectionCell: UICollectionViewCell {
    
    private let selectedScale: CGFloat = 1.1
    private let unselectedScale: CGFloat = 1.0
    
    override var isSelected: Bool {
        didSet {

            if isSelected == true {
                self.transform = CGAffineTransform(scaleX: selectedScale, y: selectedScale)
            } else {
                self.transform = CGAffineTransform.identity
            }

            self.layoutSubviews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = 2
        contentView.layer.masksToBounds = true

    }
    
    func configCell(bgColor: UIColor, isSelected: Bool) {
        contentView.backgroundColor = bgColor
        self.isSelected = isSelected
    }


}
