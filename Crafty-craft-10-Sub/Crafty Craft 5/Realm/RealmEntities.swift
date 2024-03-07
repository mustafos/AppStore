import UIKit
import RealmSwift

final class CreatedSkinRM: Object  {
    @Persisted var id = 0
    @Persisted var preview = Data()
    @Persisted var skinAssemblyDiagram = Data() /// .png 64x64
    @Persisted var is128sizeSkin = false
    @Persisted var skinAssemblyDiagram128 = Data() /// .png 128x128
    @Persisted var hatDiagram = Data()
    @Persisted var name = ""

    @Persisted var imported = false

}

final class AddonSkinVariantObj: EmbeddedObject {
    @Persisted var name: String = ""
    @Persisted var path: String = ""
    
    override init() {
        super.init()
        
        name = ""
        path = ""
    }
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}

final class AddonsEdotorRealmSession: Object  {
    @Persisted var idshka: String = ""
    @Persisted var displayName: String = ""
    @Persisted var categoryImage: String = ""
    @Persisted var displayImage: String = ""
    @Persisted var displayImageData: Data?
    @Persisted var id: String = ""
    @Persisted var type: String = ""
    @Persisted var file: String = ""
    
    @Persisted var skin_variants: List<AddonSkinVariantObj> = .init()
    
    @Persisted var health: Float = 0
    @Persisted var move_speed: Float = 0
    
    @Persisted var ranged_attack_enabled: Bool = false
    @Persisted var ranged_attack_atk_speed: Double = 0.0
    @Persisted var ranged_attack_atk_radius: Double = 0.0
    @Persisted var ranged_attack_burst_shots: Double = 0.0
    @Persisted var ranged_attack_burst_interval: Double = 0.0
    @Persisted var ranged_attack_atk_types: String?
}


final class SavedAddonRM: Object  {
    @Persisted var idshka: String = ""
    @Persisted var displayName: String = ""
    @Persisted var displayImage: String = ""
    @Persisted var displayImageData: Data?
    @Persisted var id: String = ""
    @Persisted var type: String = ""
    
    @Persisted var skin_variants: List<AddonSkinVariantObj> = .init()
    
    @Persisted var skin_variants1_path: String = ""
    @Persisted var skin_variants2_path: String?
    @Persisted var skin_variants3_path: String?
    @Persisted var skin_variants4_path: String?
    @Persisted var skin_variants1_name: String = ""
    @Persisted var skin_variants2_name: String?
    @Persisted var skin_variants3_name: String?
    @Persisted var skin_variants4_name: String?
    
    @Persisted var health: Float = 0
    @Persisted var move_speed: Float = 0
    
    @Persisted var ranged_attack_enabled: Bool = false
    @Persisted var ranged_attack_atk_speed: Double = 0.0
    @Persisted var ranged_attack_atk_radius: Double = 0.0
    @Persisted var ranged_attack_burst_shots: Double = 0.0
    @Persisted var ranged_attack_burst_interval: Double = 0.0
    @Persisted var ranged_attack_atk_types: String?
    
    @Persisted var editingDate: Date?
    @Persisted var isEnabled: Bool = false
    @Persisted var amount: Int = 1
    
    @Persisted var file: String?
}
