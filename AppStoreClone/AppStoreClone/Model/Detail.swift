//
//  Detail.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

struct AppDetailResults: Codable {
    let resultCount: Int
    let results: [AppDetail]
}

struct AppDetail: Codable {
    let artistName: String
    let trackName: String
    let releaseNotes: String
    let description: String
    let screenshotUrls: [String]
    let artworkUrl512: String
}
