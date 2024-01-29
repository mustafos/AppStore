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
    var body: some View {
        Menu {
            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                Button {
                    viewModel.selectButton(at: index)
                } label: {
                    Label(viewModel.buttons[index].label, image: index == 2 ? "lock button" : "")
                }
            }
        } label: {
            HStack {
                Text(viewModel.buttons[viewModel.selectedIndex].label)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(width: 350, height: 48, alignment: .center)
            .font(Font.custom("Montserrat", size: 16).weight(.semibold))
            .foregroundColor(.black)
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
    }
    
    func updateButtons(newButtons: [ContentFilterModel], selectedIndex: Int = 0) {
        viewModel.updateButtons(newButtons: [newButtons[0]], selectedIdx: selectedIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateButtons(newButtons: newButtons, selectedIdx: selectedIndex)
        }
    }
}

struct ContentFilterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentFilterView(viewModel: ContentFilterViewModel(buttons: [], onSelect: {_ in }))
    }
}

//import SwiftUI
//
//struct ContentFilterView: View {
//    @ObservedObject var viewModel: ContentFilterViewModel
//    @State var show: Bool = false
//    @State var name: String = "Item 1"
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 17) {
//                            ForEach(viewModel.buttons.indices, id: \.self) { item in
//                                if item != 0 {
//                                    Rectangle().frame(height: 1)
//                                        .foregroundStyle(.black)
//                                }
//                                Button {
//                                    withAnimation {
//                                        viewModel.selectButton(at: item)
//                                        name = viewModel.buttons[item].label
//                                        show.toggle()
//                                    }
//                                } label: {
//                                    HStack {
//                                        Text(viewModel.buttons[item].label)
//                                            .font(.custom("Montserrat-SemiBold", size: 16))
//                                            .foregroundStyle(.gray)
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
//                        .padding(.vertical, 15)
//                    }
//                }
//                .overlay {
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(lineWidth: 1)
//                        .foregroundStyle(.black)
//                        .padding(5)
//                }
//                .frame(height: show ? 240 : 50)
//                .offset(y: show ? 0 : -135)
//                .foregroundStyle(Color("YellowSelectiveColor"))
//                
//                ZStack {
//                    RoundedRectangle(cornerRadius: 24)
//                        .frame(height: 48)
//                        .foregroundStyle(Color("YellowSelectiveColor"))
//                    HStack {
//                        Text(name)
//                            .font(.custom("Montserrat-SemiBold", size: 16))
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24)
//                            .rotationEffect(.degrees(show ? -180 : 0))
//                    }
//                    .padding(.horizontal)
//                    .foregroundStyle(.black)
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(lineWidth: 1)
//                        .frame(height: 48)
////                        .padding(1)
//                }
//                .offset(y: -133)
//                .onTapGesture {
//                    withAnimation {
//                        show.toggle()
//                    }
//                }
//            }
//        }
//        .padding()
//        .frame(height: 280).offset(y: 40)
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

//// Pop-up button
//let colorClosure = { (action: UIAction) in
//    updateColor(action.title)
//}
//
//let button = UIButton(primaryAction: nil)
//
//button.menu = UIMenu(children: [
//    UIAction(title: "Bondi Blue", handler: colorClosure),
//    UIAction(title: "Flower Power", state: .on, handler: colorClosure)
//])
//
//button.showsMenuAsPrimaryAction = true
//
//button.changesSelectionAsPrimaryAction = true
//
//// Update to the currently set one
//updateColor(button.menu?.selectedElements.first?.title)
//
//// Update the selection
//(button.menu?.children[selectedColorIndex()] as? UIAction)?.state = .on
