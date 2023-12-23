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
        installAddonView.layer.cornerRadius = 34
        installAddonView.layer.masksToBounds = true
        let installAddonTap = UITapGestureRecognizer(target: self, action: #selector(self.installAddonAction(_:)))
        installAddonView.addGestureRecognizer(installAddonTap)
        
        manualInstallAddonView.layer.cornerRadius = 34
        manualInstallAddonView.layer.masksToBounds = true
        let manualInstallAddonTap = UITapGestureRecognizer(target: self, action: #selector(self.manualAddonAction(_:)))
        manualInstallAddonView.addGestureRecognizer(manualInstallAddonTap)
    }

    @objc func manualAddonAction(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
        manualIntallAction?()
    }
    
    @objc func installAddonAction(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true)
        shareAddonAction?()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
