//
//  SearchView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 03.06.2023.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct SearchView: View {
    
    @StateObject var vm = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    if vm.results.isEmpty && vm.query.isEmpty {
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
                            ForEach(vm.results) { result in
                                VStack(spacing: 16) {
                                    
                                    AppIconTitleView(result: result)
                                    
                                    ScreenshotsRow(proxy: proxy, result: result)
                                }
                                .padding(16)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $vm.query)
        }
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
