//
//  UIViewController+Keyboard.swift
//  Crafty Craft 5
//
//  Created by dev on 19.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

public protocol KeyboardStateProtocol: AnyObject {

    func keyboardShows(height: CGFloat)

    func keyboardHides()
}

public extension UIViewController {
    // MARK: Public
    
    /**
     Register for `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.

     - parameter keyboardStateDelegate: Keyboard state delegate

     :discussion: It is recommended to call this method in `viewWillAppear:`
     */
    func registerForKeyboardNotifications() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self,
                                  selector: #selector(UIViewController._keyboardWillShow(_:)),
                                  name: UIResponder.keyboardWillShowNotification,
                                  object: nil)
        defaultCenter.addObserver(self,
                                  selector: #selector(UIViewController._keyboardWillHide(_:)),
                                  name: UIResponder.keyboardWillHideNotification,
                                  object: nil)
    }

    /**
     Unregister from `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.

     :discussion: It is recommended to call this method in `viewWillDisappear:`
     */
    func unregisterFromKeyboardNotifications() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        defaultCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Private

    /// Handler for `UIKeyboardWillShowNotification`
    @objc fileprivate dynamic func _keyboardWillShow(_ n: Notification) {
        guard let userInfo = n.userInfo,
            let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let convertedRect = view.convert(rect, from: nil)
        let height = convertedRect.height
        
        if let vc = self as? KeyboardStateProtocol {
            vc.keyboardShows(height: height)
        }
    }

    /// Handler for `UIKeyboardWillHideNotification`
    @objc fileprivate dynamic func _keyboardWillHide(_ n: Notification) {
        if let vc = self as? KeyboardStateProtocol {
            vc.keyboardHides()
        }
    }
}
