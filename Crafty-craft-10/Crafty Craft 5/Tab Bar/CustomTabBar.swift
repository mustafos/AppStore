//
//  CustomTabBar.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 28.12.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case create
    case content
    case seeds
    case servers
}

struct CustomTabBar: View {
    @State private var selectedTab: Tab = .create
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.rawValue) { tab in
                        Group {
                            switch tab {
                            case .create:
                                Text("Hello")
                            case .content:
                                Text("Hello")
                            case .seeds:
                                Text("Hello")
                            case .servers:
                                Text("Hello")
                            }
                        }
                        .tag(tab)
                        .ignoresSafeArea()
                    }
                }
            }
            VStack {
                Spacer()
                TabBarItems(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    CustomTabBar()
}
