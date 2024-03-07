//
//  UIImageView+Border.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setBorder(size: CGFloat, color: UIColor) {
        self.layer.borderWidth = size
        self.layer.borderColor = color.cgColor
    }
}
