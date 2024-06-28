//
//  ReviewsViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 23.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

class ReviewsViewModel: ObservableObject {
    
    @Published var entries: [Review] = [Review]()
    @Published var error: Error?
    
    private let trackId: Int
    
    init(trackId: Int) {
        self.trackId = trackId
        fetchReviews()
    }
    
    private func fetchReviews() {
        Task {
            do {
                self.entries = try await APIService.fetchReviews(trackId: trackId)
            } catch {
                print("Failed to fetch reviews:", error)
                self.error = error
            }
        }
    }
}
