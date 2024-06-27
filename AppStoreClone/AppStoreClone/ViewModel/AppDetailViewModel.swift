//
//  AppDetailViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

struct APIServive {
    
    enum APIError: Error {
        case appDetailNotFound
        case badResponse(statusCode: Int)
    }
    
    static func fetchAppDetail(trackId: Int) async throws -> AppDetail {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(trackId)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200..<299 ~= statusCode) {
            throw APIError.badResponse(statusCode: statusCode)
        }
            
        let appDetailResults = try JSONDecoder().decode(AppDetailResults.self, from: data)
        if let appDetail = appDetailResults.results.first {
            return appDetail
        }
        throw APIError.appDetailNotFound
    }
}

@MainActor
class AppDetailViewModel: ObservableObject {
    @Published var appDetail: AppDetail?
    @Published var error: Error?
    
    private let treckId: Int
    init(treckId: Int) {
        self.treckId = treckId
        fetchJSONData()
    }
    
    private func fetchJSONData() -> Void {
        Task {
            do {
                self.appDetail = try await APIServive.fetchAppDetail(trackId: treckId)
            } catch {
                self.error = error
            }
        }
    }
}
