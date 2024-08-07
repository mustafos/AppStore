//
//  SearchView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 03.06.2023.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct SearchView: View {
    
    @State var manager = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    if manager.results.isEmpty && manager.query.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                            Text("Please enter your search terms above")
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            ForEach(manager.results) { result in
                                NavigationLink {
                                    AppDetailView(treckId: result.trackId)
                                } label: {
                                    VStack(spacing: 16) {
                                        AppIconTitleView(result: result)
                                        
                                        ScreenshotsRow(proxy: proxy, result: result)
                                    }
                                    .foregroundStyle(Color(.label))
                                    .padding(16)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $manager.query)
        }
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
