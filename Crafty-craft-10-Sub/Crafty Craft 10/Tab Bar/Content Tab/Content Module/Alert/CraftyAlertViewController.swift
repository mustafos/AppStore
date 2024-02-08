//
//  CraftyAlertViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 01.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

struct CraftyAlertModel {
    let title: String?
    let subTitle: String?
    let buttonTitle: String
}

class CraftyAlertViewController: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    private var configModel: CraftyAlertModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let configModel {
            titleLbl.text = configModel.title
            subTitleLbl.text = configModel.subTitle
            mainButton.setTitle(configModel.buttonTitle, for: .normal)
        }
        
        self.view.layer.cornerRadius = 12
        self.view.layer.masksToBounds = true
    }

    @IBAction func buttonDidTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func config(model: CraftyAlertModel) {
        self.configModel = model
    }
}
