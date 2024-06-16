//
//  Result.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 16.06.2024.
//  Copyright © 2023 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct Result: Codable, Identifiable {
    
    var id: Int { trackId }
    let trackId: Int
    let trackName: String
    let artworkUrl512: String
    let primaryGenreName: String
    let screenshotUrls: [String]
}

struct SearchResult: Codable {
    let results: [Result]
}
