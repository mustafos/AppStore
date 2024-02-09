//  Created by Melnykov Valerii on 14.07.2023
//


import UIKit

enum configView {
    case first,second,transaction
}

protocol ReusableViewEvent : AnyObject {
    func nextStep(config: configView)
}

struct ReusableViewModel {
    var title : String
    var items : [ReusableContentCell]
}

struct ReusableContentCell {
    var title : String
    var image : UIImage
    var selectedImage: UIImage
}

class ReusableView: UIView, AnimatedButtonEvent {
    func onClick() {
        self.protocolElement?.nextStep(config: self.configView)
    }
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var titleLb: UILabel!
    @IBOutlet private weak var content: UICollectionView!
    @IBOutlet private weak var nextStepBtn: AnimatedButton!
    @IBOutlet private weak var titleWight: NSLayoutConstraint!
    @IBOutlet private weak var buttonBottom: NSLayoutConstraint!
    
    weak var protocolElement : ReusableViewEvent?
    
    public var configView : configView = .first
    public var viewModel : ReusableViewModel? = nil
    private let cellName = "ReusableCell"
    private var selectedStorage : [Int] = []
    private let multic: CGFloat = 0.94
    private let xib = "ReusableView"
    
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Init()
    }
    
    private func Init() {
        Bundle.main.loadNibNamed(xib, owner: self, options: nil)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Устройство является iPhone
            if UIScreen.main.nativeBounds.height >= 2436 {
                // Устройство без физической кнопки "Home" (например, iPhone X и новее)
            } else {
                // Устройство с физической кнопкой "Home"
                buttonBottom.constant = 47
            }
        } else {
            buttonBottom.constant = 63
        }

        contentView.fixInView(self)
        nextStepBtn.delegate = self
        nextStepBtn.style = .native
        contentView.backgroundColor = .clear
        setContent()
        setConfigLabels_TOC()
        configScreen_TOC()
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            let layout = RTLSupportedCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            content.collectionViewLayout = layout
        }
    }
    
    private func setContent(){
        content.dataSource = self
        content.delegate = self
        content.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        content.backgroundColor = .clear
//        UIView.appearance().semanticContentAttribute = .forceLeftToRight
    }
    
    private func setConfigLabels_TOC(){
        titleLb.setShadow()
        
        titleLb.textColor = .white
        titleLb.font = UIFont(name: Configurations.getSubFontName(), size: 24)
//        titleLb.lineBreakMode = .byWordWrapping
        titleLb.adjustsFontSizeToFitWidth = true
    }
    
    public func setConfigView(config: configView) {
        self.configView = config
    }
    
    private func setLocalizable(){
        self.titleLb.text = viewModel?.title
    }
    
    //MARK: screen configs
    
    private func configScreen_TOC(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            titleWight.setValue(0.35, forKey: "multiplier")
        } else {
            titleWight.setValue(0.7, forKey: "multiplier")
        }
    }
    
    private func getLastElement() -> Int {
        return (viewModel?.items.count ?? 0) - 1
    }
}

extension ReusableView : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setLocalizable()
        return viewModel?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = content.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! ReusableCell
        let content = viewModel?.items[indexPath.item]
        cell.cellLabel.text = content?.title.uppercased()
        if selectedStorage.contains(where: {$0 == indexPath.item}) {
            cell.cellLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            cell.cellImage.image = content?.selectedImage
            cell.contentContainer.backgroundColor = #colorLiteral(red: 0.7372549176, green: 0.7372549176, blue: 0.7372549176, alpha: 1)
            cell.cellLabel.font = UIFont(name: Configurations.getSubFontName(), size: 12)
            cell.cellLabel.setShadow(with: 0.25)
        } else {
            cell.cellLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            cell.cellImage.image = content?.image
            cell.contentContainer.backgroundColor = #colorLiteral(red: 0.4941176471, green: 0.4941176471, blue: 0.4941176471, alpha: 1)
            cell.cellLabel.font = UIFont(name: Configurations.getSubFontName(), size: 10)
            cell.cellLabel.setShadow(with: 0.5)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedStorage.contains(where: {$0 == indexPath.item}) {
            selectedStorage.removeAll(where: {$0 == indexPath.item})
        } else {
            selectedStorage.append(indexPath.row)
        }
        
       
        UIApplication.shared.impactFeedbackGenerator(type: .light)
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil, completion: nil)
        if indexPath.last == getLastElement() {
            collectionView.scrollToLastItem(animated: false)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return selectedStorage.contains(indexPath.row) ? CGSize(width: collectionView.frame.height * 0.8, height: collectionView.frame.height) : CGSize(width: collectionView.frame.height * 0.7, height: collectionView.frame.height * 0.85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    
}

class RTLSupportedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}
