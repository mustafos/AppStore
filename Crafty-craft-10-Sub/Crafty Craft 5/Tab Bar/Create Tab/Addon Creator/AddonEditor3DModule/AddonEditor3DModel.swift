//
//  AddonEditor3DModel.swift
//  Crafty Craft 5
//
//  Created by 1 on 16.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//
import Photos
import UIKit
import SceneKit
import Foundation

final class AddonEditor3DVCModel {
    private(set) weak var controller: AddonEditor3DViewController!
    
    var scnModel: SceneLogicModelAddon3D?
    var smallScnModel: SceneLogicModelAddon3D?

    var saveTextureManger: SaveRecsourceManager?
    var editorAddonModel = EditorAddonModel()
    
    //MARK: Save Assemby
    
    func saveAssemblyDiagram(_ addonPreview: UIImage, name: String) {
        guard let assemblyDiagram = scnModel?.constructImage() else {
            print("somthing is wrong with your texture")
            return
        }
        saveTextureManger?.updateTexture(newTexture: assemblyDiagram)
        saveTextureManger?.updatePreview(newPreview: addonPreview)
        saveTextureManger?.setupResources()
        saveTextureManger?.saveResourcess(with: name)
    }
    
    //MARK: Init
    
    init(viewController: AddonEditor3DViewController, resourcePack: ResourcePack, savingDelegate: AddonSaveable?) {
        controller = viewController
        self.scnModel = SceneLogicModelAddon3D(resourcePack: resourcePack)
        let visibleColor = #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 0.85)
        let hideColor = #colorLiteral(red: 0.4291685424, green: 0.5411764706, blue: 1, alpha: 0.6724586093)
        self.smallScnModel = SceneLogicModelAddon3D(resourcePack: resourcePack, visibleColor: visibleColor, hideColor: hideColor)

        self.saveTextureManger = SaveRecsourceManager(model: resourcePack, delegate: savingDelegate)
    }
    
    
    //MARK: EditSide
    
    func editSideHandeler(hitResult:  SCNHitTestResult, box: SCNBox) {
        
        // Get texture coordinate and convert to pixel
        let localHitPoint = hitResult.localCoordinates
        
        // Determine which face of the cube was tapped.
        let face = getTouchedFace(hitResult: hitResult, box: box)
        guard let image = getTextureFromHitPoint(cubeSide: face, hitResult: hitResult) else {
            print("Error smth went wrong")
            return
        }
        let imageSize = image.size
        
        // Normalize hit coordinates to the range [0, 1] for texture mapping.
        let normalizedHitPoint = normalizeHitPoint(localHit: localHitPoint, hitedBox: box)

        let preparedPixels = preparePixels(sideTapped: face, normalizedHit: normalizedHitPoint, imgSizes: imageSize)
        
        guard let newTexture = editorAddonModel.editSideByPixel(sideTapped: face, sideTexture: image, textureX: preparedPixels[0], textureY: preparedPixels[1]) else {

            print(#function)
            print("smth went wrong With editing")
            return
        }
        
        hitResult.node.geometry?.materials[face.rawValue].diffuse.contents = newTexture
        
    }

    private func preparePixels(sideTapped: CubeSideName, normalizedHit: SCNVector3, imgSizes: CGSize) -> [Int] {
        // Convert normalized texture coordinates to pixel coordinates.
        let hitPixelX = Int(normalizedHit.x * Float(imgSizes.width))
        let hitPixelY = Int(normalizedHit.y * Float(imgSizes.height))
        let hitPixelAsHeightZ = Int(normalizedHit.z * Float(imgSizes.height))
        let hitPixelAsWidthZ = Int(normalizedHit.z * Float(imgSizes.width))
        
        var preparedCoordinates = [Int]()
        
        var preparedX = 0
        var preparedY = 0
        
        switch sideTapped {
            
        case .front:
            preparedX = hitPixelX
            preparedY = hitPixelY
        case .left:
            preparedX = hitPixelAsWidthZ
            preparedY = hitPixelY
        case .back:
            preparedX = Int(imgSizes.width - 1) - hitPixelX
            preparedY = hitPixelY
        case .right:
            preparedX = Int(imgSizes.width - 1) - hitPixelAsWidthZ
            preparedY = hitPixelY
        case .top:
            preparedX = hitPixelX
            preparedY = Int(imgSizes.height - 1) - hitPixelAsHeightZ
        case .bottom:
            preparedX = hitPixelX
            preparedY = hitPixelAsHeightZ
        }
        
        preparedCoordinates = [preparedX, preparedY]
        
        print(" preparedCoordinates \n xy: \(preparedCoordinates), sideTapped: \(sideTapped)")
        
        return preparedCoordinates
    }
    
    //MARK: Texture of Touched Box
    
    func getTouchedFace(hitResult: SCNHitTestResult, box: SCNBox) -> CubeSideName {
        // Get texture coordinate and convert to pixel
        let localHitPoint = hitResult.localCoordinates
        // Define the size of the box.
        let width = Float(box.width)
        let height = Float(box.height)
        let length = Float(box.length)
        
        // Define a small epsilon because of precision issues.
        let epsilon: Float = 0.00001
        
        // Determine which face of the cube was tapped.
        var face: CubeSideName
        
        if abs(localHitPoint.x - width / 2) < epsilon {
            face = .right
        } else if abs(localHitPoint.x + width / 2) < epsilon {
            face = .left
        } else if abs(localHitPoint.y - height / 2) < epsilon {
            face = .top
        } else if abs(localHitPoint.y + height / 2) < epsilon {
            face = .bottom
        } else if abs(localHitPoint.z - length / 2) < epsilon {
            face = .front
        } else {
            face = .back
        }
        
        return face
    }
    
    func getTextureFromHitPoint(cubeSide: CubeSideName, hitResult: SCNHitTestResult) -> UIImage? {

        // Fetch the material of the tapped face.
        guard let hitMaterial = hitResult.node.geometry?.materials[cubeSide.rawValue],
              let image = hitMaterial.diffuse.contents as? UIImage else {
            return nil
        }

        return image
    }
    
    //MARK: Color from Texture
    
    func getColorFromHitPoint(hitResult: SCNHitTestResult, box: SCNBox) -> UIColor? {
        // Determine which face of the cube was tapped.
        let face = getTouchedFace(hitResult: hitResult, box: box)
        guard let image = getTextureFromHitPoint(cubeSide: face, hitResult: hitResult) else {
            print("Error: Could not get the texture from the hit point.")
            return nil
        }
        
        let imageSize = image.size
        let localHitPoint = hitResult.localCoordinates
        
        // Normalize hit coordinates to the range [0, 1] for texture mapping.
        
        let normalizedHitPoint = normalizeHitPoint(localHit: localHitPoint, hitedBox: box)
        
        let preparedPixels = preparePixels(sideTapped: face, normalizedHit: normalizedHitPoint, imgSizes: imageSize)
        
        let color = getColorFromImage(image: image, x: preparedPixels[0], y: preparedPixels[1])
        
        return color
    }
    
    /// Normalize hit coordinates to the range [0, 1] for texture mapping.
    private func normalizeHitPoint(localHit: SCNVector3, hitedBox: SCNBox) -> SCNVector3 {
        
        let width = Float(hitedBox.width)
        let height = Float(hitedBox.height)
        let length = Float(hitedBox.length)
        
        let normalizedX: Float = (width != 0) ? (localHit.x / width) + 0.5 : 0.5
        let normalizedY: Float = (height != 0) ? (localHit.y / height) + 0.5 : 0.5
        let normalizedZ: Float = (length != 0) ? (localHit.z / length) + 0.5 : 0.5
        
        let normalizedHitPoint = SCNVector3(
            normalizedX,
            normalizedY,
            normalizedZ
        )

        return normalizedHitPoint
    }

    func getColorFromImage(image: UIImage, x: Int, y: Int) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }
        
        let convertedY = (cgImage.height - 1) - y
        
        let width = cgImage.width
        if x < 0 || x >= width { return nil }
        
        let height = cgImage.height
        if convertedY < 0 || convertedY >= height { return nil }
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let totalBytes = height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData: [UInt8] = [UInt8](repeating: 0, count: totalBytes)
        guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let byteIndex = (bytesPerRow * convertedY) + x * 4
        let red = CGFloat(rawData[byteIndex]) / 255.0
        let green = CGFloat(rawData[byteIndex + 1]) / 255.0
        let blue = CGFloat(rawData[byteIndex + 2]) / 255.0
        let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0
        
        let resultColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return resultColor
    }

}

//MARK: ThumbNailScene Methods

extension AddonEditor3DVCModel {
    
    func showHideNode(touchedNode: SCNNode) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self,
                  let nodeName = touchedNode.name,
                  let bigNode = self.scnModel?.rootNode.childNode(withName: nodeName, recursively: true) else {
                    print("error to create CubeNode in undo")
                    return
                }
            
            bigNode.isHidden.toggle()
            
            if bigNode.isHidden == true {
                touchedNode.geometry?.materials.first?.diffuse.contents = self.smallScnModel?.addonModel?.hideCubesColor
                
            } else {
                touchedNode.geometry?.materials.first?.diffuse.contents = self.smallScnModel?.addonModel?.showCubesColor
            }
            
        }

    }
}


extension AddonEditor3DVCModel {
    func saveTextureToLibrary() {
        guard let assemblyDiagram = scnModel?.constructImage() else {
            print("somthing is wrong with your texture")
            return
        }
        
        requestAuthorizationAndSaveImageToLibrary(image: assemblyDiagram)
    }
    
    private func saveImageToPhotoLibrary(image: UIImage) {
        guard let _ = image.pngData() else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { [weak self] success, error in
            if !success {
                AppDelegate.log("Error saving image: \(String(describing: error))")
            } else {
                AppDelegate.log("Image saved successfully!")
                self?.presenAlert(with: "Image saved successfully!", and: nil)
            }
        })
    }
    
    func requestAuthorizationAndSaveImageToLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            switch status {
            case .authorized:
                self?.saveImageToPhotoLibrary(image: image)
            case .denied, .restricted:
                self?.showPermissionAlert()
            case .notDetermined:
                // Request not handled. Probably, the user hasn't made a choice yet.
                break
            case .limited:
                // The user has granted limited access to the photo library.
                self?.saveImageToPhotoLibrary(image: image)
            @unknown default:
                fatalError("Unknown status of PHPhotoLibrary.authorizationStatus()")
            }
        }
    }
    
    func showPermissionAlert() {
        let alertController = UIAlertController(title: "Photo Library Access Denied",
                                                message: "Please allow access to your photo library to save images.",
                                                preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    AppDelegate.log("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.controller.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private func presenAlert(with titleInfo: String, and massageInfo: String?) {
        let alertController = UIAlertController(title: titleInfo, message: massageInfo, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.controller.present(alertController, animated: true, completion: nil)
        }
    }
}
