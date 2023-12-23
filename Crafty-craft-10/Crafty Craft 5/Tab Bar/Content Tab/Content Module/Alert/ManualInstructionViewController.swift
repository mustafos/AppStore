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
        self.view.layer.cornerRadius = 12
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
