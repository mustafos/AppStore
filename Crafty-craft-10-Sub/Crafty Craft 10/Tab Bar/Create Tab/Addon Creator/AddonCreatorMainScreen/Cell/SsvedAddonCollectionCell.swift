

import UIKit

class SsvedAddonCollectionCell: UICollectionViewCell {
    
    enum CellMode {
        case plusMode
        case savedAddonMOde
    }
    
    var cellMode: CellMode = .savedAddonMOde

    var onDownloadButtonTapped: ((UIButton) -> Void)?
    
    var onDeleteButtonTapped: (() -> Void)?

    @IBOutlet weak var addonTitleLab: UILabel!
    
    @IBOutlet weak var addonPreview: CustomImageLoader!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        onDeleteButtonTapped?()
    }
    
    @IBAction func downLoadBtnTapped(_ sender: UIButton) {
        onDownloadButtonTapped?(downloadBtn)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
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
    
    func configCell(savedAddon: SavedAddon?, with mode: CellMode) {

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
