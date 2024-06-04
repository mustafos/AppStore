//
//  ContentView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 03.06.2023.
//  Copyright © 2023 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    ForEach(0..<10) { num in
                        VStack(spacing: 16) {
                            
                            AppIconTitleView()
                            
                            ScreenshotsRow(proxy: proxy)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: .constant("Enter search term"))
        }
    }
}

struct AppIconTitleView: View {
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 80, height: 80)
            VStack(alignment: .leading) {
                Text("DriverPro: Plan, Study, Test!")
                    .lineLimit(1)
                    .font(.system(size: 20))
                Text("Education")
                    .foregroundStyle(.secondary)
                Text("STARS 1.5M")
            }
            
            Image(systemName: "icloud.and.arrow.down")
        }
    }
}

struct ScreenshotsRow: View {
    let proxy: GeometryProxy
    var body: some View {
        let width = (proxy.size.width - 4 * 16) / 3
        
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: width, height: 200)
            RoundedRectangle(cornerRadius: 12)
                .frame(width: width, height: 200)
            RoundedRectangle(cornerRadius: 12)
                .frame(width: width, height: 200)
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
