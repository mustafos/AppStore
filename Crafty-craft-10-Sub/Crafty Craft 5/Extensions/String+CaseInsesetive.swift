//
//  String+CaseInsesetive.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension String {
    func containsCaseInsesetive(_ str: Self) -> Bool {
        self.lowercased().contains(str.lowercased())
    }
}
