//
//  HueDelegate.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import UIKit


/// Delegate used for writing back hue updates from the HueView.
internal protocol HueDelegate {
    func didUpdateHue(hue: CGFloat)
}
