//
//  SkinEditorCollectionViewCell.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class SkinEditorCollectionViewCell: UICollectionViewCell {
    
    var onDownloadButtonTapped: ((UIButton) -> Void)?
    var onDeleteButtonTapped: (() -> Void)?
    
    @IBOutlet weak var nameSkinLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var bodyImage: UIImageView!
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelContainer.layer.borderColor = UIColor(.black).cgColor
        labelContainer.layer.borderWidth = 1
        labelContainer.roundCorners(20)
        imageContainer.layer.borderColor = UIColor(.black).cgColor
        imageContainer.layer.borderWidth = 1
        imageContainer.roundCorners(20)
        backgroundContainerView.roundCorners(.allCorners, radius: 27)
        backgroundContainerView.layer.borderWidth = 1
        backgroundContainerView.layer.borderColor = UIColor(.black).cgColor
        backgroundColor = .clear
    }
    
    @IBAction func onDownloadButtonTapped(_ sender: UIButton) {
        onDownloadButtonTapped?(downloadButton)
    }
    
    @IBAction func onDeleteButtonTapped(_ sender: UIButton) {
        onDeleteButtonTapped?()
    }
    
    public func plusMode() {
        downloadButton.isHidden = true
        deleteButton.isHidden = true
        bodyImage.image = UIImage(named: "add skin")
        nameSkinLabel.text = ""
    }
    
    public func publicMode(skinInfo: AnatomyCreatedModel) {
        bodyImage.image = skinInfo.preview
        downloadButton.isHidden = false
        deleteButton.isHidden = false
        nameSkinLabel.text = skinInfo.name
    }
}
