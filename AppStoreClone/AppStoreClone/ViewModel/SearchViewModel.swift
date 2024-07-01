//
//  SearchViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 16.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation
import Combine

@Observable
class SearchViewModel {
    
    var results: [Result] = [Result]()
    var isSearching = false
    
    var query = "DriverPro" {
        didSet {
            if oldValue != query {
                queryPublisher.send(query)
            }
        }
    }
    
    private var queryPublisher = PassthroughSubject<String, Never>()
    
    private var cancellablas = Set<AnyCancellable>()
    
    init() {
        queryPublisher
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                self.fetchJSONData(searchValue: newValue)
            }.store(in: &cancellablas)
    }
    
    private func fetchJSONData(searchValue: String) {
        Task {
            do {
                self.isSearching = true
                self.results = try await APIService.fetchSearchResults(searchValue: searchValue)
                self.isSearching = false
            } catch {
                self.isSearching = false
                print("Failed due to error:", error)
            }
        }
    }
}
