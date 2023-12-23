//
//  FontManager.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

enum MontserratFont: String {
    case semiBold = "Montserrat-SemiBold"
    case bold = "Montserrat-Bold"
    case regural = "Montserrat-Regular"
}

extension UIFont {
    static func montserratFont(_ type: MontserratFont, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: type.rawValue, size: size) else {
            return .systemFont(ofSize: size)
        }
        return customFont
    }
}
