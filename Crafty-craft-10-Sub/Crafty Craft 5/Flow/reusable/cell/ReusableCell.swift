//  Created by Melnykov Valerii on 14.07.2023
//


import UIKit

class ReusableCell: UICollectionViewCell {
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    func setupCell() {
        cellLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        cellLabel.font = UIFont(name: Configurations.getSubFontName(), size: 10)
        contentContainer.layer.cornerRadius = 8
        titleContainer.layer.cornerRadius = 8
        cellLabel.setShadow(with: 0.5)
        cellImage.layer.cornerRadius = 8
//        cellImage.layer.borderColor = UIColor.black.cgColor
//        cellImage.layer.borderWidth = 2
    }
}
