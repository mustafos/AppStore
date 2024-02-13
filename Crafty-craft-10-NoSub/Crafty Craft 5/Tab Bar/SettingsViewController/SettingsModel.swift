import UIKit
import RealmSwift

final class SettingsModel {
    
    var cacheInKB: String? {
        updateCacheSize()
    }
    
    func openUrl(urlToOpen: String?) {
        guard let urlToOpen,
              let url = URL(string: urlToOpen) else {
              print("Invalid URL")

              return
          }
          
          guard UIApplication.shared.canOpenURL(url) else {
              print("Cannot open URL")
              return
          }
          
          UIApplication.shared.open(url, options: [:], completionHandler: nil)

    }
    
    func clearCache() {
        guard let allRealmedSkins = RealmServiceProviding.shared.getAllRealmSessionObjects(of: SkinsRealmSession.self)?.filter({ $0.skinImageData != nil }),
              let allRealmedAddons = RealmServiceProviding.shared.getAllRealmSessionObjects(of: AddonsRealmSession.self)?.filter({ $0.addonImageData != nil }),
              let allRealmedMaps = RealmServiceProviding.shared.getAllRealmSessionObjects(of: MapsRealmSession.self)?.filter({ $0.mapImageData != nil }),
              let allRealmedServers = RealmServiceProviding.shared.getAllRealmSessionObjects(of: ServerRealmSession.self)?.filter({$0.imageData != nil }),
              let allRealmedSeeds = RealmServiceProviding.shared.getAllRealmSessionObjects(of: SeedRealmSession.self)?.filter({$0.seedImageData != nil })
        else {
            return
        }
        
        allRealmedSkins.forEach({ RealmServiceProviding.shared.updateRealmObj(realmObj: $0, keyToUpdate: "skinImageData", newVal: nil as Data?)
        })
        
        allRealmedAddons.forEach({ RealmServiceProviding.shared.updateRealmObj(realmObj: $0, keyToUpdate: "addonImageData", newVal: nil as Data?)
        })
        
        allRealmedMaps.forEach({ RealmServiceProviding.shared.updateRealmObj(realmObj: $0, keyToUpdate: "mapImageData", newVal: nil as Data?)
        })
        
        allRealmedServers.forEach({ RealmServiceProviding.shared.updateRealmObj(realmObj: $0, keyToUpdate: "imageData", newVal: nil as Data?) })
        
        allRealmedSeeds.forEach({ RealmServiceProviding.shared.updateRealmObj(realmObj: $0, keyToUpdate: "seedImageData", newVal: nil as Data?) })

    }

    
    //MARK: Private Methods
    
    private func updateCacheSize() -> String? {
        //get all content Models with cached Images
        guard let allRealmedSkins = RealmServiceProviding.shared.getAllRealmSessionObjects(of: SkinsRealmSession.self)?.filter({ $0.skinImageData != nil }),
              let allRealmedAddons = RealmServiceProviding.shared.getAllRealmSessionObjects(of: AddonsRealmSession.self)?.filter({ $0.addonImageData != nil }),
              let allRealmedMaps = RealmServiceProviding.shared.getAllRealmSessionObjects(of: MapsRealmSession.self)?.filter({ $0.mapImageData != nil }),
              let allRealmedServers = RealmServiceProviding.shared.getAllRealmSessionObjects(of: ServerRealmSession.self)?.filter({$0.imageData != nil }),
              let allRealmedSeeds = RealmServiceProviding.shared.getAllRealmSessionObjects(of: SeedRealmSession.self)?.filter({$0.seedImageData != nil })
        else {
            return "0 KB"
        }
        
        //count tatalSize of contentModels storedImages
        var skinsCachedDataSize: Int = 0

        allRealmedSkins.forEach({ skinsCachedDataSize += $0.skinImageData?.count ?? 0 })
        allRealmedAddons.forEach({ skinsCachedDataSize += $0.addonImageData?.count ?? 0 })
        allRealmedMaps.forEach({ skinsCachedDataSize += $0.mapImageData?.count ?? 0 })
        allRealmedServers.forEach({ skinsCachedDataSize += $0.imageData?.count ?? 0 })
        allRealmedSeeds.forEach({ skinsCachedDataSize += $0.seedImageData?.count ?? 0 })

        // Convert size into KB
        let sizeInKB = Double(skinsCachedDataSize) / 1024.0

        // Round Size
        let roundedSizeInKB = Double(round(100 * sizeInKB) / 100)
        let resultCache = "\(roundedSizeInKB) KB"

        return resultCache
    }
}
