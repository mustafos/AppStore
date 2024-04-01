//
//  TintedTextField.swift
//  Crafty Craft 5
//
//  Created by dev on 31.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class TintedTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        if let button = subviews.first(where: { $0 is UIButton }) as? UIButton,
           let image = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
        }
    }
}
