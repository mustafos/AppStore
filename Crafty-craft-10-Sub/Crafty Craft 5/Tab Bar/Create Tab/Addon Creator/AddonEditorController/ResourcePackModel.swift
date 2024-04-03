//
//  ResourcePackModel.swift
//  Crafty Craft 5
//
//  Created by dev on 14.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

// MARK: - ResourcePack
struct ResourcePackModel: Codable {
    let formatVersion: Int?
    let modules: [ResourcePackModule]?

    enum CodingKeys: String, CodingKey {
        case formatVersion = "format_version"
        case modules
    }
}

// MARK: - Module
struct ResourcePackModule: Codable {
    let description, type, uuid: String?
    let version: [Int]?
}

struct ResourcePack {
    let addonPath: URL
    let entityPath: URL
    let name: String
    let geometry: Codable
    let resourcesPath: URL
    let texturePath: URL
    var image: Data
    
    func copy(with texture: Data) -> ResourcePack {
        ResourcePack(addonPath: addonPath, entityPath: entityPath, name: name, geometry: geometry, resourcesPath: resourcesPath, texturePath: texturePath, image: texture)
    }
    
    init(addonPath: URL, entityPath: URL, name: String, geometry: Codable, resourcesPath: URL, texturePath: URL, image: Data) {
        self.addonPath = addonPath
        self.entityPath = entityPath
        self.name = name
        self.geometry = geometry
        self.resourcesPath = resourcesPath
        self.texturePath = texturePath
        self.image = image
    }
    
    init() {
        addonPath = URL(fileURLWithPath: "")
        entityPath = URL(fileURLWithPath: "")
        name = ""
        geometry = ""
        resourcesPath = URL(fileURLWithPath: "")
        texturePath = URL(fileURLWithPath: "")
        image = Data()
    }
    
    func widthGeometrySize() -> (Float, Float) {
        guard let minecraftGeometryModel = self.geometry as? MinecraftGeometryModel,
              let addonGeometry = minecraftGeometryModel.minecraftGeometry.first  else {
            return (0, 0)
        }
        var maxX: Float = 0
        var minX: Float = 0
        
        for bone in addonGeometry.bones {
            maxX = max(bone.cubes?.map({$0.origin[0] + Float($0.size[0])/2}).max() ?? 0, maxX)
            minX = min(bone.cubes?.map({$0.origin[0] - Float($0.size[0])/2}).min() ?? 0, minX)
        }
        return (minX, maxX)
    }
    
    func heightGeometrySize() -> (Float, Float) {
        guard let minecraftGeometryModel = self.geometry as? MinecraftGeometryModel,
              let addonGeometry = minecraftGeometryModel.minecraftGeometry.first  else {
            return (0, 0)
        }
        var maxY: Float =  0
        var minY: Float = 0
        
        for bone in addonGeometry.bones {
            maxY = max(bone.cubes?.map({$0.origin[1] + Float($0.size[1])/2}).max() ?? 0, maxY)
            minY = min(bone.cubes?.map({$0.origin[1] - Float($0.size[1])/2}).min() ?? 0, minY)
        }
        return (minY, maxY)
    }
    
    private func generateRandomEmoji() -> String {
        let emojis = ["😀", "😎", "😂", "😍", "🥳", "🤔", "😊", "🚀"]
        let randomIndex = Int.random(in: 0..<emojis.count)
        return emojis[randomIndex]
    }
    
    func depthGeometrySize() -> (Float, Float) {
        guard let minecraftGeometryModel = self.geometry as? MinecraftGeometryModel,
              let addonGeometry = minecraftGeometryModel.minecraftGeometry.first  else {
            return (0, 0)
        }
        
        var maxZ: Float =  0
        var minZ: Float =  0
        
        for bone in addonGeometry.bones {
            maxZ = max(bone.cubes?.map({$0.origin[2] + Float($0.size[2])/2}).max() ?? 0, maxZ)
            minZ = min(bone.cubes?.map({$0.origin[2] - Float($0.size[2])/2}).min() ?? 0, minZ)
        }
        return (minZ, maxZ)
    }
}

// MARK: - ResourcePackEntity
struct ResourcePackEntity: Codable {
    let minecraftClientEntity: MinecraftClientEntity?

    enum CodingKeys: String, CodingKey {
        case minecraftClientEntity = "minecraft:client_entity"
    }
}

struct MinecraftGeometryModel: Codable {
    let formatVersion: String
    let minecraftGeometry: [MinecraftGeometry]

    enum CodingKeys: String, CodingKey {
        case formatVersion = "format_version"
        case minecraftGeometry = "minecraft:geometry"
    }
}

struct MinecraftGeometryUV6Model: Codable {
    let formatVersion: String
    let minecraftGeometry: [MinecraftGeometryUV6]

    enum CodingKeys: String, CodingKey {
        case formatVersion = "format_version"
        case minecraftGeometry = "minecraft:geometry"
    }
}

// MARK: - MinecraftClientEntity
struct MinecraftClientEntity: Codable {
    let description: MinecraftClientEntityDescription
}

// MARK: - Description
struct MinecraftClientEntityDescription: Codable {
    let identifier: String
    let textures: MinecraftClientEntityTexture
    let geometry: MinecraftClientEntityGeometry
}

// MARK: - Geometry
struct MinecraftClientEntityTexture: Codable {
    let name: String?

    enum CodingKeys: String, CodingKey {
        case name = "default"
    }
}

// MARK: - Geometry
struct MinecraftClientEntityGeometry: Codable {
    let name: String?

    enum CodingKeys: String, CodingKey {
        case name = "default"
    }
}

/// Legacy

struct MinecraftGeometryLegacy: Codable {
    let textureWidth, textureHeight: Int
    let visibleBoundsWidth, visibleBoundsHeight: Float
    let visibleBoundsOffset: [Float]
    let bones: [MinecraftGeometryBone]
    
    enum CodingKeys: String, CodingKey {
        case bones
        case textureWidth = "texturewidth"
        case textureHeight = "textureheight"
        case visibleBoundsWidth = "visible_bounds_width"
        case visibleBoundsHeight = "visible_bounds_height"
        case visibleBoundsOffset = "visible_bounds_offset"
    }
}

/// Geometry with old uv structure [0, 0]
///
struct MinecraftGeometry: Codable {
    let description: MinecraftGeometryDescription
    let bones: [MinecraftGeometryBone]
}

struct MinecraftGeometryBone: Codable {
    let name: String
    let pivot: [Float]
    let rotation: [Float]?
    let cubes: [MinecraftGeometryCube]?
    let parent: String?
}

struct MinecraftGeometryCube: Codable {
    let origin: [Float]
    let pivot: [Float]?
    let size: [Int]
    let uv: TextureUV
    let inflate: Float?
    let mirror: Bool?
    let rotation: [Float]?
    
    
    enum CodingKeys: String, CodingKey {
        case origin
        case pivot
        case size
        case inflate
        case mirror
        case rotation
        case uv
        case uv6
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        origin = try values.decode([Float].self, forKey: .origin)
        pivot = try? values.decode([Float]?.self, forKey: .pivot)
        size = try values.decode([Int].self, forKey: .size)
        inflate = try? values.decode(Float?.self, forKey: .inflate)
        mirror = try? values.decode(Bool?.self, forKey: .mirror)
        rotation = try? values.decode([Float]?.self, forKey: .rotation)
        
        if let decodedUV =  try? values.decode([Int].self, forKey: .uv) {
            uv = .uv(decodedUV)
            
        } else {
            let decodedUV6 = try values.decode(MinecraftGeometryUv6Format.self, forKey: .uv6)
            uv = .uv6(decodedUV6)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin, forKey: .origin)
        try container.encode(pivot, forKey: .pivot)
        try container.encode(size, forKey: .size)
        try container.encode(inflate, forKey: .inflate)
        try container.encode(mirror, forKey: .mirror)
        try container.encode(rotation, forKey: .rotation)
        
        switch uv {
        case .uv(let uv):
            try container.encode(uv, forKey: .uv)
            
        case .uv6(let uv6):
            try container.encode(uv6, forKey: .uv6)
        }
    }
}

enum TextureUV {
    case uv(_: [Int])
    case uv6(_: MinecraftGeometryUv6Format)
}

/// Geometry with new uv structure
///
struct MinecraftGeometryUV6: Codable {
    let description: MinecraftGeometryDescription
    let bones: [MinecraftGeometryBoneUV6]
}

struct MinecraftGeometryBoneUV6: Codable {
    let name: String
    let pivot: [Float]
    let rotation: [Float]?
    let cubes: [MinecraftGeometryCubeUV6]?
    let parent: String?
}

struct MinecraftGeometryCubeUV6: Codable {
    let origin: [Float]
    let pivot: [Float]?
    let size: [Int]
    let uv: MinecraftGeometryUv6Format
    let inflate: Float?
    let mirror: Bool?
    let rotation: [Float]?
    
    enum CodingKeys: String, CodingKey {
        case origin
        case pivot
        case size
        case uv
        case inflate
        case mirror
        case rotation
    }
    
    enum EncodingCodingKeys: String, CodingKey {
        case origin
        case pivot
        case size
        case uv6
        case inflate
        case mirror
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingCodingKeys.self)
        try container.encode(origin, forKey: .origin)
        try container.encode(pivot, forKey: .pivot)
        try container.encode(size, forKey: .size)
        try container.encode(uv, forKey: .uv6)
        try container.encode(inflate, forKey: .inflate)
        try container.encode(mirror, forKey: .mirror)
    }
}

struct MinecraftGeometryUv6Format: Codable {
    let north, east, south, west: MinecraftGeometryUv6Info
    let up, down: MinecraftGeometryUv6Info
}

// MARK: - Down
struct MinecraftGeometryUv6Info: Codable {
    let uv: [Int]
    let uvSize: [Double]

    enum CodingKeys: String, CodingKey {
        case uv
        case uvSize = "uv_size"
    }
}

/// Description
///
struct MinecraftGeometryDescription: Codable {
    let identifier: String
    let textureWidth, textureHeight: Int
    let visibleBoundsWidth, visibleBoundsHeight: Float
    let visibleBoundsOffset: [Float]
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case textureWidth = "texture_width"
        case textureHeight = "texture_height"
        case visibleBoundsWidth = "visible_bounds_width"
        case visibleBoundsHeight = "visible_bounds_height"
        case visibleBoundsOffset = "visible_bounds_offset"
    }
}
