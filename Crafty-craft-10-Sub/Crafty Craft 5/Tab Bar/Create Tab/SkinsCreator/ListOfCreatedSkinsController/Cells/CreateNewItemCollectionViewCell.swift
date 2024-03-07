//
//  SkinNewCollectionViewCell.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class CreateNewItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundContainerView.roundCorners(27)
    }
    
    func setCrateTitle(_ title: String) {
        titleLabel.text = title
    }
}
