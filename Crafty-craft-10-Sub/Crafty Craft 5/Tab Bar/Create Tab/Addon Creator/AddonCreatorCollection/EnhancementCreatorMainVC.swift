//
//  EnhancementCreatorMainVC.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class EnhancementCreatorMainVC: UIViewController {
    var model = EdditionalAddonModel()
    
    @IBOutlet weak var unlockActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet private weak var tabsStackView: UIStackView!
    @IBOutlet weak var addonCollectionView: UICollectionView!
    @IBOutlet weak var selectItemView: UIView!
    @IBOutlet weak var selectedText: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    private var selectedButton: UIButton!
    @IBOutlet private weak var layouTabButton: UIButton!
    @IBOutlet private weak var groupTabButton: UIButton!
    @IBOutlet private weak var recentTabButton: UIButton!
    
    private var suggestionsTableView: UITableView?
    private var footerCell: UIView?
    private var isHideButtons: Bool = true
    internal weak var downloadButton: UIButton?
    
    private enum TabsPageController: Int {
        case layout = 0
        case group = 1
        case recent = 2
    }
    private var filterText: String?
    
    // MARK: - State
    private var _tabsPageControllMode: TabsPageController = .layout
    private var tabsPageControllMode: TabsPageController {
        set {
            guard _tabsPageControllMode != newValue else {
                return
            }
            
            _tabsPageControllMode = newValue
            
            updatePageControllerUI()
        }
        get {
            _tabsPageControllMode
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                dismissKeyboardOnTapOutside()
        setupCollectionView()
        addFooterView()
        configureUIComponents()
        refreshCollectionViewUI()
        updatePageControllerUI()
        unlockActivityIndicator.isHidden = true
        
        IAPManager.shared.addonProductDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSubscriptionAvailable {
            model.updateCreatedAddons()
            addonCollectionView.reloadData()
        }
        
        unlockButton.isHidden = isSubscriptionAvailable
        addonCollectionView.isHidden = !isSubscriptionAvailable
        addonCollectionView.isHidden = !isSubscriptionAvailable
        
        checkProduct()
    }

    private var isSubscriptionAvailable: Bool {
        IAPManager.shared.addonCreatorIsValid ?? false
    }
    
    //MARK: - SetUp UI
    
    private func isPrime(_ number: Int) -> Bool {
        if number <= 1 {
            return false
        }
        if number <= 3 {
            return true
        }
        var i = 2
        while i * i <= number {
            if number % i == 0 {
                return false
            }
            i += 1
        }
        return true
    }
    
    internal var cellId: String {
        String(describing: SsvedAddonCollectionCell.self)
    }
    
    private func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }
    
    private func setupCollectionView() {
        unlockButton.roundCorners(36)
        unlockButton.borderColor = .black
        unlockButton.borderWidth = 1
        unlockButton.titleLabel?.textAlignment = .center
        
        let nib = UINib(nibName: cellId, bundle: nil)
        addonCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let nib2 = UINib(nibName: "CreateNewItemCollectionViewCell", bundle: nil)
        addonCollectionView.register(nib2, forCellWithReuseIdentifier: "CreateNewItemCollectionViewCell")
    }
    
    private func addFooterView() {
        footerCell = UIView(frame: CGRect(x: 0, y: 0, width: addonCollectionView.bounds.width, height: 70))
        footerCell?.backgroundColor = UIColor.clear
        addonCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
    }
    
    private func reverseString(_ s: String) -> String {
        return String(s.reversed())
    }
    
    private func configureUIComponents() {
        tabsStackView.roundCorners(24)
        tabsStackView.layer.borderColor = UIColor.black.cgColor
        tabsStackView.layer.borderWidth = 1
        selectImage.image = UIImage(systemName: "chevron.down")
        selectedText.text = layouTabButton.titleLabel?.text
        selectItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayDropdownMenu)))
        tabsPageControllMode = .layout
    }
    
    private func checkProduct() {
        //CheckSkinProduct
        if IAPManager.shared.addonCreatorIsValid == nil {    // nil - if subscription have not loaded in sceneDelegate
            validateSub(for: Configurations.unlockFuncSubscriptionID)
            disableOrEnableCreateAddons(isEnabled: false)
        }
    }
    
    private func disableOrEnableCreateAddons(isEnabled: Bool) {
        if isEnabled == true {
            unlockActivityIndicator.stopAnimating()
        } else {
            unlockActivityIndicator.startAnimating()
        }
        selectItemView.isHidden = false
        tabsStackView.isHidden = false
        unlockActivityIndicator.isHidden = isEnabled
        unlockButton.isEnabled = isEnabled
        unlockButton.isUserInteractionEnabled = isEnabled
    }
    
    //Should never work - validation should be done in scene
    private func validateSub(for productName: String) {
        IAPManager.shared.validateSubscriptions(productIdentifiers: [productName]) { [weak self] results in
            switch productName {
            case Configurations.unlockFuncSubscriptionID:
                if let value = results[Configurations.unlockFuncSubscriptionID] {
                    IAPManager.shared.addonCreatorIsValid = value
                }
                DispatchQueue.main.async { [weak self] in
                    self?.disableOrEnableCreateAddons(isEnabled: true)
                }
            default:
                break
                
            }
        }
    }
    //MARK: - Action
    
    @IBAction func unlockButtonTapped(_ sender: Any) {
        //show subscrition
        let nextVC = PremiumMainController()
        nextVC.productBuy = .unlockFuncProduct
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction private func onRecentButtonTapped(_ sender: UIButton) {
        selectImage.image = UIImage(systemName: "chevron.down")
        tabsPageControllMode = .recent
        model.collectionMode = .recent
    }
    
    @IBAction private func onGroupButtonTapped(_ sender: UIButton) {
        selectImage.image = UIImage(systemName: "chevron.down")
        tabsPageControllMode = .group
        model.collectionMode = .groups
    }
    
    @IBAction private func onLatoutButtonTapped(_ sender: UIButton) {
        selectImage.image = UIImage(systemName: "chevron.down")
        tabsPageControllMode = .layout
        model.collectionMode = .savedAddons
    }
    
    
    //MARK: - Private Methods
    private func updatePageControllerUI() {
        switch tabsPageControllMode {
        case .layout:
            refreshTabUI(selected: layouTabButton, deselected: [groupTabButton, recentTabButton])
        case .group:
            refreshTabUI(selected: groupTabButton, deselected: [layouTabButton, recentTabButton])
        case .recent:
            refreshTabUI(selected: recentTabButton, deselected: [groupTabButton, layouTabButton])
        }
        
        addonCollectionView.reloadData()
    }
    
    private func refreshTabUI(selected: UIButton, deselected: [UIButton]) {
        selectedButton = selected
        selectedButton.isHidden = true
        selectedText.text = selected.titleLabel?.text
        selected.setTitleColor(.white, for: .normal)
        deselected.forEach { button in
            button.isHidden = true
        }
    }
    
    private func refreshCollectionViewUI() {
        addonCollectionView.backgroundColor = .clear
        addonCollectionView.allowsSelection = true
        addonCollectionView.isUserInteractionEnabled = true
    }
    
    @objc private func displayDropdownMenu() {
        for button in [layouTabButton, groupTabButton, recentTabButton] {
            button?.isHidden.toggle()
        }
        selectImage.image = UIImage(systemName: "chevron.up")
        selectedButton?.isHidden = true
    }
}



extension EnhancementCreatorMainVC : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let nextVC = AddonCategoryOptionsViewController()
            navigationController?.pushViewController(nextVC, animated: true)
            
        } else {
            guard let savedAddon = model.getSavedAddon(by: indexPath.item - 1) else { return }
            model.updateRecentForAddon(savedAddon: savedAddon)
            
            let fileManager = FileManager.default
            let file = savedAddon.file
            let fileUrl = fileManager.documentDirectory.appendingPathComponent(savedAddon.file)
            if file.isEmpty == false, fileManager.fileExists(atPath: fileUrl.path) {
                let _ = fileManager.secureSafeCopyItem(at: fileUrl, to: fileManager.cachesMCAddonDirectory.appendingPathComponent(fileUrl.lastPathComponent))
            }
            
            let nextVC = AddonEditorViewController(addonModel: savedAddon, mode: .modify)
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

extension EnhancementCreatorMainVC : UICollectionViewDataSource {
    func filteredAddon() -> [SavedAddonEnch] {
        if let filterText, !filterText.isEmpty {
            return model.filteringCreatedAddon.filter({$0.displayName.containsCaseInsesetive(filterText)})
        } else {
            return model.filteringCreatedAddon
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredAddon().count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if  indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateNewItemCollectionViewCell", for: indexPath) as! CreateNewItemCollectionViewCell
            cell.setCrateTitle("Create addon")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SsvedAddonCollectionCell
            let savedAddonModel = filteredAddon()[indexPath.item - 1]
            
            cell.onDownloadButtonTapped = { [weak self] button in
                guard NetworkStatusMonitor.shared.isNetworkAvailable else {
                    self?.showNoInternetMess()
                    return
                }
                
                self?.downloadButton = button
                self?.handleDownloadButtonTap(savedAddon: savedAddonModel)
            }
            
            cell.onDeleteButtonTapped = { [weak self] in
                guard let correctIndex = self?.addonCollectionView.indexPath(for: cell) else {
                    AppDelegate.log("Error: checkUp indexPath!!!")
                    return
                }
                self?.deleteButtonTapped(indexPath: correctIndex)
            }
            
            cell.configCell(savedAddon: savedAddonModel, with: .savedAddonMOde)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
        }
        return UICollectionReusableView()
    }
}

extension EnhancementCreatorMainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / (Device.iPad ? 4 : 2) - 8
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
}

//MARK: Cell Handlers
extension EnhancementCreatorMainVC {
    private func deleteButtonTapped(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete Addon", message: "Are you sure you want to delete this Addon?", preferredStyle: .alert)
        
        // Add "Delete" action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performSkinDeletion(at: indexPath)
        }
        alert.addAction(deleteAction)
        
        // Add "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    private func performSkinDeletion(at indexPath: IndexPath) {
        
        // Animate the deletion
        if let selectedCell = self.addonCollectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                selectedCell.alpha = 0.0
                selectedCell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { [weak self] _ in
                guard let self else { return }
                let deletedSkinIndex = indexPath.item - 1
                self.model.deleteAddon(at: deletedSkinIndex)
                self.model.updateCreatedAddons()
                
                // Firstly update UI
                self.addonCollectionView.performBatchUpdates({ [weak self] in
                    self?.addonCollectionView.deleteItems(at: [indexPath])
                }, completion: nil)
            }
        }
    }
    
    private func handleDownloadButtonTap(savedAddon: SavedAddonEnch?) {
        
        guard let savedAddon else {
            AppDelegate.log("savedAddon is nil")
            return
        }
        
        let url = FileManager.default.documentDirectory.appendingPathComponent(savedAddon.file)
        
        //HARD FIX
        if savedAddon.file == "mcaddons" {
                    
            if let imageData = savedAddon.displayImageData, let image = UIImage(data: imageData) {
                share(image: image, from: downloadButton)
            } else if let image = ImageCacheManager.shared.image(forKey: savedAddon.idshka) {
                share(image: image, from: downloadButton)
            } else {
                DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: savedAddon.displayImage) { [weak self] theUrl in
                    guard theUrl != nil else { return }
                    CustomImageLoader().loadImage(from: theUrl!, id: savedAddon.idshka) { [weak self] img in
                        guard let img, let self else { return }
                        self.share(image: img, from: self.downloadButton)
                    }
                }
            }
            return
        }
    
        // Check if the file exists at the specified URL.
        if FileManager.default.fileExists(atPath: url.path) {
            share(url: url, from: downloadButton)
        } else {
            // Handle the case where the file does not exist.
            AppDelegate.log("File does not exist at the specified URL.")
        }
    }
}

extension EnhancementCreatorMainVC: SearchableCollection {
    func filterData(with text: String?) {
        filterText = text
        addonCollectionView.reloadData()
    }
}

extension EnhancementCreatorMainVC: IAPManagerAddonPurchaseProtocol {
    func addonCreatorDidUnlocked() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let _ = navigationController?.viewControllers.last as? PremiumMainController {
                navigationController?.popViewController(animated: true)
            }
            model.updateCreatedAddons()
            addonCollectionView.reloadData()
            
            unlockButton.isHidden = isSubscriptionAvailable
            addonCollectionView.isHidden = !isSubscriptionAvailable
            addonCollectionView.isHidden = !isSubscriptionAvailable
            disableOrEnableCreateAddons(isEnabled: true)
        }
    }
}
