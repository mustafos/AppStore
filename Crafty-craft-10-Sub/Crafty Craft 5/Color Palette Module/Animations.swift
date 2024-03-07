//
//  Animations.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

/// Convenience class for animating our selectors.
class Animations {
    
    internal static func animateScale(view: UIView, byScale: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            view.transform = CGAffineTransform(scaleX: byScale,y: byScale)
        }
    }
    
    internal static func animateScaleReset(view: UIView) {
        UIView.animate(withDuration: 0.25) {
            view.transform = CGAffineTransform(scaleX: 1,y: 1)
        }
    }
}
