//
//  Decodable+Dictionary.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

extension Decodable {
    init<Key: Hashable>(dict: [Key: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
