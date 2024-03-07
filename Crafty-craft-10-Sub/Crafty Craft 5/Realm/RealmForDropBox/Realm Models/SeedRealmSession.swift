//
//  SeedRealmModel.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import RealmSwift

class SeedRealmSession: Object, Identifiable {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name: String
    @Persisted var seedImagePath: String
    @Persisted var seedDescrip: String
    @Persisted var seed: String
    @Persisted var isNew: Bool
    @Persisted var seedImageData: Data?
    

    convenience init(name: String, seedImagePath: String, seedDescrip: String, isNew: Bool, seed: String, seedImageData: Data? = nil) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
        self.seedImagePath = seedImagePath
        self.seedDescrip = seedDescrip
        self.isNew = isNew
        self.seed = seed
        self.seedImageData = seedImageData
    }
}

struct SeedSession: Identifiable {
    let id: String
    let name: String
    let seedImagePath: String
    let seedDescrip: String
    let isNew: Bool
    let seed: String
    let imageData: Data?
}
