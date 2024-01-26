//
//  ContentFilterView.swift
//  Crafty Craft 10
//
//  Created by dev on 01.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI

struct ContentFilterView: View {
    @ObservedObject var viewModel: ContentFilterViewModel
    @State var show: Bool = true
    @State var name: String = "Item 1"
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 17) {
                            ForEach(viewModel.buttons.indices, id: \.self) { item in
                                if item != 0 {
                                    Rectangle().frame(height: 1)
                                        .foregroundStyle(.gray)
                                }
                                Button {
                                    withAnimation {
                                        viewModel.selectButton(at: item)
                                        name = viewModel.buttons[item].label
                                        show.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.buttons[item].label)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.black)
                                        Spacer()
                                        if let icon = viewModel.buttons[item].icon {
                                            Image(uiImage: icon)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 15)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.gray)
                        .padding(1)
                }
                .frame(height: show ? 200 : 50)
                .offset(y: show ? 0 : -135)
                .foregroundStyle(.ultraThinMaterial)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10).frame(height: 60)
                        .foregroundStyle(.white)
                    HStack {
                        Text(name)
                            .font(.title2)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(show ? -180 : 0))
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.black)
                    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).frame(height: 60)
                        .padding(1)
                }
                .offset(y: -133)
                .onTapGesture {
                    withAnimation {
                        show.toggle()
                    }
                }
            }
        }
        .padding()
        .frame(height: 280).offset(y: 40)
    }
    
    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
        }
    }
}

#Preview {
    ContentFilterView(viewModel: ContentFilterViewModel(buttons: [], onSelect: {_ in }))
}
