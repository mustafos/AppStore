//
//  ContentFilterView.swift
//  Crafty Craft 5
//
//  Created by dev on 01.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import SwiftUI

struct ContentFilterView: View {
    @ObservedObject var viewModel: ContentFilterViewModel

    var body: some View {
        Picker(selection: $viewModel.selectedIndex, label: Text("")) {
            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                Text(viewModel.buttons[index].label).tag(index)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: viewModel.selectedIndex) { newIndex in
            viewModel.selectButton(at: newIndex)
        }
        .frame(width: 150)  // Adjust the width according to your design
        .padding(8)
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
// TODO: – Second variant of Picker use UIHostingController correctly
//struct PickerMenu: View {
//    @ObservedObject var viewModel: ContentFilterViewModel
//    @State private var selection: String = "All"
//    var body: some View {
//        VStack {
//            DropDown(content: viewModel.buttons.map { $0.label }, selection: $selection, activeTint: .primary.opacity(0.1), inActiveTint: .white.opacity(0.05), dynamic: false)
//                            .frame(width: 130)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//        .background {
//            Color(.blue)
//                .ignoresSafeArea()
//        }
//    }
//}
//
//#Preview {
//    PickerMenu(viewModel: ContentFilterViewModel(buttons: [], onSelect: {_ in }))
//}
//
//// MARK: Custom View Builder
//struct DropDown: View {
//    var content: [String]
//    @Binding var selection: String
//    var activeTint: Color
//    var inActiveTint: Color
//    var dynamic: Bool = true
//    /// – View Properties
//    @State private var expandView: Bool = false
//    var body: some View {
//        GeometryReader {
//            let size = $0.size
//            
//            VStack(alignment: .leading, spacing: 0) {
//                if !dynamic {
//                    RowView(selection, size)
//                }
//                ForEach(content.filter {
//                    dynamic ? true : $0 != selection
//                }, id: \.self) { title in
//                    RowView(title, size)
//                }
//            }
//            .background {
//                Rectangle()
//                    .fill(inActiveTint)
//            }
//            /// – Moving View Base on the Selection
//            .offset(y: dynamic ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -55) : 0)
//        }
//        .frame(height: 55)
//        .overlay(alignment: .trailing) {
//            Image(systemName: "chevron.down")
//                .padding(.trailing, 10)
//        }
//        .mask(alignment: .top) {
//            Rectangle()
//                .frame(height: expandView ? CGFloat(content.count) * 55 : 55)
//            /// – Moving the Mask Based on the Selection, so that Every Content Will be Visible
//            /// – Visible Only When Content is Expanded
//                .offset(y: dynamic && expandView ? (CGFloat(content.firstIndex(of: selection) ?? 0) * -55) : 0)
//        }
//    }
//    
//    /// – Row View
//    @ViewBuilder
//    func RowView(_ title: String, _ size: CGSize) -> some View {
//        Text(title)
//            .font(.title3)
//            .fontWeight(.semibold)
//            .padding(.horizontal)
//            .frame(width: size.width, height: size.height, alignment: .leading)
//            .background {
//                if selection == title {
//                    Rectangle()
//                        .fill(activeTint)
//                        .transition(.identity)
//                }
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
//                    /// – If Expanded then Make Selection
//                    if expandView {
//                        expandView = false
//                        /// – Disabling Animation for Non-Dynamic Contents
//                        if dynamic {
//                            selection = title
//                        } else {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                selection = title
//                            }
//                        }
//                    } else {
//                        /// – Disabiling Outside Taps
//                        if selection == title {
//                            expandView = true
//                        }
//                    }
//                }
//            }
//    }
//}
