//
//  ContentFilterView.swift
//  Crafty Craft 10
//
//  Created by dev on 01.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI

enum DropDownPickerState {
    case up
    case down
}

struct ContentFilterView: View {
    @ObservedObject var viewModel: ContentFilterViewModel
    @State private var state: DropDownPickerState = .down
    var onStateChange: ((DropDownPickerState) -> Void)?
    @SceneStorage("drop_down_zindex") private var index = 100.0
    @State private var zindex = 100.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if state == .up && !viewModel.isDropdownVisible {
                    ScrollView {
                        VStack {
                            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                                viewModel.buttonView(for: index)
                                    .onTapGesture {
                                        withAnimation(.snappy) {
                                            viewModel.selectButton(at: index)
                                            onStateChange?(viewModel.isDropdownVisible ? .up : .down)
                                        }
                                    }
                            }
                        }
                        .transition(.move(edge: state == .up ? .bottom : .top))
                        .zIndex(1)
                    }
                    .frame(maxHeight: geometry.size.height - 48)
                }
                
                HStack {
                    Text(viewModel.buttons[viewModel.selectedIndex].label)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: state == .up ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.black)
                        .rotationEffect(.degrees((viewModel.isDropdownVisible ? -180 : 0)))
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(Color("YellowSelectiveColor"))
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        viewModel.isDropdownVisible.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .down && viewModel.isDropdownVisible {
                    ScrollView {
                        VStack {
                            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                                if index != viewModel.selectedIndex {
                                    viewModel.buttonView(for: index)
                                        .onTapGesture {
                                            withAnimation(.snappy) {
                                                viewModel.selectButton(at: index)
                                                onStateChange?(viewModel.isDropdownVisible ? .up : .down)
                                            }
                                        }
                                }
                            }
                        }
                        .transition(.move(edge: state == .up ? .bottom : .top))
                        .zIndex(1)
                    }
                }
            }
            .clipped()
            .background(Color("YellowSelectiveColor"))
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.black)
            }
            .frame(height: viewModel.isDropdownVisible ? 240 : 48, alignment: state == .up ? .bottom : .top)
            
        }
        .frame(width: .infinity, height: 240)
        .zIndex(zindex)
    }

    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
        }
    }
}
