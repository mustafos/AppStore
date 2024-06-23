//
//  AppDetailViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

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
        Task {
            do {
                guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(treckId)") else { return }
                let (data, _) = try await URLSession.shared.data(from: url)
                let appDetailResults = try JSONDecoder().decode(AppDetailResults.self, from: data)
                appDetailResults.results.forEach { appDetail in
                    print(appDetail.description)
                }
                
                self.appDetail = appDetailResults.results.first
                
            } catch {
                print("Faild fetching app detail:", error)
            }
        }
    }
}
