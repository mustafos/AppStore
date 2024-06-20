//
//  AppIconTitleView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 17.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

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
                
                HStack(spacing: 0) {
                    ForEach(0..<Int(result.averageUserRating), id: \.self) { num in
                        Image(systemName: "star.fill")
                    }
                    
                    ForEach(0..<5 - Int(result.averageUserRating), id: \.self) { num in
                        Image(systemName: "star")
                    }
                    
                    Text(result.userRatingCount.roundedWiThAbbreviations)
                        .padding(.leading, 4)
                }.padding(.top, 0)
            }
            
            Spacer()
            
            Button {
                // save app
            } label: {
                Image(systemName: "icloud.and.arrow.down")
                    .font(.system(size: 24))
            }
        }
    }
}
