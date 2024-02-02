//
//  ContentFilterView.swift
//  Crafty Craft 10
//
//  Created by dev on 01.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI
//
//struct ContentFilterView: View {
//    @ObservedObject var viewModel: ContentFilterViewModel
//    var body: some View {
//        Menu {
//            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
//                Button {
//                    viewModel.selectButton(at: index)
//                } label: {
//                    Label(viewModel.buttons[index].label, image: index == 2 ? "lock button" : "")
//                }
//            }
//        } label: {
//            HStack {
//                Text(viewModel.buttons[viewModel.selectedIndex].label)
//                Spacer()
//                Image(systemName: "chevron.down")
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 8)
//            .frame(width: 350, height: 48, alignment: .center)
//            .font(Font.custom("Montserrat", size: 16).weight(.semibold))
//            .foregroundColor(.black)
//            .background(Color("YellowSelectiveColor"))
//            .cornerRadius(40)
//            .overlay(
//                RoundedRectangle(cornerRadius: 40)
//                    .stroke(Color("EerieBlackColor"),lineWidth: 1)
//                    .shadow(color: Color.black, radius: 2, x: -2, y: -2)
//                    .clipShape(
//                        RoundedRectangle(cornerRadius: 40)
//                    )
//            )
//        }
//        .shadow(radius: 5, x: 3, y: 3)
//    }
//    
//    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
//        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
//        }
//    }
//}
//
//struct ContentFilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentFilterView(viewModel: ContentFilterViewModel(buttons: [], onSelect: {_ in }))
//    }
//}

//import SwiftUI
//
//struct ContentFilterView: View {
//    @ObservedObject var viewModel: ContentFilterViewModel
//    @State var isShowingFilters: Bool = false
//    @State var filterName: String = "All"
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 24)
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 12) {
//                            ForEach(viewModel.buttons.indices, id: \.self) { item in
//                                if item != 0 {
//                                    Rectangle().frame(height: 1)
//                                        .foregroundStyle(.black)
//                                }
//                                Button {
//                                    withAnimation {
//                                        viewModel.selectButton(at: item)
//                                        filterName = viewModel.buttons[item].label
//                                        isShowingFilters.toggle()
//                                    }
//                                } label: {
//                                    HStack {
//                                        Text(viewModel.buttons[item].label)
//                                            .font(.custom("Montserrat-SemiBold", size: 16))
//                                            .foregroundStyle(Color("PopularGrayColor"))
//                                        Spacer()
//                                        if let icon = viewModel.buttons[item].icon {
//                                            Image(uiImage: icon)
//                                                .resizable()
//                                                .frame(width: 20)
//                                        }
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.vertical, 20)
//                    }
//                }
//                .overlay {
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(lineWidth: 1)
//                        .foregroundStyle(.gray)
//                }
//                .frame(height: isShowingFilters ? 240 : 48)
//                .offset(y: isShowingFilters ? 0 : -132)
//                .foregroundStyle(Color("YellowSelectiveColor"))
//                
//                ZStack {
//                    RoundedRectangle(cornerRadius: 24)
//                        .frame(height: 48)
//                        .foregroundStyle(Color("YellowSelectiveColor"))
//                    HStack {
//                        Text(filterName)
//                            .font(.custom("Montserrat-SemiBold", size: 16))
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24)
//                            .rotationEffect(.degrees(isShowingFilters ? -180 : 0))
//                    }
//                    .padding(.horizontal)
//                    .foregroundStyle(.black)
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(lineWidth: 1)
//                        .frame(height: 48)
//                }
//                .offset(y: -132)
//                .onTapGesture {
//                    withAnimation {
//                        isShowingFilters.toggle()
//                    }
//                }
//            }
//        }
//        .background(.yellow)
////        .padding(.vertical, 20)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .offset(y: 38)
//    }
//    
//    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
//        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
//        }
//    }
//}
//
//#Preview {
//    ContentFilterView(viewModel: ContentFilterViewModel(buttons: [], onSelect: {_ in }))
//}

//import SwiftUI
//
//struct MonolithDropdown: View {
//    @State var selection1: String? = nil
//    
//    var body: some View {
//        DropDownPicker(
//            selection: $selection1,
//            options: [
//                "Apple", "Google", "Amazon", "Facebook",
//                "Instagram", "Netflix", "Meta", "Tesla"
//            ]
//        )
//        .padding(.bottom, 300)
//    }
//}
//
//#Preview {
//    MonolithDropdown()
//}

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
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees((showFilters ? -180 : 0)))
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(.green)
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
            .background(.yellow)
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.gray)
            }
            .frame(height: 240, alignment: state == .up ? .bottom : .top)
            
        }
        .background(.red)
        .frame(width: .infinity, height: 48)
        .zIndex(zindex)
    }
    
    func OptionsView() -> some View {
        ScrollView {
            VStack {
                ForEach(viewModel.buttons.indices, id: \.self) { option in
                    if selection != viewModel.buttons[option].label {
                        HStack {
                            Text(viewModel.buttons[option].label)
                            Spacer()
                            // For sub version only
                            if let icon = viewModel.buttons[option].icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .frame(width: 20)
                            }
                        }
                        .foregroundStyle(Color.gray)
                        .animation(.none, value: selection)
                        .frame(height: 48)
                        .contentShape(.rect)
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
                                selection = viewModel.buttons[option].label
                                showFilters.toggle()
                                onStateChange?(showFilters ? .up : .down)
                            }
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
