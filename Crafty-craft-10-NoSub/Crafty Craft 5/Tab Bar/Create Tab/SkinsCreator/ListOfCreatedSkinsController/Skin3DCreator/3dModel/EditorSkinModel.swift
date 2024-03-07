import Foundation
import UIKit
import SceneKit

enum BrashSize: Int, CaseIterable {
    case one = 1
    case two = 2
    case four = 4
    case six = 6
    case eight = 8
}

enum ToolBar3DSelectedItem {
    case pencil
    case eraser
    case brash
    case fill
    case noise
    case undo
}


class EditorSkinModel {
    private(set) weak var controller: ThreeDSkinTestViewController!
    
    private(set) var magnifyingGlassView: MagnifyingGlassView?
    lazy var currentDrawingColor: UIColor = controller.colorManager3D.getColor(by: 0) {
        didSet {
            controller.colorManager3D.updateColorsArr(with: currentDrawingColor)
        }
    }
    
    var brashSize: BrashSize = .one
    
    private(set) var assemblyDiagramSize: AssemblyDiagramDimensions = .dimensions64x64
    private(set) var skinCreatedModel: AnatomyCreatedModel?
    
    private var colorlForSideNodes: [String:[UIColor]] = [CubicHuman.BodyPart.head.top.name:[UIColor](), CubicHuman.BodyPart.head.bottom.name:[UIColor](), CubicHuman.BodyPart.head.front.name:[UIColor](), CubicHuman.BodyPart.head.back.name:[UIColor](), CubicHuman.BodyPart.head.right.name:[UIColor](), CubicHuman.BodyPart.head.left.name:[UIColor](), CubicHuman.BodyPart.body.top.name:[UIColor](), CubicHuman.BodyPart.body.bottom.name:[UIColor](), CubicHuman.BodyPart.body.front.name:[UIColor](), CubicHuman.BodyPart.body.back.name:[UIColor](), CubicHuman.BodyPart.body.right.name:[UIColor](), CubicHuman.BodyPart.body.left.name:[UIColor](), CubicHuman.BodyPart.rightArm.top.name:[UIColor](), CubicHuman.BodyPart.rightArm.bottom.name:[UIColor](), CubicHuman.BodyPart.rightArm.front.name:[UIColor](), CubicHuman.BodyPart.rightArm.back.name:[UIColor](), CubicHuman.BodyPart.rightArm.right.name:[UIColor](), CubicHuman.BodyPart.rightArm.left.name:[UIColor](), CubicHuman.BodyPart.leftArm.top.name:[UIColor](), CubicHuman.BodyPart.leftArm.bottom.name:[UIColor](), CubicHuman.BodyPart.leftArm.front.name:[UIColor](), CubicHuman.BodyPart.leftArm.back.name:[UIColor](), CubicHuman.BodyPart.leftArm.right.name:[UIColor](), CubicHuman.BodyPart.leftArm.left.name:[UIColor](), CubicHuman.BodyPart.rightLeg.top.name:[UIColor](), CubicHuman.BodyPart.rightLeg.bottom.name:[UIColor](), CubicHuman.BodyPart.rightLeg.front.name:[UIColor](), CubicHuman.BodyPart.rightLeg.back.name:[UIColor](), CubicHuman.BodyPart.rightLeg.right.name:[UIColor](), CubicHuman.BodyPart.rightLeg.left.name:[UIColor](), CubicHuman.BodyPart.leftLeg.top.name:[UIColor](), CubicHuman.BodyPart.leftLeg.bottom.name:[UIColor](), CubicHuman.BodyPart.leftLeg.front.name:[UIColor](), CubicHuman.BodyPart.leftLeg.back.name:[UIColor](), CubicHuman.BodyPart.leftLeg.right.name:[UIColor](), CubicHuman.BodyPart.leftLeg.left.name:[UIColor]()]
    private var tempColorForSideNodes = [String:[UIColor]]()
    
    private var drawSkinCommands = SkinDrawCommand()
    private var tempSkinUndoCommand = SkinCommand()
    private var tempSkinRedoCommand = SkinCommand()
    
    private var commandIndex = 0
    private var nodeIndexForGesture: Int = 0
    
    //MARK: init
    init(viewController: ThreeDSkinTestViewController, skinCreatedModel: AnatomyCreatedModel, assemblyDiagramSize: AssemblyDiagramDimensions) {
        controller = viewController
        
        self.assemblyDiagramSize = assemblyDiagramSize
        self.skinCreatedModel = skinCreatedModel
        if assemblyDiagramSize == .dimensions64x64 {
            getColorsFromAssemblyDiagram(skinAssemblyDiagram: skinCreatedModel.skinAssemblyDiagram ?? UIImage())
        } else {
            getColorsFromAssemblyDiagram(skinAssemblyDiagram: skinCreatedModel.skinAssemblyDiagram128 ?? UIImage())
        }
    }
    
    deinit {
        AppDelegate.log("EditorSkinModel - deinited!")
    }
    
    func addNewColorToPalitrs(_ newColor: UIColor) {
        controller.colorManager3D.addNewColor(color: newColor)
    }
    
    private func getColorsFromAssemblyDiagram(skinAssemblyDiagram: UIImage) {
        if assemblyDiagramSize == .dimensions64x64 {
            CubicHuman.BodyPart.allSides().forEach { bodyPartSide in
                colorlForSideNodes[bodyPartSide.name] = skinAssemblyDiagram.extractPixelColors(width: bodyPartSide.width, height: bodyPartSide.height, startX: bodyPartSide.startX, startY: bodyPartSide.startY)
            }
        } else {
            CubicHuman.BodyPart.allSides128().forEach { bodyPartSide in
                colorlForSideNodes[bodyPartSide.name] = skinAssemblyDiagram.extractPixelColors(width: bodyPartSide.width, height: bodyPartSide.height, startX: bodyPartSide.startX, startY: bodyPartSide.startY)
            }
        }
        tempColorForSideNodes = colorlForSideNodes
    }
    
    func makeUndoDrawCommand() {
        if commandIndex > 0 {
            let command = drawSkinCommands.undoCommands[commandIndex - 1]
            for i in 0..<command.indexes.count {
                let rNodeName = command.nodeName[i]
                colorlForSideNodes[rNodeName]?[command.indexes[i]] = command.colors[i]
                
                controller.sceneView.scene?.rootNode.childNodes.forEach({ sideNode in
                    if sideNode.name == rNodeName {
                        sideNode.childNodes.forEach { pixelNode in
                            if Int(pixelNode.name ?? "0") == command.indexes[i] {
                                if let color = pixelNode.geometry?.firstMaterial?.diffuse.contents as? UIColor, color == command.colors[i] {} else {
                                    pixelNode.geometry?.firstMaterial?.diffuse.contents = command.colors[i]
                                }
                            }
                        }
                    }
                })
            }
            commandIndex -= 1
        }
    }
    
    //MARK: Drawing logic
    
    internal func tapToDrawingOnSkin(nameRootNod: String, nodeIndex: Int, gestureState: UIGestureRecognizer.State) {
        if let nodeColors = colorlForSideNodes[nameRootNod] {
            tapDrawLogic(nodeColors: nodeColors, nodeIndex: nodeIndex, nameRootNod: nameRootNod, gestureState: gestureState)
        }
    }
    
    internal func panBeganToDrawingOnSkin(nameRootNod: String, nodeIndex: Int, gestureState: UIGestureRecognizer.State) {
        tempSkinRedoCommand.clearCommand()
        tempSkinUndoCommand.clearCommand()
        
        let undoCommandCount = drawSkinCommands.undoCommands.count
        let redoCommandCount = drawSkinCommands.redoCommands.count
        
        let dropUndoCount = max(0, undoCommandCount - commandIndex)
        drawSkinCommands.undoCommands = Array(drawSkinCommands.undoCommands.dropLast(dropUndoCount))
        
        let dropRedoCount = max(0, redoCommandCount - commandIndex)
        drawSkinCommands.redoCommands = Array(drawSkinCommands.redoCommands.dropLast(dropRedoCount))
        
        nodeIndexForGesture = nodeIndex
        panDrawLogic(index: nodeIndex, nameRootNode: nameRootNod, gestureState: gestureState)
    }
    
    internal func panChangedToDrawingOnSkin(nameRootNod: String, nodeIndex: Int, gestureState: UIGestureRecognizer.State) {
        if nodeIndexForGesture != nodeIndex {
            panDrawLogic(index: nodeIndex, nameRootNode: nameRootNod, gestureState: gestureState)
            nodeIndexForGesture = nodeIndex
        }
    }
    
    internal func panEndedToDrawingOnSkin() {
        if drawSkinCommands.undoCommands.count > commandIndex {
            drawSkinCommands.undoCommands.removeLast(drawSkinCommands.undoCommands.count - commandIndex)
        }
        drawSkinCommands.undoCommands.append(tempSkinUndoCommand)
        drawSkinCommands.redoCommands.append(tempSkinRedoCommand)
        commandIndex += 1
    }
    
    private func tapDrawLogic(nodeColors: [UIColor], nodeIndex: Int, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        switch controller.toolBarSelectedItem {
        case .pencil, .brash:
            sizeBrushWith(color: currentDrawingColor, forIndex: nodeIndex, nameRootNod: nameRootNod, gestureState: gestureState)
        case .eraser:
            sizeBrushWith(color: .clear, forIndex: nodeIndex, nameRootNod: nameRootNod, gestureState: gestureState)
        case .fill:
            let colorsIndex = Array(0..<nodeColors.count)
            if drawSkinCommands.undoCommands.count > commandIndex {
                drawSkinCommands.undoCommands.removeLast(drawSkinCommands.undoCommands.count - commandIndex)
            }
            
            drawSkinCommands.undoCommands.append(SkinCommand(indexes: colorsIndex, colors: nodeColors, nodeName: Array(repeating: nameRootNod, count: colorsIndex.count)))
            commandIndex += 1
            
            for index in 0..<nodeColors.count {
                colorlForSideNodes[nameRootNod]?[index] = currentDrawingColor
            }
            
            controller.sceneView.scene?.rootNode.childNodes.forEach({ sideNode in
                if sideNode.name == nameRootNod {
                    sideNode.childNodes.forEach { pixelNode in
                        if pixelNode.name != nameRootNod {
                            if let color = pixelNode.geometry?.firstMaterial?.diffuse.contents as? UIColor, color == currentDrawingColor {} else {
                                pixelNode.geometry?.firstMaterial?.diffuse.contents = currentDrawingColor
                            }
                        }
                    }
                }
            })
            
            drawSkinCommands.redoCommands.append(SkinCommand(indexes: colorsIndex, colors: colorlForSideNodes[nameRootNod] ?? [], nodeName: Array(repeating: nameRootNod, count: colorsIndex.count)))
        case .noise:
            let noiseColor = makeNoiseColor()
            sizeBrushWith(color: noiseColor, forIndex: nodeIndex, nameRootNod: nameRootNod, gestureState: gestureState)
        case .undo:
            break
        }
    }
    
    private func sizeBrushWith(color: UIColor, forIndex index: Int, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        switch brashSize {
        case .one:
            changePixelArray(indexArray: [index], color: color, nameRootNod: nameRootNod, gestureState: gestureState)
        case .two:
            return getIndexesForSecondBrash(startIndex: index, color: color, nameRootNod: nameRootNod, gestureState: gestureState)
        case .four:
            return getIndexesForForthBrash(startIndex: index, color: color, nameRootNod: nameRootNod, gestureState: gestureState)
        case .six:
            return getIndexesForSixBrash(startIndex: index, color: color, nameRootNod: nameRootNod, gestureState: gestureState)
        case .eight:
            return getIndexesForEightBrash(startIndex: index, color: color, nameRootNod: nameRootNod, gestureState: gestureState)
        }
    }
    
    private func changePixelArray(indexArray: [Int], color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        if let node = controller.sceneView.scene!.rootNode.childNodes.first(where: { $0.name == nameRootNod }) {
            if node.childNodes.contains(where: { $0.name != node.name && Int($0.name ?? "0") == (indexArray.first ?? 0) }) {
                let oldColors = getColorsFromSkinNodes(by: indexArray, node: node)

                if gestureState == .ended {
                    if drawSkinCommands.undoCommands.count > commandIndex {
                        drawSkinCommands.undoCommands.removeLast(drawSkinCommands.undoCommands.count - commandIndex)
                    }
                    drawSkinCommands.undoCommands.append(SkinCommand(indexes: indexArray, colors: oldColors, nodeName: Array(repeating: nameRootNod, count: indexArray.count)))
                    commandIndex += 1
                } else if gestureState == .began {
                    for i in 0..<indexArray.count {
                        tempSkinUndoCommand.colors.append(oldColors[i])
                        tempSkinUndoCommand.indexes.append(indexArray[i])
                        tempSkinUndoCommand.nodeName.append(nameRootNod)
                    }
                } else if gestureState == .changed {
                    for i in 0..<indexArray.count {
                        if tempSkinUndoCommand.indexes.contains(indexArray[i]) {
                            var nodeNames = [String]()
                            for j in 0..<tempSkinUndoCommand.indexes.count {
                                if tempSkinUndoCommand.indexes[j] == indexArray[i] {
                                    nodeNames.append(tempSkinUndoCommand.nodeName[j])
                                }
                            }
                            if !nodeNames.contains(nameRootNod) {
                                tempSkinUndoCommand.colors.append(oldColors[i])
                                tempSkinUndoCommand.indexes.append(indexArray[i])
                                tempSkinUndoCommand.nodeName.append(nameRootNod)
                            }
                        } else {
                            tempSkinUndoCommand.colors.append(oldColors[i])
                            tempSkinUndoCommand.indexes.append(indexArray[i])
                            tempSkinUndoCommand.nodeName.append(nameRootNod)
                        }
                    }
                }
                
                for i in indexArray {
                    var newColor = UIColor()
                    switch controller.toolBarSelectedItem {
                    case .fill:
                        break
                    case .pencil, .brash:
                        newColor = color
                    case .noise:
                        newColor = makeNoiseColor()
                    case .eraser:
                        newColor = .clear
                    case .undo:
                        break
                    }
                    colorlForSideNodes[nameRootNod]?[i] = newColor
                    if let color = node.childNodes[i].geometry?.firstMaterial?.diffuse.contents as? UIColor, color == newColor {
                        
                    } else {
                        print("NOT REUSE")
                        node.childNodes[i].geometry?.firstMaterial?.diffuse.contents = newColor
                    }
                    
                }
                
                let newColors = getColorsFromSkinNodes(by: indexArray, node: node)
                
                if gestureState == .ended {
                    drawSkinCommands.redoCommands.append(SkinCommand(indexes: indexArray, colors: newColors, nodeName: Array(repeating: nameRootNod, count: indexArray.count)))
                } else if gestureState == .began {
                    for i in 0..<indexArray.count {
                        tempSkinRedoCommand.colors.append(oldColors[i])
                        tempSkinRedoCommand.indexes.append(indexArray[i])
                        tempSkinRedoCommand.nodeName.append(nameRootNod)
                    }
                } else if gestureState == .changed {
                    for i in 0..<indexArray.count {
                        if tempSkinRedoCommand.indexes.contains(indexArray[i]) {
                            for j in 0..<tempSkinRedoCommand.indexes.count {
                                if tempSkinRedoCommand.indexes[j] == indexArray[i] {
                                    if tempSkinRedoCommand.nodeName[j] == nameRootNod {
                                        tempSkinRedoCommand.colors[j] = newColors[i]
                                        break
                                    } else {
                                        tempSkinRedoCommand.colors.append(newColors[i])
                                        tempSkinRedoCommand.indexes.append(indexArray[i])
                                        tempSkinRedoCommand.nodeName.append(nameRootNod)
                                        break
                                    }
                                } else {
                                    tempSkinRedoCommand.colors.append(newColors[i])
                                    tempSkinRedoCommand.indexes.append(indexArray[i])
                                    tempSkinRedoCommand.nodeName.append(nameRootNod)
                                    break
                                }
                            }
                        } else {
                            tempSkinRedoCommand.colors.append(newColors[i])
                            tempSkinRedoCommand.indexes.append(indexArray[i])
                            tempSkinRedoCommand.nodeName.append(nameRootNod)
                        }
                    }
                }
            }
        }
    }
    
    private func getSquareIndices(rows: Int, columns: Int, centerIndex: Int, width: Int) -> [Int] {
        // Convert 1D index to 2D coordinates
        func get2DCoordinates(from index: Int, rows: Int, columns: Int) -> (Int, Int) {
            return (index / columns, index % columns)
        }
        
        func get1DIndex(from row: Int, column: Int, columns: Int) -> Int {
            return row * columns + column
        }
        
        let lastIndex = rows * columns
        
        let (centerRow, centerCol) = get2DCoordinates(from: centerIndex, rows: rows, columns: columns)
        
        // Calculate starting row and column for the square
        var startRow = centerRow - width/2
        var startCol = centerCol - width/2
        
        let minX = min(width, rows)
        let minY = min(width, columns)
        
        // Boundary checks
        if startRow < 0 { startRow = 0 }
        if startCol < 0 { startCol = 0 }
        if startRow + minX > rows { startRow = rows - minX }
        if startCol + minY > columns { startCol = columns - minY }
        
        var result = [Int]()
        
        for i in 0..<minX {
            for j in 0..<minY {
                let updatedI = startRow + i
                let updatedJ = startCol + j
                if updatedI >= 0, updatedJ >= 0 {
                    let updatedIndex = get1DIndex(from: updatedI, column: updatedJ, columns: columns)
                    if updatedIndex < lastIndex {
                        result.append(updatedIndex)
                    }
                }
            }
        }
        
        return result
    }
    
    //MARK: BrashSize
    private func getIndexesForEightBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State)  {
        return getIndexesForBrash(startIndex: startIndex, color: color, nameRootNod: nameRootNod, gestureState: gestureState, width: 8)
    }
    
    private func getIndexesForSixBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        return getIndexesForBrash(startIndex: startIndex, color: color, nameRootNod: nameRootNod, gestureState: gestureState, width: 6)
    }
    
    private func getIndexesForForthBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        return getIndexesForBrash(startIndex: startIndex, color: color, nameRootNod: nameRootNod, gestureState: gestureState, width: 4)
    }
    
    private func getIndexesForThirdBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        return getIndexesForBrash(startIndex: startIndex, color: color, nameRootNod: nameRootNod, gestureState: gestureState, width: 3)
    }
    
    private func getIndexesForSecondBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State) {
        
        return getIndexesForBrash(startIndex: startIndex, color: color, nameRootNod: nameRootNod, gestureState: gestureState, width: 2)
    }
    
    private func getIndexesForBrash(startIndex: Int, color: UIColor, nameRootNod: String, gestureState: UIGestureRecognizer.State, width: Int) {
        let nodeSize = getSizeForBodyPartSideNode(by: nameRootNod)
        let indexArray = getSquareIndices(rows: nodeSize.height, columns: nodeSize.width, centerIndex: startIndex, width: width)
        
        changePixelArray(indexArray: indexArray, color: color, nameRootNod: nameRootNod, gestureState: gestureState)
    }
    
    //MARK: Pan
    private func panDrawLogic(index: Int, nameRootNode: String, gestureState: UIGestureRecognizer.State) {
        switch controller.toolBarSelectedItem {
        case .pencil, .brash:
            sizeBrushWith(color: currentDrawingColor, forIndex: index, nameRootNod: nameRootNode, gestureState: gestureState)
        case .fill:
            break
        case .noise:
            let noiseColor = makeNoiseColor()
            sizeBrushWith(color: noiseColor, forIndex: index, nameRootNod: nameRootNode, gestureState: gestureState)
        case .eraser:
            sizeBrushWith(color: .clear, forIndex: index, nameRootNod: nameRootNode, gestureState: gestureState)
        case .undo:
            break
        }
    }
    
    private func makeNoiseColor() -> UIColor {
        let noiseVal = 0.95 - 0.4
        let randomNoiseValue = CGFloat.random(in: noiseVal...0.95)
        let color = currentDrawingColor.withLuminosity(randomNoiseValue)
        return color
    }
    
    private func getColorsFromSkinNodes(by indexArray: [Int], node: SCNNode) -> [UIColor] {
        var nodeColors = [UIColor]()
        for i in indexArray {
            if let nodeColor = node.childNodes[i].geometry?.firstMaterial?.diffuse.contents as? UIColor {
                nodeColors.append(nodeColor)
            }
        }
        return nodeColors
    }
    
    private func getColorsFromSkinNodes(by indexArray: [Int], nameRootNod: String) -> [UIColor] {
        var nodeColors = [UIColor]()
        for i in indexArray {
            if let node = controller.sceneView.scene?.rootNode.childNodes.first(where: { $0.name == nameRootNod}) {
                if let nodeColor = node.childNodes[i].geometry?.firstMaterial?.diffuse.contents as? UIColor {
                    nodeColors.append(nodeColor)
                }
            }
        }
        return nodeColors
    }
    
    private func getSizeForBodyPartSideNode(by nameRootNod: String) -> (width: Int, height: Int) {
        var kubHumSides = [Side]()
        if assemblyDiagramSize == .dimensions64x64 {
            kubHumSides = CubicHuman.BodyPart.allSides()
        } else {
            kubHumSides = CubicHuman.BodyPart.allSides128()
        }
        
        var size: (width: Int, height: Int) = (width: 0, height: 0)
        kubHumSides.forEach { side in
            if side.name == nameRootNod {
                size.width = side.width
                size.height = side.height
                return
            }
        }
        return size
    }
    
    //MARK: Save assembly diagram
    func saveSkinsAssemblyDiagram(with name: String) {
        let realm = RealmService.shared
        
        if realm.getCreatedSkinByID(skinID: skinCreatedModel?.id ?? 0) == nil {
            realm.addNewSkin(skin: skinCreatedModel?.getRealmModelToSave() ?? CreatedSkinRM())
        }
        
        if assemblyDiagramSize == .dimensions64x64 {
            let newSkinAssemblyDiagram = createImageWithRawPixels(image: skinCreatedModel?.skinAssemblyDiagram)
            skinCreatedModel?.skinAssemblyDiagram = newSkinAssemblyDiagram
            realm.editCreatedSkinAssemblyDiagram(createdSkin: skinCreatedModel, newDiagram: newSkinAssemblyDiagram)
            realm.editCreatedSkinPreview(createdSkin: skinCreatedModel, newPreview: controller.sceneView.snapshot())
            realm.editCreatedSkinName(createdSkin: skinCreatedModel, newName: name)
        } else {
            let newSkinAssemblyDiagram = createImageWithRawPixels(image: skinCreatedModel?.skinAssemblyDiagram128)
            skinCreatedModel?.skinAssemblyDiagram128 = newSkinAssemblyDiagram
            realm.editCreatedSkinAssemblyDiagram128(createdSkin: skinCreatedModel, newDiagram: newSkinAssemblyDiagram)
            realm.editIsThe128(createdSkin: skinCreatedModel, newValue: true)
            realm.editCreatedSkinPreview(createdSkin: skinCreatedModel, newPreview: controller.sceneView.snapshot())
            realm.editCreatedSkinName(createdSkin: skinCreatedModel, newName: name)
        }
    }
    
    private func createImageWithRawPixels(image: UIImage?) -> UIImage? {
        
        var imgSize = CGSize(width: 64, height: 64)
        
        if assemblyDiagramSize == .dimensions128x128 {
            imgSize = CGSize(width: 128, height: 128)
        }
        
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1)
        
        guard var context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        guard let bitmapContext = context.data else {
            return nil
        }
        
        let pixelBuffer = bitmapContext.bindMemory(to: UInt32.self,
                                                   capacity: Int(imgSize.width) * Int(imgSize.height))
        pixelBuffer.initialize(repeating: 0, count: Int(imgSize.width) * Int(imgSize.height))
        
        image?.draw(in: CGRect(origin: .zero, size: imgSize))
        
        context.setBlendMode(.copy)
        
        if assemblyDiagramSize == .dimensions64x64 {
            CubicHuman.BodyPart.allSides().forEach { side in
                if let colorArrayForSideNode = colorlForSideNodes[side.name] {
                    changeContect(myContext: &context, bodyPartSide: side, colorsArray: colorArrayForSideNode)
                }
            }
        } else {
            CubicHuman.BodyPart.allSides128().forEach { side in
                if let colorArrayForSideNode = colorlForSideNodes[side.name] {
                    changeContect(myContext: &context, bodyPartSide: side, colorsArray: colorArrayForSideNode)
                }
            }
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    private func noNanColor(_ color: UIColor) -> UIColor? {
        guard let components = color.cgColor.components else { return nil}
        let red: CGFloat = components.count > 0 ? components[0] : 0
        let green: CGFloat = components.count > 1 ? components[1] : 0
        let blue: CGFloat = components.count > 2 ? components[2] : 0
        
        
        return .init(red: red.isNaN ? 255 : red,
                     green: green.isNaN ? 255 : green,
                     blue: blue.isNaN ? 255 : blue,
                     alpha: color.cgColor.alpha.isNaN ? 1 : color.cgColor.alpha)
    }
    
    private func changeContect(myContext: inout CGContext, bodyPartSide: Side, colorsArray: [UIColor]) {
        var correctIndex = 0
        
        for y in (0..<bodyPartSide.height) {
            for x in (0..<bodyPartSide.width) {
                let index = y * bodyPartSide.width + x
                guard index < colorsArray.count else {
                    continue
                }
                
                let rawPixel = noNanColor(colorsArray[correctIndex]) ?? UIColor.clear
                
                let color = UIColor(
                    red: CGFloat(rawPixel.rgb()?.0 ?? 255) / 255.0,
                    green: CGFloat(rawPixel.rgb()?.1 ?? 255) / 255.0,
                    blue: CGFloat(rawPixel.rgb()?.2 ?? 255) / 255.0,
                    alpha: CGFloat(rawPixel.rgb()?.3 ?? 255) / 255.0
                )
                
                myContext.setFillColor(color.cgColor)
                myContext.fill(CGRect(x: bodyPartSide.startX + x,
                                      y: bodyPartSide.startY + y,
                                      width: 1, height: 1))
                correctIndex += 1
            }
        }
    }
}
