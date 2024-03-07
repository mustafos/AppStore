
import SceneKit
import Foundation


final class SceneLogicModel {
    
    //MARK: Properties
    var currentEditableModel: AnatomyCreatedModel?
    //    var currentEditableModel: SkinCreatedModel? {
    //        didSet {
    //            self.setupSteveNodes()
    //        }
    //    }
    
    var assemblyDiagramSize: AssemblyDiagramDimensions = .dimensions64x64
    
    var scene = SCNScene()
    private let camera = SCNCamera()
    let cameraNode = SCNNode()
    
    //rootNode which contains all BodyPartSideNodes
    private lazy var rootNode = scene.rootNode
    
    private var defaultPosition = [SCNVector3]()
    
    // MARK: Init
    
    
    init(assemblyDiagramSize: AssemblyDiagramDimensions, currentEditableModel: AnatomyCreatedModel) {
        guard let scn =  SCNScene(named: "stiv_v5.scn") else {
            return
        }
        self.scene = scn
        self.currentEditableModel = currentEditableModel
        self.assemblyDiagramSize = assemblyDiagramSize
        setupScene()
    }
    
    func saveDefoultPositions() {
        scene.rootNode.childNodes.forEach { node in
            if node.name != cameraNode.name {
                defaultPosition.append(node.position)
            }
        }
    }
    
    func becomeToDefoultPosition() {
//        defaultPosition.forEach { defPosition in
//
//        }
//        for i in 0..<(scene.rootNode.childNodes.count - 1) {
//            if scene.rootNode.childNodes[i].name != cameraNode.name {
//                scene.rootNode.childNodes[i].position = defaultPosition[i]
//            }
//        }
    }
    
    //MARK: Private Functions
    
    private func setupScene() {
        cameraNode.name = "CameraNode"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 2.7, z: -16)
        let constraint = SCNLookAtConstraint(target: rootNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        scene.rootNode.addChildNode(cameraNode)
        
        setupSteveNodes()
        hightLightOtsideNodes()
//        defaultPosition.append(cameraNode.position)
    }
    
    var outsideNodes: [SCNNode] {
        rootNode.childNodes.filter({ $0.name?.contains("1") ?? false })
    }
    
    private func setupSteveNodes()  {
        
        outsideNodes.forEach({ 
            guard let material = $0.geometry?.firstMaterial else {
                return
            }
            material.transparency = 0.5
        })
    
        for theNode in rootNode.childNodes {
            if assemblyDiagramSize == .dimensions64x64 {
                guard let side = CubicHuman.BodyPart.allSides().first(where: {$0.name == theNode.name }) else {
                    return
                }
                
                guard let colorsArr = currentEditableModel?.skinAssemblyDiagram?.extractPixelColors(width: side.width,
                                                                                                    height: side.height,
                                                                                                    startX: side.startX,
                                                                                                    startY: side.startY) else {
                    AppDelegate.log("SceneLogic couldnt extract array of colors")
                    return
                }
                setupSideNode(parentNode: theNode, side: side, colors: colorsArr)
            } else {
                guard let side = CubicHuman.BodyPart.allSides128().first(where: {$0.name == theNode.name }) else {
                    return
                }
                guard let colorsArr = currentEditableModel?.skinAssemblyDiagram128?.extractPixelColors(width: side.width,
                                                                                                       height: side.height,
                                                                                                       startX: side.startX,
                                                                                                       startY: side.startY) else {
                    AppDelegate.log("SceneLogic couldnt extract array of colors")
                    return
                }
                
                setupSideNode(parentNode: theNode, side: side, colors: colorsArr)
            }
            defaultPosition.append(rootNode.position)
        }
//        defaultPosition = scene.rootNode.position
    }
    
    
    
    ///Create & Color each side canvas
    private func setupSideNode(parentNode: SCNNode, side: Side, colors: [UIColor]) {
        
        let numRows = side.height
        let numColumns = side.width
        
        let xOffset = 0.01 // Adjust the horizontal offset between pixels
        let yOffset = 0.01 // Adjust the vertical offset between pixels
        
        let boundingBox = parentNode.boundingBox
        let rootNodeSize = CGSize(width: CGFloat(boundingBox.max.x - boundingBox.min.x),
                                  height: CGFloat(boundingBox.max.y - boundingBox.min.y))
        
        let pixelSize = CGSize(width: rootNodeSize.width / CGFloat(numColumns) - xOffset,
                               height: rootNodeSize.height / CGFloat(numRows) - yOffset)
        
        // Calculate the starting position of the grid to align with the top-left corner of the rootNode
        let startX = -(rootNodeSize.width / 2) + (pixelSize.width / 2)
        let startY = rootNodeSize.height / 2 - (pixelSize.height / 2)
        
        // Iterate over rows and columns to create the plane nodes
        
        var colorIndex = 0
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                
                let xPos = Float(startX) + Float(column) * (Float(pixelSize.width) + Float(xOffset))
                let yPos = Float(startY) - Float(row) * (Float(pixelSize.height) + Float(yOffset))
                
                let pixelNode = ScnPixel(width: pixelSize.width, height: pixelSize.height)
                pixelNode.position = SCNVector3(x: xPos, y: yPos, z: 0.0009)
                pixelNode.name = String(colorIndex)
                
                ///check if colror is clear
                ///standart .clear always fails
                /// else it will be colored into default color
                
                if colors[colorIndex].cgColor.alpha != 0 {
                    pixelNode.fillColor = colors[colorIndex]
                } else {
                    if parentNode.name!.contains("1") {
                        pixelNode.fillColor = colors[colorIndex]
                    }
                }
                
                
                // Add the plane node to the parent node
                parentNode.addChildNode(pixelNode)
                
                colorIndex += 1
            }
        }
    }

}


extension SceneLogicModel {
    func hightLightOtsideNodes() {
        for node in outsideNodes {
            highlightNode(node)
        }
    }
    
    func unHightLightOtsideNodes() {
        for node in outsideNodes {
            unhighlightNode(node)
        }
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
}
