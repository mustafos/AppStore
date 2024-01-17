//
//  CustomTabBar.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 28.12.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

//import SwiftUI
//
//enum Tab: String, CaseIterable {
//    case create
//    case content
//    case seeds
//    case servers
//}
//
//struct CustomTabBar: View {
//    @State private var selectedTab: Tab = .create
//    
//    init() {
//        UITabBar.appearance().isHidden = true
//    }
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                TabView(selection: $selectedTab) {
//                    ForEach(Tab.allCases, id: \.rawValue) { tab in
//                        Group {
//                            switch tab {
//                            case .create:
//                                Text("Create Screen")
//                            case .content:
//                                Text("Content Screen")
//                            case .seeds:
//                                Text("Seeds Screen")
//                            case .servers:
//                                Text("Servers Screen")
//                            }
//                        }
//                        .tag(tab)
//                        .ignoresSafeArea()
//                    }
//                }
//            }
//            VStack {
//                Spacer()
//                TabBarItems(selectedTab: $selectedTab)
//            }
//        }
//    }
//}
//
//#Preview {
//    CustomTabBar()
//}
