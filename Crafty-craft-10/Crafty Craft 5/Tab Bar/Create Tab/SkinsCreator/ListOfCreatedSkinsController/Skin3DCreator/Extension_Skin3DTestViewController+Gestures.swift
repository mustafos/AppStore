

import Foundation
import SceneKit
import UIKit



extension Skin3DTestViewController {
    //MARK: Gestures
    @objc func tapOnSceneAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let targetView = sender.view
            let touchLocation = sender.location(in: targetView)
            
            guard let hitTestResult = sceneView.hitTest(touchLocation, options: [:]).first else { return }
            let node = hitTestResult.node
            
            if let index = Int(node.name ?? ""), let rootNodeName = node.parent?.name {
                editorSkinModel.tapToDrawingOnSkin(nameRootNod: rootNodeName, nodeIndex: index, gestureState: sender.state)
            }
        }
    }
    
    static var locationOfBeganTap: CGPoint = .zero
    static var cameraControll: Bool = false
    
    @objc func panOnSceneAction(_ sender: UIPanGestureRecognizer) {
        let targetView = sender.view
        let touchLocation = sender.location(in: targetView)
        let gestureState = sender.state
        
        switch sender.state {
        case .began:
            guard let hitTestResult = sceneView.hitTest(touchLocation, options: [:]).first else {
                Self.cameraControll = true
                Self.locationOfBeganTap = sender.location(in: view)
                return
            }
            Self.cameraControll = false
            let node = hitTestResult.node
            if let index = Int(node.name ?? ""), let parentNodeName = node.parent?.name {
                editorSkinModel.panBeganToDrawingOnSkin(nameRootNod: parentNodeName, nodeIndex: index, gestureState: gestureState)
            }
        case .changed:
            if Self.cameraControll {
                var newLocation = sender.location(in: view)
                newLocation = .init(x: newLocation.x, y: newLocation.y)
                sceneView.defaultCameraController.rotateBy(x: Float(Self.locationOfBeganTap.x - newLocation.x)/1.5, y: Float(Self.locationOfBeganTap.y - newLocation.y )/1.5)
                Self.locationOfBeganTap = newLocation
            } else {
                guard let hitTestResult = sceneView.hitTest(touchLocation, options: [:]).first else { return }
                let node = hitTestResult.node
                if let index = Int(node.name ?? ""), let parentNodeName = node.parent?.name {
                    editorSkinModel.panChangedToDrawingOnSkin(nameRootNod: parentNodeName, nodeIndex: index, gestureState: gestureState)
                }
            }
            
        case .ended:
            guard !Self.cameraControll else { return }
            editorSkinModel.panEndedToDrawingOnSkin()
        case .cancelled, .possible, .failed:
            break
        @unknown default:
            break
        }
    }
    
    @objc func didPanGEtureforPicker(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .changed:
            guard let hitResult = sceneView.hitTest(location, options: [:]).first else { return }
            let node = hitResult.node
            if let _ = Int(node.name ?? "") {
                let color = node.geometry?.firstMaterial?.diffuse.contents as? UIColor
                magnifyingGlassView?.update(with: color ?? UIColor.clear, point: location)
            }
        case .ended, .cancelled:
            if let peckedColor = magnifyingGlassView?.backgroundColor, peckedColor.alpha != 0 {
                editorSkinModel.addNewColorToPalitrs(peckedColor)
                editorSkinModel.currentDrawingColor = peckedColor
            }
            
            hideMagnifyingGlass()
        default:
            break
        }
    }
    
    @objc func handleDoubleTap() {
        sceneView.rendersContinuously = true
        sceneView.pointOfView = startingPointOfView
        AppDelegate.log("Double Tap!")
    }
}
