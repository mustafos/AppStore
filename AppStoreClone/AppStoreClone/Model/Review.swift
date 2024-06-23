//
//  Review.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 23.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

struct ReviewResult: Codable {
    let feed: ReviewFeed
}

struct ReviewFeed: Codable {
    let entry: [Review]
}

struct Review: Codable, Identifiable {
    var id: String { content.label }
    let content: JSONLabel
}

struct JSONLabel: Codable {
    let label: String
}
