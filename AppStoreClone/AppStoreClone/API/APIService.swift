//
//  APIService.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 28.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

struct APIService {
    
    enum APIError: Error {
        case appDetailNotFound
        case badResponse(statusCode: Int)
        case badUrl
    }
    
    static func fetchAppDetail(trackId: Int) async throws -> AppDetail {
        let appDetailResults: AppDetailResults = try await decode(urlString: "https://itunes.apple.com/lookup?id=\(trackId)")
        if let appDetail = appDetailResults.results.first {
            return appDetail
        }
        throw APIError.appDetailNotFound
    }
    
    static func fetchSearchResults(searchValue: String) async throws -> [Result] {
        let serchResult: SearchResult = try await decode(urlString: "https://itunes.apple.com/search?term=\(searchValue)&entity=software")
        return serchResult.results
    }
    
    static func fetchReviews(trackId: Int) async throws -> [Review] {
        let reviewsResults: ReviewResult = try await decode(urlString: "https://itunes.apple.com/rss/customerreviews/page=1/id=\(trackId)/sortby=mostrecent/json?l=en&cc=us")
        return reviewsResults.feed.entry
    }
    
    static private func decode<T: Codable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw APIError.badUrl }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200..<299 ~= statusCode) {
            throw APIError.badResponse(statusCode: statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
