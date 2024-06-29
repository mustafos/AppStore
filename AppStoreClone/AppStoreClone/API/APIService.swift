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
        case badData
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
    
    static func dummyInvokingFunction() -> Void {
        // old legacy completion handler style
        legacyFetchReviews(trackId: 1234) { result in
            switch result {
            case .success(let reviews):
                DispatchQueue.main.async {
                    print(reviews)
                }
            case .failure(let error):
                print("Failed to fetch reviews:", error)
            }
        }
        
        // async await
        Task {
            let reviews = try await asyncLegacyFetchReviews(trackId: 1234)
            let appDetails = try await fetchAppDetail(trackId: 1234)
            print(reviews)
        }
    }
    
    static func asyncLegacyFetchReviews(trackId: Int) async throws -> [Review] {
        try await withCheckedThrowingContinuation { continuation in
            legacyFetchReviews(trackId: trackId) { result in
                switch result {
                case .success(let reviews):
                    continuation.resume(returning: reviews)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    static func legacyFetchReviews(trackId: Int, completion: @escaping (Swift.Result<[Review], Error>) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/rss/customerreviews/page=1/id=\(trackId)/sortby=mostrecent/json?l=en&cc=us") else {
            completion(.failure(APIError.badUrl))
            return
        }
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200..<299 ~= statusCode) {
                completion(.failure(APIError.badResponse(statusCode: statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(APIError.badData))
                return
            }
            
            // success of fetching data
            do {
                let reviewsResults: ReviewResult = try JSONDecoder().decode(ReviewResult.self, from: data)
                completion(.success(reviewsResults.feed.entry))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
