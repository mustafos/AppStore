//
//  PikkoDelegate.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

/// Delegate which propagates color changes of the colorpicker to its delegate.
public protocol PikkoDelegate {
    func writeBackColor(color: UIColor)
}
