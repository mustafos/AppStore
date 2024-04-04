//
//  UIViewController+Alert.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

extension UIViewController {
    func showNoInternetMess() {
        showAlert(title: title, message: NSLocalizedString("ConnectivityDescription", comment: ""))
    }
    
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        })
        present(alert, animated: true)
    }
}

