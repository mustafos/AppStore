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
    
    var body: some View { // chevron.down
        Picker(selection: $viewModel.selectedIndex, label: Text("")) {
            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                Text(viewModel.buttons[index].label).tag(index)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: viewModel.selectedIndex) { newIndex in
            viewModel.selectButton(at: newIndex)
        }
        .frame(width: 350, height: 48)
        .padding(0)
        .background(Color(red: 0.97, green: 0.81, blue: 0.38))
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .inset(by: 0.5)
                .stroke(Color(red: 0.1, green: 0.1, blue: 0.1), lineWidth: 1)
            
        )
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
