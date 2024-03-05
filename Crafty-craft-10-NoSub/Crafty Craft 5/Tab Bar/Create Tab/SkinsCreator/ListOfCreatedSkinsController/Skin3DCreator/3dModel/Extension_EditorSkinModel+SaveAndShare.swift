

import Photos
import Foundation
import UIKit

extension EditorSkinModel {
    
    func saveAssemblyDiagram() {
        if assemblyDiagramSize == .size64x64 {
            if let skinAssemblyDiagram = skinCreatedModel?.skinAssemblyDiagram {
                requestAuthorizationAndSaveImageToLibrary(image: skinAssemblyDiagram)
            }
        } else {
            if let skinAssemblyDiagram128 = skinCreatedModel?.skinAssemblyDiagram128 {
                requestAuthorizationAndSaveImageToLibrary(image: skinAssemblyDiagram128)
            }
        }
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
