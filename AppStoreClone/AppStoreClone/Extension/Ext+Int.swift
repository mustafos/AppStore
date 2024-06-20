//
//  Ext+Int.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 17.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

extension Int {
    var roundedWiThAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round (thousand * 10) / 10)K"
        } else {
            return "\(self)"
        }
    }
}
