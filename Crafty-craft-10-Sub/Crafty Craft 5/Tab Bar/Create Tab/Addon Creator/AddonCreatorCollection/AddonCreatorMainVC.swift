//
//  AddonCreatorMainVC.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 10.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class AddonCreatorMainVC: UIViewController {
    var model = CreatedAddonsModel()
    
    @IBOutlet private weak var tabsStackView: UIStackView!
    
    @IBOutlet weak var selectItemView: UIView!
    @IBOutlet weak var selectedText: UILabel!
    @IBOutlet weak var selectImage: UIImageView!
    
    @IBOutlet private var tabButtons: [UIButton]!
    
    @IBOutlet weak var addonCollectionView: UICollectionView!
    @IBOutlet private weak var layouTabButton: UIButton!
    @IBOutlet private weak var groupTabButton: UIButton!
    @IBOutlet private weak var recentTabButton: UIButton!
    
    private var suggestionsTableView: UITableView?
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
            
//            updatePageControllerUI()
        }
        get {
            _tabsPageControllMode
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupCollectionView()
        configureUIComponents()
        setupTabButtons()
        setupCollectionViewUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.updateCreatedAddons()
        addonCollectionView.reloadData()
    }
    
    //MARK: - SetUp UI
    
    internal var cellId: String {
        String(describing: SsvedAddonCollectionCell.self)
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        addonCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let nib2 = UINib(nibName: "CreateNewItemCollectionViewCell", bundle: nil)
        addonCollectionView.register(nib2, forCellWithReuseIdentifier: "CreateNewItemCollectionViewCell")
    }
    
    private func configureUIComponents() {
        tabsStackView.roundCorners(.allCorners, radius: 23)
        tabsStackView.layer.borderColor = UIColor.black.cgColor
        tabsStackView.layer.borderWidth = 1
        tabsPageControllMode = .layout
        selectedText.textColor = .black
    }
    
    //MARK: - Action
    @objc func selectedColorAction(_ sender: Any) {
        showButtonVisibility()
    }
    
    @IBAction func onButtonTapped(_ sender: UIButton) {
        showButtonVisibility()
        switch tabsPageControllMode {
        case .layout:
            setButtonProperties(title: "Layout", image: "chevron.down")
            tabsPageControllMode = .layout
            model.collectionMode = .savedAddons
        case .group:
            setButtonProperties(title: "Group", image: "chevron.down")
            tabsPageControllMode = .group
            model.collectionMode = .groups
        case .recent:
            setButtonProperties(title: "Recent", image: "chevron.down")
            tabsPageControllMode = .recent
            model.collectionMode = .recent
        }
        addonCollectionView.reloadData()
    }
    
    //MARK: - Private Methods

    private func updateSelectButtonImage() {
        let imageName = isHideButtons ? "chevron.down" : "chevron.up"
        selectImage.image = UIImage(systemName: imageName)
    }
    
    private func setButtonProperties(title: String, image: String) {
        selectedText.text = title
        selectImage.image = UIImage(systemName: image)
    }
    
    private func setupTabButtons() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectedColorAction(_:)))
        selectItemView.addGestureRecognizer(tapGesture)
    }

    private func setupCollectionViewUI() {
        addonCollectionView.backgroundColor = .clear
        addonCollectionView.allowsSelection = true
        addonCollectionView.isUserInteractionEnabled = true
    }
}



extension AddonCreatorMainVC : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
//            flushSearch()
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
    func filteredAddon() -> [SavedAddon] {
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
            cell.setCrateTitle("CREATE ADDON")
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
}

extension AddonCreatorMainVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / (Device.iPad ? 4 : 2) - 8
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
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
    
    private func handleDownloadButtonTap(savedAddon: SavedAddon?) {
        
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
