//
//  TabBarItems.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 28.12.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI

struct TabBarItems: View {
    @Binding var selectedTab: Tab
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    ZStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = tab
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 8) {
                                Image(tab.rawValue)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(selectedTab == tab ? Color("BeigeColor") : Color("EerieBlackColor"))
                                    .font(.system(size: 22))
                                if selectedTab == tab {
                                    Text("\(tab.rawValue.capitalized)")
                                        .font(Font.custom("Montserrat", size: 16))
                                        .foregroundStyle(Color("BeigeColor"))
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(selectedTab == tab ? Color.black : .clear)
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 76)
            .background(Color("YellowSelectiveColor"))
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color("EerieBlackColor"),lineWidth: 1)
                    .shadow(color: Color.black, radius: 2, x: -2, y: -2)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 40)
                    )
            )
        }
        .shadow(radius: 5, x: 3, y: 3)
        .padding(.horizontal, 10)
        .padding(.bottom)
    }
}
