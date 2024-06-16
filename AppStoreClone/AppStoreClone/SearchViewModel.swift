//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 16.06.2024.
//  Copyright © 2023 Mustafa Bekirov. All rights reserved.

import SwiftUI

class SearchViewModel: ObservableObject {
    
    @Published var results: [Result] = [Result]()
    
    init() {
        fetchJSONData()
    }
    
    private func fetchJSONData() {
        Task {
            do {
                guard let url = URL(string: "https://itunes.apple.com/search?term=driverpro&entity=software") else { return }
                let (data, _) = try await URLSession.shared.data(from: url)
                print(data)
                
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                searchResult.results.prefix(3).forEach { result in
                    print(result.trackName)
                }
                self.results = searchResult.results
            } catch {
                print("Failed due to error:", error)
            }
        }
    }
}
