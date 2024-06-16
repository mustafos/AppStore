//
//  SearchView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 03.06.2023.
//  Copyright © 2023 Mustafa Bekirov. All rights reserved.

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

struct AppIconTitleView: View {
    let result: Result
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: result.artworkUrl512)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading) {
                Text(result.trackName)
                    .lineLimit(1)
                    .font(.system(size: 20))
                Text(result.primaryGenreName)
                    .foregroundStyle(.secondary)
                Text("STARS 1.5M")
            }
            
            Spacer()
            
            Image(systemName: "icloud.and.arrow.down")
        }
    }
}

struct ScreenshotsRow: View {
    let proxy: GeometryProxy
    let result: Result
    var body: some View {
        let width = (proxy.size.width - 4 * 16) / 3
        
        HStack(spacing: 16) {
            ForEach(result.screenshotUrls.prefix(3), id: \.self) { screenshotsURL in
                AsyncImage(url: URL(string: screenshotsURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: width, height: 200)
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
