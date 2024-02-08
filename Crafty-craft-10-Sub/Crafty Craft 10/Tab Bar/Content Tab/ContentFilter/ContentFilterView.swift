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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<viewModel.buttons.count, id: \.self) { index in
                    viewModel.buttonView(for: index)
                }
            }
        }
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
