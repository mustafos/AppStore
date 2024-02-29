import UIKit

class ListTableViewCell: UITableViewCell {
    
    static let rowInsetHeight: CGFloat = 20
    static let backgroundCellHeight: CGFloat = 78
    static let defaultCellHeiht: CGFloat = backgroundCellHeight + rowInsetHeight
    
    @IBOutlet weak var backgroundViewContainer: UIView!
    @IBOutlet weak var cellImage: CustomImageLoader!
    @IBOutlet weak var nameLabel: UILabel!
    
    private lazy var loader = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.tintColor = .black
        return activityView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundViewContainer.roundCorners(Self.backgroundCellHeight/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        removeLoader()
    }
    
    func config(addonModel: AddonForDisplay) {
        
        self.nameLabel.text = addonModel.displayName
        
//        if let imageData = addonModel.displayImageData, let image = UIImage(data: imageData) {
//            cellImage.image = image
//        } else {
//            addLoader()
            DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: addonModel.displayImage) { [weak self] imgPAth in
                if let imgPath = imgPAth {
                    self?.cellImage.loadImage(from: imgPath, id: addonModel.idshka) { [weak self] img in
                        self?.removeLoader()
                        if addonModel.displayImageData == nil {
                            addonModel.displayImageData = img?.pngData()
                        }
                    }
                }
//            }
        }
    }
    
    func configCategory(category: AddonCategory) {
        self.nameLabel.text = category.categoryName
//        if let imageData = category.displayImageData, let image = UIImage(data: imageData) {
//            cellImage.image = image
//        } else {
//            addLoader()
            DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: category.imagePathName) { [weak self] imgPAth in
                if let imgPath = imgPAth {
                    self?.cellImage.loadImage(from: imgPath, id: category.imagePathName) { [weak self] img in
                        self?.removeLoader()
                        if category.displayImageData == nil {
                            category.displayImageData = img?.pngData()
                        }
                    }
                }
//            }
        }
    }
    
    private func addLoader() {
        loader.color = .black
        cellImage.addSubview(loader)
        bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: cellImage.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: cellImage.centerXAnchor).isActive = true
        loader.startAnimating()
    }
    
    private func removeLoader() {
        loader.removeFromSuperview()
    }
}
