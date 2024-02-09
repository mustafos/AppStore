//
//  SkinNewCollectionViewCell.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
