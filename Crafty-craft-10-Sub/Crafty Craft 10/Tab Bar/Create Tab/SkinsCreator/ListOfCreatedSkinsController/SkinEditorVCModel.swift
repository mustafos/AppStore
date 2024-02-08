import ImageIO
import UIKit
import Foundation


final class SkinEditorVCModel {
    
    var selectedSkinIndex = Int()
    private var skinsCreatedModelArray = [SkinCreatedModel]()

    //MARK: INIT
    
    init() {
        updateSkinsArray()
    }
    
    //MARK: Open Methods
    
    func getSkins() -> [SkinCreatedModel] {
        return skinsCreatedModelArray
    }
    
    func getSkinByIndex(index: Int) -> SkinCreatedModel? {
        guard skinsCreatedModelArray.indices.contains(index) == true else {
            return nil
        }
        
        return skinsCreatedModelArray[index]
    }
    
    ///if user want to create new skin, creates new Instance of SkinCreatedModel and saves it into Realm
    func getSelectedSkinModel() -> SkinCreatedModel {
        //-1 because first place in our array is always plusmode 
        if selectedSkinIndex == -1 {
            let skinForRealm = CreatedSkinRM()
            skinForRealm.id = RealmService.shared.generateID(object: skinForRealm)
            skinForRealm.name = "NewSkin\(skinForRealm.id)"
            skinForRealm.skinAssemblyDiagram = Data()
            
            if let emptyImage = UIImage(named: "clearSkin") {
                let emptyData = emptyImage.pngData() ?? Data()
                skinForRealm.skinAssemblyDiagram = emptyData
                skinForRealm.hatDiagram = emptyData
            }

            if let emptyImage = UIImage(named: "clearSkin128x128") {
                let emptyData = emptyImage.pngData() ?? Data()
                skinForRealm.skinAssemblyDiagram128 = emptyData
            }
            
            return SkinCreatedModel.init(realmedModel: skinForRealm)
            
        } else {
            return skinsCreatedModelArray[selectedSkinIndex]
        }
    }
    
    func updateSkinsArray() {
        skinsCreatedModelArray = RealmService.shared.getCreatedSkinsArray().map({ SkinCreatedModel(realmedModel: $0) })
    }
    
    func deleteSkin(at index: Int) {
        guard skinsCreatedModelArray.indices.contains(index) else {
            return
        }
        AppDelegate.log("index ",index)
        AppDelegate.log(skinsCreatedModelArray.count)
        let skinToDelete = skinsCreatedModelArray[index]
        
        // Delete from the data source (e.g., Realm)
        RealmService.shared.deleteSkin(skin: skinToDelete)
        
        // Remove from the array
        skinsCreatedModelArray.remove(at: index)
    }
}

