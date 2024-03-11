//
//  AddonCreatorMainVC.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 05.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class AddonCreatorMainVC: UIViewController {
    var model = EdditionalAddonModel()
    
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
        hideKeyboardWhenTappedAround()
        setupCollectionView()
        addFooterView()
        configureUIComponents()
        setupCollectionViewUI()
        updatePageControllerUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            model.updateCreatedAddons()
            addonCollectionView.reloadData()
    }

    // MARK: - SetUp UI
    internal var cellId: String {
        String(describing: SsvedAddonCollectionCell.self)
    }
    
    private func setupCollectionView() {
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
    
    private func configureUIComponents() {
        tabsStackView.roundCorners(24)
        tabsStackView.layer.borderColor = UIColor.black.cgColor
        tabsStackView.layer.borderWidth = 1
        selectImage.image = UIImage(systemName: "chevron.down")
        selectedText.text = layouTabButton.titleLabel?.text
        selectItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropDownMenu)))
        tabsPageControllMode = .layout
    }

    // MARK: – Action
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
    
    
    // MARK: - Private Methods
    private func updatePageControllerUI() {
        switch tabsPageControllMode {
        case .layout:
            updateTabUI(selected: layouTabButton, deselected: [groupTabButton, recentTabButton])
        case .group:
            updateTabUI(selected: groupTabButton, deselected: [layouTabButton, recentTabButton])
        case .recent:
            updateTabUI(selected: recentTabButton, deselected: [groupTabButton, layouTabButton])
        }
        
        addonCollectionView.reloadData()
    }
    
    private func updateTabUI(selected: UIButton, deselected: [UIButton]) {
        selectedButton = selected
        selectedButton.isHidden = true
        selectedText.text = selected.titleLabel?.text
        selected.setTitleColor(.white, for: .normal)
        deselected.forEach { button in
            button.isHidden = true
        }
    }
    
    private func setupCollectionViewUI() {
        addonCollectionView.backgroundColor = .clear
        addonCollectionView.allowsSelection = true
        addonCollectionView.isUserInteractionEnabled = true
    }
    
    @objc private func showDropDownMenu() {
        for button in [layouTabButton, groupTabButton, recentTabButton] {
            button?.isHidden.toggle()
        }
        selectImage.image = UIImage(systemName: "chevron.up")
        selectedButton?.isHidden = true
    }
}



extension AddonCreatorMainVC : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            //flushSearch()
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

extension AddonCreatorMainVC : UICollectionViewDataSource {
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
                self?.handleDeleteButtonTap(indexPath: correctIndex)
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

extension AddonCreatorMainVC: UICollectionViewDelegateFlowLayout {
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
extension AddonCreatorMainVC {
    private func handleDeleteButtonTap(indexPath: IndexPath) {
        
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

extension AddonCreatorMainVC: CollectionSearchable {
    func filterData(with text: String?) {
        filterText = text
        addonCollectionView.reloadData()
    }
}
