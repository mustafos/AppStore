//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 16.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var results: [Result] = [Result]()
    @Published var query = "DriverPro"
    
    private var cancellablas = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                self.fetchJSONData(searchValue: newValue)
            }.store(in: &cancellablas)
    }
    
    private func fetchJSONData(searchValue: String) {
        Task {
            do {
                guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchValue)&entity=software") else { return }
                let (data, _) = try await URLSession.shared.data(from: url)
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                self.results = searchResult.results
            } catch {
                print("Failed due to error:", error)
            }
        }
    }
}
