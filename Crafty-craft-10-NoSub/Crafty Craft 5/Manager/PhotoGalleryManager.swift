//
//  PhotoGalleryManager.swift
//  Crafty Craft 5
//
//  Created by dev on 20.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit
import Photos

protocol PhotoGalleryManagerProtocol {
    typealias GetImageCompletion = (UIImage) -> ()
    
    func getImageFromPhotoLibrary(from viewController: UIViewController, completion: @escaping GetImageCompletion)
    
    func getImageFromCamera(from viewController: UIViewController, completion: @escaping GetImageCompletion)
    
    func saveImageToPhotoLibrary(image: UIImage, from viewController: UIViewController)
}

class PhotoGalleryManager: NSObject, PhotoGalleryManagerProtocol {
    
    private var getImageCompletion: GetImageCompletion?
    
    func getImageFromPhotoLibrary(from viewController: UIViewController, completion: @escaping GetImageCompletion) {
        
        self.getImageCompletion = completion
        
        requestAuthorizationAndSaveImageToLibrary(from: viewController) { [weak self] granted, vc in
            DispatchQueue.main.async {
                
                guard let me = self else {
                    assert(false, "wrong construction")
                    return
                }
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = me
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                
                vc?.present(imagePicker, animated: true)
            }
        }
    }
    
    func getImageFromCamera(from viewController: UIViewController, completion: @escaping GetImageCompletion) {
        
        self.getImageCompletion = completion
        
        proceedWithCameraAccess(from: viewController) { [weak self] granted, vc in
            DispatchQueue.main.async {
                
                guard let me = self else {
                    assert(false, "wrong construction")
                    return
                }
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = me
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                
                vc?.present(imagePicker, animated: true)
            }
        }
    }
    
    func saveImageToPhotoLibrary(image: UIImage, from viewController: UIViewController) {
        guard let pngData = image.pngData() else {
            return
        }
        
        requestAuthorizationAndSaveImageToLibrary(from: viewController) { [weak self] granted, vc in
            if granted {
                DispatchQueue.main.async {
                    PHPhotoLibrary.shared().performChanges({ () -> Void in
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        let options = PHAssetResourceCreationOptions()
                        
                        creationRequest.addResource(with: PHAssetResourceType.photo, data: pngData, options: options)
                    }, completionHandler: { (success, error) -> Void in
                        if !success {
                            AppDelegate.log("Error saving image: \(String(describing: error))")
                        } else {
                            AppDelegate.log("Skin saved successfully!")
                            self?.presentAlert(with: "Skin saved successfully!", and: nil, in: vc)
                        }
                    })
                }
            }
        }
    }
    
    private func requestAuthorizationAndSaveImageToLibrary(from viewController: UIViewController, completion: @escaping (Bool, UIViewController?) -> ()) {
        PHPhotoLibrary.requestAuthorization { [weak self, viewController] (status) in
            switch status {
            case .authorized:
                completion(true, viewController)
            case .denied, .restricted:
                self?.showPermissionAlert(in: viewController)
                completion(false, viewController)
            case .notDetermined:
                // Request not handled. Probably, the user hasn't made a choice yet.
                completion(false, viewController)
            case .limited:
                completion(true, viewController)
            @unknown default:
                fatalError("Unknown status of PHPhotoLibrary.authorizationStatus()")
            }
        }
    }
    

    func proceedWithCameraAccess(from viewController: UIViewController, completion: @escaping (Bool, UIViewController?) -> ()) {
        // Check if the device supports a camera
        guard AVCaptureDevice.authorizationStatus(for: .video) != .authorized else {
            completion(true, viewController)
            return
        }

        AVCaptureDevice.requestAccess(for: .video) { success in
            DispatchQueue.main.async {
                if success { // If request is granted (success is true)
                    completion(true, viewController)
                } else { // If request is denied (success is false)
                    // Create Alert
                    let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)

                    // Add "OK" Button to alert, pressing it will bring you to the settings app
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(settingsURL) {
                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                        alert.dismiss(animated: true)
                    }))
                    // Show the alert with animation
                    viewController.present(alert, animated: true)
                }
            }
        }
    }

    
    private func showPermissionAlert(in viewController: UIViewController) {
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
        
        DispatchQueue.main.async { [weak viewController] in
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func presentAlert(with titleInfo: String, and massageInfo: String?, in viewController: UIViewController?) {
        let alertController = UIAlertController(title: titleInfo, message: massageInfo, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak viewController] in
            viewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PhotoGalleryManager: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                self?.getImageCompletion?(image)
            }
        }
    }
}
