import Foundation

struct DropBoxCuteKeys_json {

    static let skinMainKey = "3v1nm7e1"
    static let addonMainKey = "_idve7m"
    static let mapMainKey = "6_am8cq"
    static let seedMainKey = "jpa1"

    static let noData = "noData"
    
    static let skin = "Skin"
    static let seed = "Seed"
    static let addon = "Addon"
    static let map = "Map"

    static let RefreshTokenSaveVarieble = "refresh_token"
    static let pathMods = "/mods"
}

enum DropBoxCategoryType {
    case skins, addons, maps, addonsEditor, seeds
    
    var getKey: String {
        switch self {
        case .skins:
            return DropBoxCuteKeys_json.skin
        case .addons:
            return DropBoxCuteKeys_json.addon
        case .maps:
            return DropBoxCuteKeys_json.map
        case .addonsEditor:
            return "AddonsEditor"
        case .seeds:
            return DropBoxCuteKeys_json.seed
        }
    }
    
    var path : String {
        switch self {
        case .skins:
            return DropBoxCuteKeys_json.pathMods
        case .addons:
            return ""
        case .maps:
            return ""
        case .addonsEditor:
            return ""
        case .seeds:
            return ""
        }
    }
}

struct SkinContent {
    static let skinSourceImage = "8b5zjx0slu"
    static let skinImage = "27ii-t"
    static let isNew = "new"
    static let skinName = "mcgvpnt"
}

struct DropBoxSkins: Equatable, Codable {
    let skinName: String
    let skinSourceImage: String
    let skinImage: String
    let isNew: Bool
    let filterCategory: String
}

struct SeedContent {
    static let seedImage = "u07a4hh71"
    static let seedDescrip = "1vgdi8im"
    static let seedName = "r8jlwfz"
    static let seed = "a2f"
    static let isNew = "new"
}

struct DropBoxSeed: Equatable, Codable {
    let imagePath: String
    let descrip: String
    let name: String
    let seed: String
    let isNew: Bool
}

struct AddonsContent {
    static let addonImages = "pskdawa7a"
    static let addonDescription = "7ox3-z94pa"
    static let addonTitle = "a4obq3t"
    static let isNew = "new"
    static let file = "sugkx"
}

struct DropBoxAddons: Equatable, Codable {
    let addonImages: [String]
    let addonDescription: String
    let addonTitle: String
    let isNew: Bool
    let filterCategory: String
    let file: String
}

struct MapsContent {
    static let mapImages = "z4_qs2"
    static let mapDescription = "9hmgghbd2j"
    static let mapTitle = "terxv5seo"
    static let isNew = "new"
    static let file = "xf-"
    
}

struct DropBoxMaps: Equatable, Codable {
    let mapImages: [String]
    let mapDescription: String
    let mapTitle: String
    let isNew: Bool
    let filterCategory: String
    let file: String
}


// Addon Editor Keys

struct AddonsEditorContent {
    static let jsonPath = "/Addon_Maker/addon_maker.json"
    static let mainKey = "vbdfjjg-90"
    static let addonMakerFolder = "Addon_Maker/"
    static let addonTag = "AddonsEditor"
    static let mcAddonFilePath = "Addon_Maker/"
}

struct AddonItem: Equatable, Codable {
    var idshka = String()
    var displayName = String()
    var displayImage = String()
    var categoryImage = String()
    var skin_variants = [SkinVariants]()
    var id = String()
    var type = String()
    var ranged_attack = [RangedAttack]()
    var health = Float()
    var move_speed = Float()
    var type_family = String()
    var file = String()
}

struct SkinVariants: Equatable, Codable {
    var idshka = String()
    var name = String()
    var displayImage = String()
}

struct RangedAttack: Equatable, Codable {
    var idshka = String()
    var enabled = Bool()
    var atk_speed = Double()
    var atk_radius = Double()
    var burst_shots = Double()
    var burst_interval = Double()
    var atk_types = String()
}
