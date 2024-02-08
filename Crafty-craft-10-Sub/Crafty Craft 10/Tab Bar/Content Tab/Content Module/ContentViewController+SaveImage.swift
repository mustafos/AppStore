//
//  ContentViewController+SaveImage.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 31.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import Photos
import UIKit

extension ContentViewController {
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
    
    private func showPermissionAlert() {
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
            self?.present(alertController, animated: true, completion: nil)
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
                self?.presenAlert(with: "Success", and: "Skin is saved in your Photo Gallery. To use it, go to Minecraft >> Dressing Room >> EDIT CHARACTER >> OWNED >> tap Import >> CHOOSE NEW SKIN >> this will take you to your camera roll >> select the skin >> you are all to explore your custom skin")
            }
        })
    }
    
    private func presenAlert(with titleInfo: String, and massageInfo: String?) {
        let alertController = UIAlertController(title: titleInfo, message: massageInfo, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
