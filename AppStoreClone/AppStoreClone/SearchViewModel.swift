//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 16.06.2024.
//  Copyright © 2023 Mustafa Bekirov. All rights reserved.

import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var results: [Result] = [Result]()
    @Published var query = ""
    
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
                //                print(data)
                
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                //                searchResult.results.prefix(3).forEach { result in
                //                    print(result.trackName)
                //                }
                //                DispatchQueue.main.async {    /*old*/
                //                Task { @MainActor in          /*new*/
                self.results = searchResult.results
            } catch {
                print("Failed due to error:", error)
            }
        }
    }
}
