//
//  EdditionalAddonModel.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

enum CollectionViewState {
    case savedAddons
    case groups
    case recent
}

class EdditionalAddonModel {
    
    private var realm = RealmService.shared
    
    var collectionMode: CollectionViewState = .savedAddons {
        didSet {
            updateCreatedAddons()
        }
    }
    
    var createdAddons = [SavedAddonEnch]() {
        didSet {
            filteringCreatedAddon = createdAddons
        }
    }
    
    var filteringCreatedAddon = [SavedAddonEnch]()
    
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
            let convertedClass = SavedAddonEnch(realmModel: addon)
            createdAddons.append(convertedClass)
        }
    }
    
    func getSavedAddon(by index: Int) -> SavedAddonEnch? {
        guard index >= 0 && index < filteringCreatedAddon.count else {
            AppDelegate.log("Index is out of range")
            return nil
        }
        
        return filteringCreatedAddon[index]
    }
    
    func updateRecentForAddon(savedAddon: SavedAddonEnch) {
        
        guard let realmedSavedAddon = realm.getSavedAddonRM(by: savedAddon.idshka) else {
            return
        }
        
        realm.editRecentProprty(for: realmedSavedAddon, newDate: Date())
    }
    
    private func shuffleArray<T>(_ array: [T]) -> [T] {
        var shuffledArray = array
        for i in 0..<shuffledArray.count {
            let randomIndex = Int.random(in: i..<shuffledArray.count)
            if i != randomIndex {
                shuffledArray.swapAt(i, randomIndex)
            }
        }
        return shuffledArray
    }
    
    private func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }
    
    func deleteAddon(at index: Int) {
        
        var addonToDelete: SavedAddonEnch?
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
    
    private func generateRandomDate(from startDate: Date, to endDate: Date) -> Date {
        return Date(timeIntervalSinceReferenceDate: TimeInterval.random(in: startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate))
    }
}
