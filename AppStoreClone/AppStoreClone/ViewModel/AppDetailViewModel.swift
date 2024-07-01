//
//  AppDetailViewModel.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import Foundation

@Observable
class AppDetailViewModel {
    
    var appDetail: AppDetail?
    var error: Error?
    
    private let treckId: Int
    init(treckId: Int) {
        self.treckId = treckId
        fetchJSONData()
    }
    
    private func fetchJSONData() -> Void {
        Task {
            do {
                self.appDetail = try await APIService.fetchAppDetail(trackId: treckId)
            } catch {
                self.error = error
            }
        }
    }
}
