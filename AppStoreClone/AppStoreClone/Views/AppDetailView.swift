//
//  AppDetailView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 21.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI

struct AppDetailView: View {
    @StateObject var vm: AppDetailViewModel
    
    let treckId: Int
    
    init(treckId: Int) {
        self._vm = .init(wrappedValue: AppDetailViewModel(treckId: treckId))
        self.treckId = treckId
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let appDetail = vm.appDetail {
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: appDetail.artworkUrl512)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        Text(appDetail.trackName)
                            .font(.system(size: 24, weight: .semibold))
                        Text(appDetail.artistName)
                        Image(systemName: "icloud.and.arrow.down")
                            .font(.system(size: 24))
                            .padding(.vertical, 4)
                    }
                    
                    Spacer()
                }.padding()
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("What's New")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.vertical)
                        Spacer()
                        Button {} label: {
                            Text("Verion History")
                        }
                    }
                    Text(appDetail.releaseNotes)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.vertical)
                    Text(appDetail.description)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppDetailView(treckId: 6474212227)
    }.preferredColorScheme(.dark)
}
