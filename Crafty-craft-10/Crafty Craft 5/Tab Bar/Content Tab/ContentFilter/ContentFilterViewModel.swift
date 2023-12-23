import SwiftUI
import UIKit

enum ContentFilter {
    case latest
    case popular
    case filter(String)
}


extension ContentFilter: Equatable {
    static func == (lhs: ContentFilter, rhs: ContentFilter) -> Bool {
        switch (lhs, rhs) {
        case (.latest, .latest), (.popular, .popular):
            return true  // Both are latest or popular, consider them equal
        case let (.filter(value1), .filter(value2)) where value1 == value2:
            return true  // Both have filter values that match, consider them equal
        default:
            return false // Filters or filter values don't match, consider them not equal
        }
    }
}


struct ContentFilterModel {
    let icon: UIImage? = nil
    let cornerIcon: UIImage? = UIImage(named: "categoryLock_ic")  // New property for corner icon
    let label: String
    let filter: ContentFilter
    var isLocked: Bool = false
}

class ContentFilterViewModel: ObservableObject {
    typealias OnSelection = (ContentFilter) -> Void
    
    @Published var selectedIndex: Int = 0
    private(set) var buttons: [ContentFilterModel]
    private let onSelect: OnSelection
    
    init(buttons: [ContentFilterModel], onSelect: @escaping OnSelection) {
        self.buttons = buttons
        self.onSelect = onSelect
    }
    
    func updateButtons(newButtons: [ContentFilterModel], selectedIdx: Int) {
        buttons = newButtons
        if selectedIdx > newButtons.count {
            selectedIndex = 0
        } else {
            selectedIndex = selectedIdx
        }
    }
    
    func selectButton(at index: Int) {
        if selectedIndex != index {
            selectedIndex = index
        }
        // Callback about selected button
        onSelect(buttons[selectedIndex].filter)
    }
    
    @ViewBuilder
    func buttonView(for index: Int) -> some View {
        Button(action: {
            self.selectButton(at: index)
        }) {
            ZStack(alignment: .trailing) {  // Align content to the trailing edge
                HStack {
                    if let icon = buttons[index].icon {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(buttons[index].label)
                        .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .font(Font.custom("Blinker-SemiBold", size: 16))
                }
                .frame(height: 30)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selectedIndex == index ? Color.white : Color.clear)
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white, lineWidth: selectedIndex == index ? 0 : 1)
                            .padding(1)
                    }
                )
                .foregroundColor(
                    selectedIndex == index ? Color.black : Color.white
                )
                
                if buttons[index].isLocked == true {
                    // Display corner icon only if contentFilterView is false or for indices other than latest and popular
                    if let cornerIcon = buttons[index].cornerIcon {
                        Image(uiImage: cornerIcon)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .offset(x: 4, y: -6)  // Position the corner icon outside the button
                    }
                }
            }
        }
        .padding(.init(top: 0, leading: 1, bottom: 0, trailing: 1))
    }
}
