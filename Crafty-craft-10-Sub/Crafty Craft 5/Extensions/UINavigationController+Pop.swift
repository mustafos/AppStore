//
//  UINavigationController+Pop.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
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
