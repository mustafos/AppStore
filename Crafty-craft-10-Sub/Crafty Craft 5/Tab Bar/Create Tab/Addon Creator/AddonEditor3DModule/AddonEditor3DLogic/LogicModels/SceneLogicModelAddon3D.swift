

import SceneKit
import Foundation

final class SceneLogicModelAddon3D {
    
    //MARK: Properties
    
    var addonModel: AddonConstructorModel?
    var resourcePack: ResourcePack
    
    var scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    var headNode: SCNNode?
    
    //rootNode which contains all BodyPartSideNodes
    lazy var rootNode = scene.rootNode
    
    private var cubsNodes: [SCNNode] = []
    
    // MARK: - Init
    //NormalScene
    init(resourcePack: ResourcePack) {
        self.resourcePack = resourcePack
        self.addonModel = AddonConstructorModel(resourcePack: resourcePack)
        self.setupScene()
    }
    
    //SmallScene
    init(resourcePack: ResourcePack, visibleColor: UIColor, hideColor: UIColor) {
        self.resourcePack = resourcePack
        self.addonModel = AddonConstructorModel(resourcePack: resourcePack, modelColor: visibleColor, hideColor: hideColor)
        self.setupScene()
    }
    
    private func setupScene() {
        setUpCamera()
        drawAddonInScene()
    }
    
    private func setUpCamera() {
        cameraNode.name = "CameraNode"
        
        camera.zFar = 350
        
        cameraNode.camera = camera
        let cameraOffsetMultiplier: Float = 3
        
        let (minX, maxX) = resourcePack.widthGeometrySize()
        let (minY, maxY) = resourcePack.heightGeometrySize()
        let (_, maxZ) = resourcePack.depthGeometrySize()
        let xCameraPosition = (minX + maxX) / 2
        let yCameraPosition = (minY + maxY) / 2
        var zCameraPosition =  maxZ
        
        if maxX - xCameraPosition > zCameraPosition {
            zCameraPosition = maxX - xCameraPosition
        }
        
        if maxY - yCameraPosition > zCameraPosition {
            zCameraPosition = maxY - yCameraPosition
        }
        
        cameraNode.simdPosition = SIMD3(x: xCameraPosition,
                                        y: yCameraPosition,
                                        z: max(zCameraPosition * cameraOffsetMultiplier, 25))
        
        let constraint = SCNLookAtConstraint(target: rootNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        scene.rootNode.addChildNode(cameraNode)
    }
    
    //MARK: - Add Nodes to Scene
    
    private func drawAddonInScene() {
        guard let addonModel = self.addonModel else { return }
        addBoneNodesToScene(bones: addonModel.allBones)
        hightLightCubes()
    }
    
    func hightLightCubes() {
        for cub in cubsNodes {
            highlightNode(cub)
        }
    }
    
    func unHightLightCubes() {
        for cub in cubsNodes {
            unhighlightNode(cub)
        }
    }
    
    //MARK: - Convert Model into Nodes
    
    func addBoneNodesToScene(bones: [AddonBone]) {
        
        //Create superParentNode - will be usefull in model scaling
        //All nodes that dont have parent - will be child of superParentNode
        let superParentNode = SCNNode()
        superParentNode.name = addonModel?.superParent.name
        superParentNode.simdPosition = SIMD3(0,0,0)
        var allNodes: [SCNNode] = [superParentNode]
        
        var cubsArray: [SCNNode] = []
        
        for bone in bones {
            var boneNode = SCNNode()
            boneNode.name = bone.name
            
            if boneNode.name == "superParent" {
                boneNode.simdPosition = SIMD3(0, 0, 0)
            } else {
                boneNode.simdPosition = SIMD3(bone.position.x,
                                              bone.position.y,
                                              bone.position.z)
                if let bonePivot = bone.pivot {
                    boneNode.pivot = SCNMatrix4MakeTranslation(bonePivot.x, bonePivot.y, bonePivot.z)
                }

            }

            if let parentNode = allNodes.first(where: { $0.name == bone.parentName }) {
                parentNode.addChildNode(boneNode)
            }
            
                            
            if let boneRotation = bone.rotation {
                boneNode.eulerAngles = .init(deg2rad(-boneRotation.x), deg2rad(boneRotation.y), deg2rad(-boneRotation.z))
            }

            if var cubeModel = bone.cubes {
                let cubes = createCubeNodes(cubeModels: cubeModel)
                cubes.forEach({ boneNode.addChildNode($0) })
                cubsArray.append(contentsOf: cubes)
            }
            
            allNodes.append(boneNode)
        }
        
        cubsNodes = cubsArray
        rootNode.addChildNode(superParentNode)
    }
    
    
    private func createLineNode(fromPos origin: SCNVector3, toPos destination: SCNVector3, color: UIColor) -> SCNNode {
        let line = lineFrom(vector: origin, toVector: destination)
        let lineNode = SCNNode(geometry: line)
        let planeMaterial = SCNMaterial()
        planeMaterial.emission.contents = color
        
        lineNode.geometry?.firstMaterial = planeMaterial

        return lineNode
    }

    private func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]

        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)

        return SCNGeometry(sources: [source], elements: [element])
    }


    private func highlightNode(_ node: SCNNode) {
        let (min, max) = node.boundingBox
        
        let topLeftMinZ = SCNVector3Make(min.x, max.y, min.z)
        let bottomLeftMinZ = SCNVector3Make(min.x, min.y, min.z)
        let topRightMinZ = SCNVector3Make(max.x, max.y, min.z)
        let bottomRightMinZ = SCNVector3Make(max.x, min.y, min.z)
        
        let topLeftMaxZ = SCNVector3Make(min.x, max.y, max.z)
        let bottomLeftMaxZ = SCNVector3Make(min.x, min.y, max.z)
        let topRightMaxZ = SCNVector3Make(max.x, max.y, max.z)
        let bottomRightMaxZ = SCNVector3Make(max.x, min.y, max.z)


        let bottomSideMinZ = createLineNode(fromPos: bottomLeftMinZ, toPos: bottomRightMinZ, color: .red.withAlphaComponent(0.5))
        let leftSideMinZ = createLineNode(fromPos: bottomLeftMinZ, toPos: topLeftMinZ, color: .red.withAlphaComponent(0.5))
        let rightSideMinZ = createLineNode(fromPos: bottomRightMinZ, toPos: topRightMinZ, color: .red.withAlphaComponent(0.5))
        let topSideMinZ = createLineNode(fromPos: topLeftMinZ, toPos: topRightMinZ, color: .red.withAlphaComponent(0.5))
        
        let bottomSideMaxZ = createLineNode(fromPos: bottomLeftMaxZ, toPos: bottomRightMaxZ, color: .red.withAlphaComponent(0.5))
        let leftSideMaxZ = createLineNode(fromPos: bottomLeftMaxZ, toPos: topLeftMaxZ, color: .red.withAlphaComponent(0.5))
        let rightSideMaxZ = createLineNode(fromPos: bottomRightMaxZ, toPos: topRightMaxZ, color: .red.withAlphaComponent(0.5))
        let topSideMaxZ = createLineNode(fromPos: topLeftMaxZ, toPos: topRightMaxZ, color: .red.withAlphaComponent(0.5))
        
        let topSideMaxY = createLineNode(fromPos: topLeftMinZ, toPos: topLeftMaxZ, color: .red.withAlphaComponent(0.5))
        let bottomSideMaxY = createLineNode(fromPos: bottomLeftMinZ, toPos: bottomLeftMaxZ, color: .red.withAlphaComponent(0.5))
        let topSideMinY = createLineNode(fromPos: topRightMinZ, toPos: topRightMaxZ, color: .red.withAlphaComponent(0.5))
        let bottomSideMinY = createLineNode(fromPos: bottomRightMinZ, toPos: bottomRightMaxZ, color: .red.withAlphaComponent(0.5))
        

        [bottomSideMinZ, leftSideMinZ, rightSideMinZ, topSideMinZ,
         bottomSideMaxZ, leftSideMaxZ, rightSideMaxZ, topSideMaxZ,
         topSideMaxY, bottomSideMaxY, topSideMinY, bottomSideMinY
        ].forEach {
            $0.name = UUID().uuidString + String.hightlightIdentifier // Whatever name you want so you can unhighlight later if needed
            node.addChildNode($0)
        }
    }

    private func unhighlightNode(_ node: SCNNode) {
        let highlightningNodes = node.childNodes { (child, stop) -> Bool in
            child.name?.contains(String.hightlightIdentifier) ?? false
        }
        highlightningNodes.forEach {
            $0.removeFromParentNode()
        }
    }
    
    //MARK: Debug functions
    
    enum debugEnum {
        case showPivot
        case showPosition
    }
    
    func debugPivot(for node: SCNNode, size: CGFloat = 0.3, color: UIColor, pointType: debugEnum = .showPivot) -> SCNNode {
        // Create a small sphere to represent the pivot
        let pivotGeometry = SCNSphere(radius: size)
        pivotGeometry.firstMaterial?.diffuse.contents = color // Set it to a noticeable color
        let pivotNode = SCNNode(geometry: pivotGeometry)
        
        if pointType == .showPivot {
            // Position the debug node at the pivot point
            let pivotMatrix = node.pivot
            pivotNode.simdPosition = SIMD3(pivotMatrix.m41,
                                            pivotMatrix.m42,
                                            pivotMatrix.m43)
        } else {
            pivotNode.simdPosition = node.simdPosition
        }

        return pivotNode
    }
    
    
    private func deg2rad(_ number: Float) -> Float {
        number * .pi / 180
    }
    
    //MARK: Set Side Material
    ///prepareMaterial for normalSceneModel
    private func prepareSideMaterial(sourcePng: UIImage?, box: inout SCNBox, cubeInfo: CubeInfo) {
        
        var materials = [SCNMaterial]()
        
        for side in cubeInfo.cubeSides {
            
            let material = SCNMaterial()
            material.isDoubleSided = true
            
            if let croppedImage = sourcePng?.crop(startX: side.startX, startY: side.startY, width: side.sideWidth, height: side.sideHeight) {
                material.diffuse.contents = croppedImage
                material.diffuse.magnificationFilter = .nearest
            } else {
                material.diffuse.contents = UIColor.red // placeholder color if the image could not be cropped
            }
            
            materials.append(material)
        }
        
        box.materials = materials
    }
    
    ///Prepare material for thumbnail cube
    private func prepareSideMaterial(box: inout SCNBox) {
        box.materials.first?.diffuse.contents = addonModel?.showCubesColor
    }
    
    
    //MARK: Create Cubes
    
    private func generateRandomCharacter() -> Character {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomIndex = Int.random(in: 0..<characters.count)
        return characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
    }
    
    func createCubeNodes(cubeModels: [CubeInfo]) -> [SCNNode] {
        var resultArr = [SCNNode]()
        
        for cubeModel in cubeModels {
            var box = SCNBox(width: CGFloat(cubeModel.width),
                             height: CGFloat(cubeModel.height),
                             length: CGFloat(cubeModel.length),
                             chamferRadius: 0)
            
            let image = addonModel?.assemblyImg

            if addonModel?.isThumbnail == false {
                prepareSideMaterial(sourcePng: image, box: &box, cubeInfo: cubeModel)
            } else {
                prepareSideMaterial(box: &box)
            }
            
            
            let boxNode = SCNNode(geometry: box)
            boxNode.name = cubeModel.name
            boxNode.simdPosition = SIMD3(cubeModel.geometry.x,
                                     cubeModel.geometry.y,
                                     cubeModel.geometry.z)
            resultArr.append(boxNode)
            
        }
        
        return resultArr
    }
}

extension String {
    static var hightlightIdentifier = "Hightlight"
}

extension UIImage {
    
    func crop(startX: Int, startY: Int, width: Int, height: Int) -> UIImage? {
        
        let rect = CGRect(x: startX, y: startY, width: width, height: height)
        
        // Check if the given coordinates and dimensions are valid
        guard rect.maxX <= size.width, rect.maxY <= size.height, rect.minX >= 0, rect.minY >= 0 else {
            return nil
        }
        
        // Convert the rect to the image's coordinate system
        let cgImage = self.cgImage?.cropping(to: rect)
        
        // Convert the CGImage back to UIImage
        if let croppedCGImage = cgImage {
            return UIImage(cgImage: croppedCGImage)
        }
        
        return nil
    }
}


//MARK: SaveChanges

extension SceneLogicModelAddon3D {
    
    // 1. Helper structure for capturing drawing data.
    func extractDrawingData() -> [DrawingData] {
        var drawingData: [DrawingData] = []
        
        guard let validAddonModel = addonModel else {
            return drawingData
        }

        var boxNodes = [SCNNode]()
        self.rootNode.enumerateChildNodes { (node, stop) in
            if node.geometry is SCNBox {
                boxNodes.append(node)
            }
        }

        for bone in validAddonModel.allBones {
            if let boneCubes = bone.cubes {
                for cubeModel in boneCubes {
                    if let matchedNode = boxNodes.first(where: { $0.name == cubeModel.name }),
                       let matchedBox = matchedNode.geometry as? SCNBox {
                        for side in cubeModel.cubeSides {
                            if let material = matchedBox.materials[safe: side.name.rawValue],
                               let textureImage = material.diffuse.contents as? UIImage {
                                let rect = CGRect(x: side.startX, y: side.startY, width: side.sideWidth, height: side.sideHeight)
                                drawingData.append(DrawingData(image: textureImage, rect: rect))
                            }
                        }
                    }
                }
            }
        }
        
        return drawingData
    }

    func constructImage() -> UIImage? {
        var drawingData: [DrawingData] = []

        if Thread.isMainThread {
            drawingData = extractDrawingData()
        } else {
            DispatchQueue.main.sync {
                drawingData = self.extractDrawingData()
            }
        }

        let totalWidth = addonModel?.textureSizes.width ?? 0
        let totalHeight = addonModel?.textureSizes.height ?? 0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: totalHeight), false, 1.0)

        //Fill enitireImg with cleanColor
        UIColor.clear.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        
        //Draw in img
        drawingData.forEach({ $0.image.draw(in: $0.rect) })
        let assembledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return assembledImage
    }

}


extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


struct DrawingData {
    let image: UIImage
    let rect: CGRect
}

extension SceneLogicModelAddon3D {
    func synchronizeCameras(with targetScene: SCNScene) {
        guard let targetCameraNode = targetScene.rootNode.childNode(withName: "CameraNode", recursively: true) else {
            return
        }

        cameraNode.simdPosition = targetCameraNode.simdPosition
        cameraNode.simdOrientation = targetCameraNode.simdOrientation
    }
}
