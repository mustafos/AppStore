import RealmSwift

final class RealmServiceDropBox {
    private init() {}
    static let shared = RealmServiceDropBox()
    
    private var realm = try! Realm()
    
    func create<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            AppDelegate.log(error)
        }
    }
    
    func create<T: Object>(_ object: [T]) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            AppDelegate.log(error)
        }
    }
    
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            AppDelegate.log(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            AppDelegate.log(error)
        }
    }
    
    func readAll<T: Object>(_ object: T.Type) -> Results<T> {
        realm.objects(object)
    }
    
    func read<T: Object>(_ object: T.Type, id: String) -> T? {
        realm.object(ofType: object, forPrimaryKey: id)
    }
}
