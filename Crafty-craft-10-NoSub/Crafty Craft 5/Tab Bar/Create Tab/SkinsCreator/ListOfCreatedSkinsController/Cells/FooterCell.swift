//
//  FooterCell.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 03.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class FooterCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Customize your footer view here
        backgroundColor = .red // Example color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
