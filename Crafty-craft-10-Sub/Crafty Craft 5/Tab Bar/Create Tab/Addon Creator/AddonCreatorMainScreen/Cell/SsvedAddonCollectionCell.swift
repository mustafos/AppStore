//
//  SsvedAddonCollectionCell.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
    return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
        let value = $1.reduce(0, +)
        return ($1.count == k && value <= t && value > $0) ? value : $0
    }
}

import UIKit

class SsvedAddonCollectionCell: UICollectionViewCell {
    
    enum CellState {
        case plusMode
        case savedAddonMOde
    }
    
    var cellMode: CellState = .savedAddonMOde

    var onDownloadButtonTapped: ((UIButton) -> Void)?
    
    var onDeleteButtonTapped: (() -> Void)?

    @IBOutlet weak var addonTitleLab: UILabel!
    
    @IBOutlet weak var addonPreview: CustomImageLoader!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    
    @IBOutlet weak var labelContainer: UIView!
    
    @IBOutlet weak var imageContainer: UIView!
    
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        onDeleteButtonTapped?()
    }
    
    @IBAction func downLoadBtnTapped(_ sender: UIButton) {
        onDownloadButtonTapped?(downloadBtn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelContainer.layer.borderColor = UIColor(.black).cgColor
        labelContainer.layer.borderWidth = 1
        labelContainer.roundCorners(20)
        imageContainer.layer.borderColor = UIColor(.black).cgColor
        imageContainer.layer.borderWidth = 1
        imageContainer.roundCorners(20)
        roundCorners(.allCorners, radius: 27)
        layer.borderWidth = 1
        layer.borderColor = UIColor(.black).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        addonPreview.image = nil
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
         
         if cellMode == .plusMode {
             // Update the image view frame and appearance in .plusMode
             addonPreview.image = UIImage(named: "add skin")
         }
     }
    
    private func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }
    
    func configCell(savedAddon: SavedAddonEnch?, with mode: CellState) {

        self.cellMode = mode
        
        switch cellMode {

        case .plusMode:
            addonPreview.image = UIImage(named: "add skin")
            deleteBtn.isHidden = true
            downloadBtn.isHidden = true
            addonTitleLab.text = ""
        case .savedAddonMOde:
            deleteBtn.isHidden = false
            downloadBtn.isHidden = false
            addonTitleLab.text = savedAddon?.displayName

            guard let localSavedAddon = savedAddon else { return }

            if let imageData = savedAddon?.displayImageData, let image = UIImage(data: imageData) {
                addonPreview.image = image
            } else if let image = ImageCacheManager.shared.image(forKey: localSavedAddon.idshka) {
                addonPreview.image = image
            } else {
                DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: localSavedAddon.displayImage) { [weak self] theUrl in
                    guard theUrl != nil else { return }
                    self?.addonPreview.loadImage(from: theUrl!, id: localSavedAddon.idshka) { img in
                        savedAddon?.displayImageData = img?.pngData()
                    }
                }
            }
        }
    }
}
