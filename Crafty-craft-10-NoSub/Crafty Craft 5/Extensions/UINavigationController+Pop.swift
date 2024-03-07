//
//  UINavigationController+Pop.swift
//  Crafty Craft 5
//
//  Created by dev on 16.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

extension UINavigationController {
    func pop(to controller: UIViewController.Type, animated: Bool = true) {
        if let controller = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            popToViewController(controller, animated: animated)
        } else {
            popViewController(animated: animated)
        }
    }
}
