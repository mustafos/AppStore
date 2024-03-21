import UIKit
import SceneKit

//MARK: - NoramalScene Gestures

extension AddonEditor3DViewController {
    
    //MARK: DoubleTap
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        
        let targetView = sender.view
        let touchLocation = sender.location(in: targetView)
        
        if sceneView.hitTest(touchLocation, options: [:]).first == nil {
            sceneView.rendersContinuously = true
            sceneView.pointOfView = self.startingPointOfView
            sceneView.setNeedsDisplay()
            AppDelegate.log("Double Tap!")
        }
        
        
    }
    
    //MARK: Tap Draw
    
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        
        guard let vcModel else {
            return
        }
        
        let tapLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapLocation, options: nil)
        
        guard let rooNode = vcModel.scnModel?.rootNode,
              let hitResult = hitResults.first,
              let box = hitResult.node.geometry as? SCNBox else  {
            print("user tapped on scene but didn`t touch 3DModel")
            return
        }

        let face = vcModel.getTouchedFace(hitResult: hitResult, box: box)
        let oldTexture = vcModel.getTextureFromHitPoint(cubeSide: face, hitResult: hitResult)
        let change = CubeChange(touchedFace: face, cubeIdentifier: hitResult.node.name ?? UUID().uuidString, previousTexture: oldTexture)
        
        vcModel.editorAddonModel.undoManager.completeUndoRegistration(for: change, rootNode: rooNode)
        vcModel.editorAddonModel.undoManager.resetTempCubeChanges()
        vcModel.editSideHandeler(hitResult: hitResult, box: box )
    }
    
    //MARK: Pan for Drawing/Erase
    
    static var locationOfBeganTap: CGPoint = .zero
    static var cameraControll: Bool = false
    
    @objc func panOnSceneAction(_ sender: UIPanGestureRecognizer) {
        let targetView = sender.view
        let touchLocation = sender.location(in: targetView)
        
        guard let vcModel else {
            return
        }

        switch sender.state {
        case .began:
            guard let _ = sceneView.hitTest(touchLocation, options: [:]).first else {
                Self.cameraControll = true
                Self.locationOfBeganTap = sender.location(in: view)
                return
            }
            Self.cameraControll = false
            if vcModel.editorAddonModel.undoManager.groupingLevel == 0 {
                vcModel.editorAddonModel.undoManager.beginUndoGrouping()
                print("began")
            }

        case .changed:
            if Self.cameraControll {
                var newLocation = sender.location(in: view)
                newLocation = .init(x: newLocation.x, y: newLocation.y)
                sceneView.defaultCameraController.rotateBy(x: Float(Self.locationOfBeganTap.x - newLocation.x)/1.5, y: Float(Self.locationOfBeganTap.y - newLocation.y )/1.5)
                Self.locationOfBeganTap = newLocation
            } else {
                guard let rooNode = vcModel.scnModel?.rootNode else {
                    print("ERROR")
                    print("Smth went wrong checkUp scnModel !!!")
                    return
                }
                
                let hitTests = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode: 1])
                
                guard hitTests.count > 0 else {
                    return
                }
                
                var uniqNodes: [SCNNode] = []
                for idx in 0...hitTests.count {
                    let hitResult = hitTests[idx]
                    if let box = hitResult.node.geometry as? SCNBox {
                        if uniqNodes.contains(hitResult.node) {
                            break
                        }
                        uniqNodes.append(hitResult.node)
                        let face = vcModel.getTouchedFace(hitResult: hitResult, box: box)
                        let oldTexture = vcModel.getTextureFromHitPoint(cubeSide: face, hitResult: hitResult)
                        let change = CubeChange(touchedFace: face, cubeIdentifier: hitResult.node.name ?? UUID().uuidString, previousTexture: oldTexture)
                        vcModel.editorAddonModel.undoManager.completeUndoRegistration(for: change, rootNode: rooNode)
                        
                        vcModel.editSideHandeler(hitResult: hitResult, box: box)
                    }
                }
            }
        case .ended, .cancelled, .failed:
            guard !Self.cameraControll else { return }
            print(".ended, .cancelled, .failed")
            if vcModel.editorAddonModel.undoManager.groupingLevel > 0 {
                vcModel.editorAddonModel.undoManager.endUndoGrouping()
                vcModel.editorAddonModel.undoManager.resetTempCubeChanges()
            }
        case .possible:
            print("possible")
        @unknown default:
            break
        }
    }
    
    
    //MARK: Pan for MagnifyingGlass
    @objc func panGestureforPicker(_ recognizer: UIPanGestureRecognizer) {
        
        guard let vcModel else {
            return
        }

        let location = recognizer.location(in: recognizer.view)
        
        switch recognizer.state {
            
        case .changed:
            guard let hitResult = sceneView.hitTest(location, options: [:]).first,
                  let box = hitResult.node.geometry as? SCNBox,
                  let color = vcModel.getColorFromHitPoint(hitResult: hitResult, box: box) else {
                
                magnifyingGlassView?.update(with: UIColor.clear, point: location)
                return
            }
            magnifyingGlassView?.update(with: color, point: location)
            
        case .ended, .cancelled:
            if let pickedColor = magnifyingGlassView?.backgroundColor {
                vcModel.editorAddonModel.colorManager3D.addNewColor(color: pickedColor)

                vcModel.editorAddonModel.currentDrawingColor = pickedColor
            }
            
            hideMagnifyingGlass()
        default:
            break
        }
    }
    
    @objc func doubleTapOnSceneAction(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .recognized {
        }
    }
}



//MARK: Thumbnail Gestures

extension AddonEditor3DViewController {
    
    @objc func thumbnailDidTap(_ sender: UITapGestureRecognizer) {
        guard let vcModel else {
            return
        }
        
        let tapLocation = sender.location(in: smallStiveView)
        let hitResults = smallStiveView.hitTest(tapLocation, options: nil)
        
        guard let hitResult = hitResults.first else  {
            print("user tapped on scene but didn`t touch 3DModel")
            return
        }
        let touchedNode = hitResult.node
        
        vcModel.showHideNode(touchedNode: touchedNode)
    }
}
