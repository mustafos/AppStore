//
//  FontManager.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

enum BlinkerFont: String {
    case semiBold = "Blinker-SemiBold"
    case regural = "Blinker-Regular"
}

extension UIFont {
    static func blinkerFont(_ type: BlinkerFont, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: type.rawValue, size: size) else {
            return .systemFont(ofSize: size)
        }
        return customFont
    }
}
