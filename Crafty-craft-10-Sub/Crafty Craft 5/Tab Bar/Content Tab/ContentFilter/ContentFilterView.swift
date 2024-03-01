//
//  ContentFilterView.swift
//  Crafty Craft 5
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
    @State var selection: String?
    @State var showFilters = false
    var state: DropDownPickerState = .down
    var onStateChange: ((DropDownPickerState) -> Void)?
    @SceneStorage("drop_down_zindex") private var index = 100.0
    @State var zindex = 100.0
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if state == .up && showFilters {
                    ScrollView {
                        OptionsView()
                    }
                    .frame(maxHeight: geometry.size.height - 48)
                }
                
                HStack {
                    Text(selection == nil ? "All" : selection!)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: state == .up ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.black)
                        .rotationEffect(.degrees((showFilters ? -180 : 0)))
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(Color("YellowSelectiveColor"))
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        showFilters.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .down && showFilters {
                    OptionsView()
                }
            }
            .clipped()
            .background(Color("YellowSelectiveColor"))
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.black)
            }
            .frame(height: 240, alignment: state == .up ? .bottom : .top)
            
        }
        .frame(width: .infinity, height: 240)
        .zIndex(zindex)
    }
    
    func OptionsView() -> some View {
        ScrollView {
            VStack {
                ForEach(viewModel.buttons.indices.filter { selection != viewModel.buttons[$0].label }, id: \.self) { option in
                    let button = viewModel.buttons[option]
                    HStack {
                        Text(button.label)
                        Spacer()
                        
                        if button.isLocked, let cornerIcon = button.cornerIcon {
                            Image(uiImage: cornerIcon)
                                .resizable()
                                .frame(width: 20, height: 16)
                        }
                    }
                    .foregroundStyle(Color("PopularGrayColor"))
                    .animation(.none, value: selection)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 20)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 60)
                    )
                    .onTapGesture {
                        withAnimation(.snappy) {
                            viewModel.selectButton(at: option)
                            selection = button.isLocked ? viewModel.buttons[2].label : viewModel.buttons[option].label
                            showFilters.toggle()
                            onStateChange?(showFilters ? .up : .down)
                        }
                    }
                }
            }
            .transition(.move(edge: state == .up ? .bottom : .top))
            .zIndex(1)
        }
    }
    
    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
        }
    }
}
