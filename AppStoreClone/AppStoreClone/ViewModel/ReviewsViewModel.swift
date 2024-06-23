//
//  ReviewsViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 23.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

class ReviewsViewModel: ObservableObject {
    
    @Published var entries: [Review] = [Review]()
    
    private let trackId: Int
    
    init(trackId: Int) {
        self.trackId = trackId
        fetchReviews()
    }
    
    private func fetchReviews() -> Void {
        Task {
            do {
                guard let url = URL(string: "https://itunes.apple.com/rss/customerreviews/page=1/id=\(trackId)/sortby=mostrecent/json?l=en&cc=us") else { return }
                let (data, _) = try await URLSession.shared.data(from: url)
                let reviewsResults = try JSONDecoder().decode(ReviewResult.self, from: data)
                self.entries = reviewsResults.feed.entry
            } catch {
                print("Failed to fetch reviews:", error)
            }
        }
    }
}
