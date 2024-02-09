//
//  UIViewController+ActivityView.swift
//  Crafty Craft 5
//
//  Created by dev on 03.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func share(url: URL, from: UIView? = nil, direction: UIPopoverArrowDirection = .any) {
        let fileManager = FileManager.default
        
        let name = url.lastPathComponent
        let tempUrl = fileManager.cachesDirectory.appendingPathComponent(name)
        let centerView: some UIView = from ?? view
        
        if fileManager.secureSafeCopyItem(at: url, to: tempUrl) {
            _share(shareItems: [tempUrl], from: centerView, direction: direction)
        }
    }
    
    func share(image: UIImage, from: UIView? = nil, direction: UIPopoverArrowDirection = .any) {
        let fileManager = FileManager.default
        
        let tempUrl = fileManager.cachesDirectory.appendingPathComponent("image.png")
        let centerView: some UIView = from ?? view
        
        if image.save(to: tempUrl) {
            _share(shareItems: [tempUrl], from: centerView, direction: direction)
        }
    }
    
    func share(string: String, from: UIView? = nil, direction: UIPopoverArrowDirection = .any) {
        let centerView: UIView = from ?? view
        _share(shareItems: [string], from: centerView, direction: direction)
    }
    
    private func _share(shareItems: [Any], from: UIView, direction: UIPopoverArrowDirection) {
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        var dimmingView: UIView?

        // Check if the device is an iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Create a black view for dimming effect
            dimmingView = UIView(frame: self.view.bounds)
            dimmingView!.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            dimmingView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(dimmingView!)
            
            // Configure popover presentation for iPad
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = from
                popoverController.permittedArrowDirections = direction
                popoverController.sourceRect = from.bounds
            }
        }

        // Present the activity view controller
        self.present(activityViewController, animated: true) {
            if dimmingView != nil {
                // Bring the dimming view to the front if it exists
                self.view.bringSubviewToFront(dimmingView!)
            }
        }

        // Remove the dimming view when the activity view controller is dismissed
        activityViewController.completionWithItemsHandler = { (_, _, _, _) in
            UIView.animate(withDuration: 0.3, animations: {
                dimmingView?.alpha = 0
            }) { _ in
                dimmingView?.removeFromSuperview()
            }

        }
    }

}

