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
    let cornerIcon: UIImage? = UIImage(named: "lock button")
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
}
