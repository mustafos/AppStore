//
//  DownloadContnetViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 28.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class DownloadContnetViewController: UIViewController {
    var shareAddonAction: (() -> Void)?
    var manualInstallAssonAction: ((URL) -> Void)?
    var manualIntallAction: (() -> Void)?
    
    @IBOutlet weak var manualInstallAddonView: UIView!
    @IBOutlet weak var installAddonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateInstallViews()
    }
    
    private func configurateInstallViews() {
        self.view.roundCorners(32)
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func installAddonAction(_ sender: Any) {
        self.dismiss(animated: true)
        shareAddonAction?()
    }
    
    @IBAction func manualAddonAction(_ sender: Any) {
        self.dismiss(animated: true)
        manualIntallAction?()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
