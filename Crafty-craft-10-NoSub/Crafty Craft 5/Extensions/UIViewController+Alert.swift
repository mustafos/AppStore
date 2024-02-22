//
//  UIViewController+Alert.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 26.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showNoInternetMess() {
        showAlert(title: NSLocalizedString("connectivityIssue", comment: ""), message: NSLocalizedString("connectivityAlert", comment: ""))
    }
    
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        })
        present(alert, animated: true)
    }
}

