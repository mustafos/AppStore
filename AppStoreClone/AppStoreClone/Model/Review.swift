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
    let title: JSONLabel
    let author: Author
    
    let rating: JSONLabel
    
    private enum CodingKeys: String, CodingKey {
        case author
        case title
        case content
        
        case rating = "im:rating"
    }
}

struct Author: Codable {
    let name: JSONLabel
}

struct JSONLabel: Codable {
    let label: String
}
