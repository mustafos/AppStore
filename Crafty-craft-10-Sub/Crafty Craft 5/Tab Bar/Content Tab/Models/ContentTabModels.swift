import UIKit

// MARK: - Enums
enum TabsPageController: Int {
    case skins = 0
    case maps = 1
    case addons = 2
    
    var name: String {
        switch self {
        case .skins:
            return "Skins"
        case .maps:
            return "Maps"
        case .addons:
            return "Addons"
        }
    }
}

enum SegmentedController {
    case latest
    case popular
    case filter(String)
}

struct TabPagesCollectionCellModel {
    let id: String
    let name: String
    let image: String
    let isContentNew: Bool
    let description: String?
    let isFavorite: Bool
    var imageData: Data?
    let filterCategory: String
    let file: String?
}

struct TableCellData {
    let name: String
    let imageName: String
    var isSelected: Bool
}

extension TableCellData: Equatable {
    static func == (lhs: TableCellData, rhs: TableCellData) -> Bool {
        lhs.name == rhs.name && lhs.imageName == rhs.imageName && lhs.isSelected == rhs.isSelected
    }
}
