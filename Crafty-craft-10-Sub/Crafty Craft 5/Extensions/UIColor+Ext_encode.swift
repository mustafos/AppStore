//
//  UIcolor+Ext_encode.swift
//  Crafty Craft 5
//
//  Created by 1 on 31.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//
import UIKit


extension UIColor {
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    static func decode(from data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
}
