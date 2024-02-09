import Foundation
import UIKit

class SliderCellView: UIView {
    
    private var fontName: String = Configurations.getSubFontName()
    private var textColot: UIColor = UIColor.white
    
    lazy var titleLabel: UILabel = {
       var label = UILabel()
        label.font = UIFont(name: fontName, size: 12)
        label.textColor = textColot
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            label.textAlignment = .right
        } else {
            label.textAlignment = .left
        }
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
       var label = UILabel()
        label.font = UIFont(name: fontName, size: 12)
        label.textColor = textColot
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            label.textAlignment = .right
        } else {
            label.textAlignment = .left
        }
        return label
    }()
    
    lazy var starIcon: UIImageView = {
       var image = UIImageView()
        image.image = UIImage(named: "star")
        image.transform = CGAffineTransform(scaleX: 0.55, y: 0.55)
        return image
    }()
    
    lazy var stackView: UIStackView = {
       var stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    convenience init(title: String, subTitle: String) {
        self.init()
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func configureView() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        addSubview(starIcon)
    }
    
    func makeConstraints() {
        starIcon.snp.remakeConstraints { make in
//            make.height.equalTo(50)
            make.width.equalTo(starIcon.snp.height)
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        stackView.snp.remakeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.equalTo(starIcon.snp_trailingMargin).offset(10)
        }
    }
}
