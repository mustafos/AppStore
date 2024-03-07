//
//  UIImageView+Border.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 24.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setBorder(size: CGFloat, color: UIColor) {
        self.layer.borderWidth = size
        self.layer.borderColor = color.cgColor
    }
}
