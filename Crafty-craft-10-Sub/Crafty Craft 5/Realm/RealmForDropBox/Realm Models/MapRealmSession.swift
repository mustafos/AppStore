import Foundation
import RealmSwift

class MapsRealmSession: Object, Identifiable {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var mapImages: List<String>
    @Persisted var mapDescription: String
    @Persisted var mapTitle: String
    @Persisted var isNew: Bool
    @Persisted var isFavorite: Bool
    @Persisted var mapImageData: Data?
    @Persisted var filterCategory: String
    @Persisted var file: String

    convenience init(mapImages: [String], mapDescription: String, mapTitle: String, isNew: Bool, isFavorite: Bool, mapImageData: Data?, filterCategory: String, file: String) {
        self.init()
        self.id = UUID().uuidString
        self.mapImages.append(objectsIn: mapImages)
        self.mapDescription = mapDescription
        self.mapTitle = mapTitle
        self.isNew = isNew
        self.isFavorite = isFavorite
        self.mapImageData = mapImageData
        self.filterCategory = filterCategory
        self.file = file
    }
}

struct MapsSession: Identifiable {
    let id: String
    let mapImages: [String]
    let mapDescription: String
    let mapTitle: String
    let isNew: Bool
    let isFavorite: Bool
    let mapImageData: Data?
    let filterCategory: String
    let file: String
}
