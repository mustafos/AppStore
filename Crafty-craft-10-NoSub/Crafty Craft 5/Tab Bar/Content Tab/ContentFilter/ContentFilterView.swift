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
        Menu {
            ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                Button {
                    viewModel.selectButton(at: index)
                } label: {
                    Text(viewModel.buttons[index].label)
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
