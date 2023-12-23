//
//  CategoryOptionHeaderSection.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 16.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

class CategoryOptionHeaderSection: UIView {
    lazy var title: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.montserratFont(.semiBold, size: 20)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        self.title.text = title
        setupTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupTitle() {
        self.addSubview(title)
        title.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        title.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
}

