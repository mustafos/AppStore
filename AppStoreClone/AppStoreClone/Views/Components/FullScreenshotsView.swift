//
//  FullScreenshotsView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 22.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct FullScreenshotsView: View {
    @Environment(\.dismiss) var dismiss
    let screenshotUrls: [String]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(screenshotUrls, id: \.self) { screenshort in
                        let width = proxy.size.width - 64
                        AsyncImage(url: URL(string: screenshort)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: width)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.top, 70)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: width)
                                .foregroundStyle(Color(.label))
                                .padding(.top, 70)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .secondary)
                        .font(.system(size: 28, weight: .semibold))
                        .padding()
                }
            }
        }
    }
}
