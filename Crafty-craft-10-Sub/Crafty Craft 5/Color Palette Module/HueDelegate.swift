//
//  HueDelegate.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit


/// Delegate used for writing back hue updates from the HueView.
internal protocol HueDelegate {
    func didUpdateHue(hue: CGFloat)
}
