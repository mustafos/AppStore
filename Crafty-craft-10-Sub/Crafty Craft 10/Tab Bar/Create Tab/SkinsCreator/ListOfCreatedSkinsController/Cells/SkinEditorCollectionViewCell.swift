import UIKit


class SkinEditorCollectionViewCell: UICollectionViewCell {
    
    var onDownloadButtonTapped: ((UIButton) -> Void)?
    var onDeleteButtonTapped: (() -> Void)?
    
    @IBOutlet weak var nameSkinLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var bodyImage: UIImageView!
    @IBOutlet weak var backgroundContainerView: UIView!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundContainerView.roundCorners(12)
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
    
    public func publicMode(skinInfo: SkinCreatedModel) {
        bodyImage.image = skinInfo.preview
        downloadButton.isHidden = false
        deleteButton.isHidden = false
        nameSkinLabel.text = skinInfo.name
    }
}
