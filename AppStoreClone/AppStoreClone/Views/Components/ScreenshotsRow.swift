//
//  ScreenshotsRow.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 17.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

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
