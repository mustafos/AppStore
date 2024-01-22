//
//  UIView+Constraints.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 14.11.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult
    func centerInSuperview() -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: superview!.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview!.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}


