//
//  String+CaseInsesetive.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 30.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

extension String {
    func containsCaseInsesetive(_ str: Self) -> Bool {
        self.lowercased().contains(str.lowercased())
    }
}
