//
//  ManualInstructionViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 01.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class ManualInstructionViewController: UIViewController {
    var onGrantAccessAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.roundCorners(32)
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func grantAccessTapped(_ sender: Any) {
        dismiss(animated: true)
        onGrantAccessAction?()
    }
    
    @IBAction func cancellTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
