

import Foundation
import UIKit

struct AddonConstructorModel {

    var isThumbnail: Bool
    var showCubesColor: UIColor?
    var hideCubesColor: UIColor?

    var superParent: AddonBone
    var allBones: [AddonBone]
    var textureSizes: TextureSize
    var assemblyImg: UIImage
    private let globalMirror: Float = -1
    
    //MARK: Init
    
    init() {
        self.isThumbnail = false
        self.superParent = AddonBone()
        self.allBones = []
        self.textureSizes = TextureSize()
        self.assemblyImg = UIImage()
    }
    
    //Normal ScneneModel
    init(resourcePack: ResourcePack) {
        self.init()
        self.isThumbnail = false
        self.superParent = self.createSuperParent()
        self.assemblyImg = self.getAssemblyDiagram(resourcePack: resourcePack)
        self.allBones = createAllBones(resourcePack: resourcePack)
        self.textureSizes =  TextureSize(size: self.assemblyImg.size)
    }
    
    //Normal ScneneModel
    init(resourcePack: ResourcePack, modelColor: UIColor, hideColor: UIColor) {
        self.init()
        self.isThumbnail = true
        self.showCubesColor = modelColor
        self.hideCubesColor = hideColor
        self.superParent = self.createSuperParent()
        self.assemblyImg = self.getAssemblyDiagram(resourcePack: resourcePack)
        self.allBones = createAllBones(resourcePack: resourcePack)
        self.textureSizes =  TextureSize(size: self.assemblyImg.size)
        
    }
    

    //MARK: Init functions
    
    private func createSuperParent() -> AddonBone {
        var superParent = AddonBone()
        superParent.name = "superParent"
        superParent.pivot = Coordinates3D([0, 10, 2])
        
        return superParent
    }
    
    private mutating func createAllBones(resourcePack: ResourcePack) -> [AddonBone] {

        guard let minecraftGeometryModel = resourcePack.geometry as? MinecraftGeometryModel,
              let addonGeometry = minecraftGeometryModel.minecraftGeometry.first  else {

            print("ERROR: wrong custing")
            return [AddonBone]()
        }

        let assemblyDiagram = getAssemblyDiagram(resourcePack: resourcePack)
        let allBones = buildBones(addonGeometry: addonGeometry)

        return allBones
    }
    
    //MARK: Texture
    
    private mutating func getAssemblyDiagram(resourcePack: ResourcePack) -> UIImage {
        var addonAssembly = UIImage()
        
        if resourcePack.image.isEmpty == false {
            addonAssembly = UIImage(data:  resourcePack.image) ?? UIImage()
            
        } else {
            let pathToTexture = resourcePack.texturePath.path
            addonAssembly = UIImage(contentsOfFile: pathToTexture) ?? UIImage()
        }
        
        return addonAssembly
    }
    
    //MARK: Build Bones
    
    private func buildBones(addonGeometry: MinecraftGeometry) -> [AddonBone] {
        
        var resultArr = [AddonBone]()
        var aditionlNodes = [AddonBone]()

        for parsedBone in addonGeometry.bones {
            
            //Set Name
            var addonBone = AddonBone()
            addonBone.name = parsedBone.name
            
            //Set bone parent
            if let boneParent = parsedBone.parent {
                addonBone.parentName = boneParent
            } else {
                addonBone.parentName = superParent.name
            }
            
            //Calculate bone local Coordinates for pivot
            let parentBonePivot = (addonGeometry.bones.first(where: {$0.name == parsedBone.parent})?.pivot ?? superParent.pivot?.asFloatArr()) ?? [0,0,0]
            let convertedParentBonePivot = convertIntoScnDimension(parentBonePivot)
            let convertedParsedBonePivot = convertIntoScnDimension(parsedBone.pivot)

            let substractedPivot = convertedParsedBonePivot.subtract(convertedParentBonePivot)
            let bonePivot = Coordinates3D(substractedPivot)
            
            addonBone.position = bonePivot
            //Calculate bone rotation
            if let parsedRotation = parsedBone.rotation, parsedRotation.count >= 3 {
                addonBone.rotation = Coordinates3D([
                    parsedRotation[0] * globalMirror, // x * -1
                    parsedRotation[1] , // y * -1
                    parsedRotation[2] * globalMirror
                ])
            }
            
            //Calculate Cubes
            if let parsedCubes = parsedBone.cubes {
                addonBone.cubes = createCubesFromParsedData(parsedCubes, parsedParentBone: parsedBone, additionalNodes: &aditionlNodes)
            }
            
            resultArr.append(addonBone)
        }
        
        resultArr.append(contentsOf: aditionlNodes)
        return resultArr
    }
    
    //MARK: CreateCubes
    
    private func createCubesFromParsedData(_ parsedCubes: [MinecraftGeometryCube], parsedParentBone: MinecraftGeometryBone, additionalNodes: inout [AddonBone]) -> [CubeInfo] {
        var resultCubes = [CubeInfo]()
        
        for (index, parsedCube) in parsedCubes.enumerated() {
            
            var cubeInfo = CubeInfo()
            
            cubeInfo.width = Float(parsedCube.size[0])
            cubeInfo.height = Float(parsedCube.size[1])
            cubeInfo.length = Float(parsedCube.size[2])

            cubeInfo.rotation = parsedCube.rotation
            
//            cubeInfo.uv = parsedCube.uv
            switch parsedCube.uv {
            case .uv(let uvValue):
                cubeInfo.uv = uvValue
                cubeInfo.cubeSides = calculateSideStartPoint(cube: parsedCube, uvValue: uvValue)

            case .uv6(let uv6Value):
                print("success")
                
//                cubeInfo.uv6 = uv6Value
            }
            
            
            if let parsedCubePivot = parsedCube.pivot {

//                //Create New parent bone, only in case when cube has its own pivot, for correct rotation
                var newParentBone = AddonBone()
                newParentBone.name = "pivotBone_\(parsedParentBone.name)_cube_\(index)"
                newParentBone.parentName = parsedParentBone.name
                cubeInfo.parentName = newParentBone.name
                cubeInfo.name = "\(cubeInfo.parentName)_cubeNuber[\(index)]"

                let convertedParentBonePivot = convertIntoScnDimension(parsedParentBone.pivot)
                var convertedCubePivot = convertIntoScnDimension(parsedCubePivot)
                var newParentBonePivot = convertedCubePivot.subtract(convertedParentBonePivot)

                newParentBone.position = Coordinates3D(newParentBonePivot)
                
                
                
                //Calculate bone rotation
                if let parsedRotation = parsedCube.rotation, parsedRotation.count >= 3 {
                    newParentBone.rotation = Coordinates3D([
                        parsedRotation[0] * globalMirror, // x * -1
                        parsedRotation[1], // y * -1
                        parsedRotation[2] * globalMirror
                    ])
                }
                
                

//                let cubeInfoPivot = convertedCubePosition.subtract(newParentBone.pivot?.asFloatArr() ?? [0,0,0])
//                cubeInfo.pivot = Coordinates3D(cubeInfoPivot)
                
                let convertedCubePos = convertIntoScnDimension([parsedCube.origin[0] + cubeInfo.width / 2,
                                                                 parsedCube.origin[1] + cubeInfo.height / 2,
                                                                 parsedCube.origin[2] + cubeInfo.length / 2])
                let convertedNewParentBonePivot = convertIntoScnDimension(parsedCubePivot)
                var cubePosition = convertedCubePos.subtract(convertedNewParentBonePivot)
                
                cubeInfo.geometry = Coordinates3D(cubePosition)
                
                newParentBone.cubes = [cubeInfo]
                
                additionalNodes.append(newParentBone)

            } else {
                cubeInfo.parentName = parsedParentBone.name
                
                
                
                
                cubeInfo.rotation = parsedCube.rotation
                
                
                let convertedCubePos = convertIntoScnDimension([parsedCube.origin[0] + cubeInfo.width / 2,
                                                                 parsedCube.origin[1] + cubeInfo.height / 2,
                                                                 parsedCube.origin[2] + cubeInfo.length / 2])
                let convertedParentBonePivot = convertIntoScnDimension(parsedParentBone.pivot)
                var cubePosition = convertedCubePos.subtract(convertedParentBonePivot)
                
                cubeInfo.geometry = Coordinates3D(cubePosition)
                cubeInfo.name = "\(cubeInfo.parentName)_cubeNuber[\(index)]"
                resultCubes.append(cubeInfo)
            }
            
            
        }

        return resultCubes
    }
    
    //MARK: Calculate Side Startpoints
    
    func calculateSideStartPoint(cube: MinecraftGeometryCube, uvValue: [Int]) -> [CubeSide] {

        // Create array for sides
        var sides = [CubeSide]()
        let uvX = uvValue[0]
        let uvY = uvValue[1]
        let cubeWidth = cube.size[0]
        let cubeHeight = cube.size[1]
        let cubeLength = cube.size[2]
        
        // Calculate UV for each side
        let uvTop = [uvX + cubeLength, uvY]
        let uvBottom = [uvX + cubeLength + cubeWidth, uvY]
        
        let uvLeft = [uvX, uvY + cubeLength]
        let uvRight = [uvX + cubeLength + cubeWidth, uvY + cubeLength]
        
        let uvFront = [uvX + cubeLength, uvY + cubeLength]
        let uvBack = [uvX + cubeLength * 2 + cubeWidth, uvY + cubeLength]
        
        // Add each side to the array
        sides.append(CubeSide(name: .front, startX: uvFront[0], startY: uvFront[1], sideWidth: cubeWidth, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .right, startX: uvRight[0], startY: uvRight[1], sideWidth: cubeLength, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .back, startX: uvBack[0], startY: uvBack[1], sideWidth: cubeWidth, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .left, startX: uvLeft[0], startY: uvLeft[1], sideWidth: cubeLength, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .top,  startX: uvTop[0], startY: uvTop[1], sideWidth: cubeWidth, sideHeight: cubeLength))
        sides.append(CubeSide(name: .bottom, startX: uvBottom[0], startY: uvBottom[1], sideWidth: cubeWidth, sideHeight: cubeLength))
        
        //Sort by rawValue to ensure That material will be set in correct subsecuence [front, right, back, left, top, bot]
        sides.sort(by: { $0.name.rawValue < $1.name.rawValue })
        
        return sides
    }
    
    private func calculateSideStartPointUv6(uv6: MinecraftGeometryUv6Format, cube: MinecraftGeometryCube) -> [CubeSide] {
        // Create array for sides
        var sides = [CubeSide]()

        let cubeWidth = cube.size[0]
        let cubeHeight = cube.size[1]
        let cubeLength = cube.size[2]
        
        let uvTop = uv6.up.uv
        let uvBottom = uv6.down.uv
        
        let uvLeft = uv6.west.uv
        let uvRight = uv6.east.uv
        
        let uvFront = uv6.north.uv
        let uvBack = uv6.south.uv
        
        // Add each side to the array
        sides.append(CubeSide(name: .front, startX: uvFront[0], startY: uvFront[1], sideWidth: cubeWidth, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .right, startX: uvRight[0], startY: uvRight[1], sideWidth: cubeLength, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .back, startX: uvBack[0], startY: uvBack[1], sideWidth: cubeWidth, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .left, startX: uvLeft[0], startY: uvLeft[1], sideWidth: cubeLength, sideHeight: cubeHeight))
        sides.append(CubeSide(name: .top,  startX: uvTop[0], startY: uvTop[1], sideWidth: cubeWidth, sideHeight: cubeLength))
        sides.append(CubeSide(name: .bottom, startX: uvBottom[0], startY: uvBottom[1], sideWidth: cubeWidth, sideHeight: cubeLength))
        
        //Sort by rawValue to ensure That material will be set in correct subsecuence [front, right, back, left, top, bot]
        sides.sort(by: { $0.name.rawValue < $1.name.rawValue })
        
        return sides
    }

    //only one bone never has parent, it is superParent
    func getParent(for bone: AddonBone) -> AddonBone {
        if let boneParentName = bone.parentName,
           let parent = allBones.first(where: { $0.name == boneParentName }) {

           return parent

        } else {
            return superParent
        }
    }
    
    private func convertIntoScnDimension(_ arrToConvert: [Float]) -> [Float] {
        var resultArr = arrToConvert
        resultArr[0] *= -1
        resultArr[2] *= -1
        
        return resultArr
    }
}


//MARK: Constructor Enteties

struct AddonBone {
    var name: String
    var parentName: String? // even if Json doesnt containt parent for bone, globalBone will be parent by default
    var pivot: Coordinates3D?
    var position: Coordinates3D
    var rotation: Coordinates3D?
    var cubes: [CubeInfo]?
    
    init() {
        self.name = ""
        self.parentName = nil
        self.pivot = Coordinates3D()
        self.position = Coordinates3D()
        self.rotation = nil
        self.cubes = []
    }

}

struct TextureSize {
    var width = Int()
    var height = Int()
    
    init() {
        self.width = 0
        self.height = 0
    }
    
    init(size: CGSize) {
        self.width = Int(size.width)
        self.height = Int(size.height)
    }
}

struct CubeInfo {

    var uv: [Int]?
    var uv6: [Int]?
    var name: String
    var parentName: String
    var width: Float
    var height: Float
    var length: Float
    var rotation: [Float]?
    var pivot: Coordinates3D
    var geometry: Coordinates3D
    var isThumbnail: Bool
//    var thumbShowFillColor: UIColor
//    var thumbHideFillColor: UIColor

    var cubeSides: [CubeSide]
    
    init() {
        self.uv = [0, 0]
        self.name = ""
        self.parentName = ""
        self.width = 0.0
        self.height = 0.0
        self.length = 0.0
        self.rotation = nil
        self.pivot = Coordinates3D()
        self.geometry = Coordinates3D()
        self.cubeSides = []
        self.isThumbnail = false
//        self.thumbShowFillColor = #colorLiteral(red: 0.0862745098, green: 0.4039215686, blue: 0.3411764706, alpha: 0.5)
//        self.thumbHideFillColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 0.5390067195)
    }
}

struct Coordinates3D {
    var x: Float
    var y: Float
    var z: Float
    
    init() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }
    
    init(_ coordinates: [Float]) {
        self.x = coordinates[0]
        self.y = coordinates[1]
        self.z = coordinates[2]
    }
    
    func asFloatArr() -> [Float] {
        return [x, y, z]
    }
    
    var multipliedByMinusOne: Coordinates3D {
        return .init([-x, -y, -z])
    }
    
}

struct CubeSide {
    var name: CubeSideName
    var startX: Int
    var startY: Int
    var sideWidth: Int
    var sideHeight: Int
}

enum CubeSideName: Int {
    case front = 0
    case left = 3
    case back = 2
    case right = 1
    case top = 4
    case bottom = 5
}
