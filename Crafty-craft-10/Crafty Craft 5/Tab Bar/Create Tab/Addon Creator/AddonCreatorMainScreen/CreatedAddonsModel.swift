
import Foundation


enum CollectionState {
    case savedAddons
    case groups
    case recent
}

class CreatedAddonsModel {
    
    private var realm = RealmService.shared
    
    var collectionMode: CollectionState = .savedAddons {
        didSet {
            updateCreatedAddons()
        }
    }
    
    var createdAddons = [SavedAddon]() {
        didSet {
            filteringCreatedAddon = createdAddons
        }
    }
    
    var filteringCreatedAddon = [SavedAddon]()
    
    init() {
        updateCreatedAddons()
    }
    
    func updateCreatedAddons() {
        createdAddons.removeAll()
        
        let savedAddons = realm.getArrayOfSavedAddons()
        var sortedAddons = savedAddons
        
        switch collectionMode {
        case .savedAddons:
            break
        case .groups:
            sortedAddons = savedAddons.sorted(by: { $0.type < $1.type })
        case .recent:
            sortedAddons = savedAddons.sorted { (addon1, addon2) -> Bool in
                if let editingDate1 = addon1.editingDate, let editingDate2 = addon2.editingDate {
                    
                    return editingDate1 > editingDate2
                }
                // Handle the case where at least one editingDate is nil
                return addon1.editingDate != nil
            }
        }
        
        for addon in sortedAddons {
            let convertedClass = SavedAddon(realmModel: addon)
            createdAddons.append(convertedClass)
        }
    }
    
    func getSavedAddon(by index: Int) -> SavedAddon? {
        guard index >= 0 && index < filteringCreatedAddon.count else {
            AppDelegate.log("Index is out of range")
            return nil
        }
        
        return filteringCreatedAddon[index]
    }
    
    func updateRecentForAddon(savedAddon: SavedAddon) {
        
        guard let realmedSavedAddon = realm.getSavedAddonRM(by: savedAddon.idshka) else {
            return
        }
        
        realm.editRecentProprty(for: realmedSavedAddon, newDate: Date())
    }
    
    func deleteAddon(at index: Int) {
        
        var addonToDelete: SavedAddon?
        if createdAddons.count == filteringCreatedAddon.count {
            addonToDelete = createdAddons[index]
        } else {
            addonToDelete = filteringCreatedAddon[index]
        }
        
        guard let addon = addonToDelete else { return }
        // Delete from the data source (e.g., Realm)
        RealmService.shared.deleteAddon(addon: addon)
        
        // Remove from the array
        createdAddons.remove(at: index)
//        createdAddons.removeAll { $0.id == addon.id}
//        filteringCreatedAddon.removeAll { $0.id == addon.id}
    }
}
