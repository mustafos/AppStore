//
//  SkinsRealmSession.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import RealmSwift

class SkinsRealmSession: Object, Identifiable {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name: String
    @Persisted var skinSourceImagePath: String
    @Persisted var skinImagePath: String
    @Persisted var isNew: Bool
    @Persisted var isFavorite: Bool
    @Persisted var skinImageData: Data?
    @Persisted var filterCategory: String

    convenience init(name: String, skinSourceImagePath: String, skinImagePath: String, isNew: Bool, isFavorite: Bool, skinImageData: Data?, filterCategory: String) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
        self.skinSourceImagePath = skinSourceImagePath
        self.skinImagePath = skinImagePath
        self.isNew = isNew
        self.isFavorite = isFavorite
        self.skinImageData = skinImageData
        self.filterCategory = filterCategory
    }
}

struct SkinsSession: Identifiable {
    let id: String
    let name: String
    let skinSourceImagePath: String
    let skinImagePath: String
    let isNew: Bool
    let isFavorite: Bool
    let skinImageData: Data?
    let filterCategory: String
}
