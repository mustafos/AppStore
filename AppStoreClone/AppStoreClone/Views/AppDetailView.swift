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
        GeometryReader { proxy in
            if let error = vm.error {
                Text("Failed to fetch app details")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .font(.largeTitle)
                    .padding()
                    .multilineTextAlignment(.center)
            }
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
                    
                    previewScreenshots
                    
                    VStack(alignment: .leading) {
                        Text("Reviews")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ReviewsView(trackId: self.treckId, proxy: proxy)
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.vertical)
                        Text(appDetail.description)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    AsyncImage(url: URL(string: vm.appDetail?.artworkUrl512 ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 24, height: 24)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {} label: {
                        Image(systemName: "icloud.and.arrow.down")
                            .frame(width: 24)
                    }
                }
            }
        }
    }
    
    @State var isPresentingFullScreenScreenshots = false
    
    private var previewScreenshots: some View {
        VStack {
            Text("Preview")
                .font(.system(size: 24, weight: .semibold))
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(vm.appDetail?.screenshotUrls ?? [], id: \.self) { screenshort in
                        Button {
                            isPresentingFullScreenScreenshots.toggle()
                        } label: {
                            AsyncImage(url: URL(string: screenshort)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 350)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(width: 200, height: 350)
                                    .foregroundStyle(Color(.label))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $isPresentingFullScreenScreenshots) {
            FullScreenshotsView(screenshotUrls: vm.appDetail?.screenshotUrls ?? [])
        }
    }
}

#Preview {
    NavigationStack {
        AppDetailView(treckId: 547702041)
    }.preferredColorScheme(.dark)
}
