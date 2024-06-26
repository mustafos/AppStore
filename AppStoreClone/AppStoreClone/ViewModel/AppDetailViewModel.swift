//
//  AppDetailViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

struct APIServive {
    static func fetchAppDetail(trackId: Int) async throws -> AppDetail {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(trackId)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        let appDetailResults = try JSONDecoder().decode(AppDetailResults.self, from: data)
        return appDetailResults.results.first
    }
}

@MainActor
final class AppDetailViewModel: ObservableObject {
    
    @Published var appDetail: AppDetail?
    
    private let treckId: Int
    
    init(treckId: Int) {
        self.treckId = treckId
        print("Fetch JSON data for app detail")
        fetchJSONData()
    }
    
    private func fetchJSONData() -> Void {
        self.appDetail = APIServive.fetchAppDetail()
        Task {
            do {
                guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(treckId)") else { return }
                let (data, response) = try await URLSession.shared.data(from: url)
                let appDetailResults = try JSONDecoder().decode(AppDetailResults.self, from: data)
                self.appDetail = appDetailResults.results.first
            } catch {
                print("Faild fetching app detail:", error)
            }
        }
    }
}
