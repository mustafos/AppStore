//
//  SkinCreatorMainVC.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 10.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

protocol CollectionSearchable {
    func filterData(with text: String?)
}

protocol SkinPikerHandler: AnyObject {
    func showSkinPicker(for item: SkinCreatedModel)
    func showEditSkinPicker(for item: SkinCreatedModel)
}

class SkinCreatorMainVC: UIViewController {
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    var alertWindow: UIWindow?
    var blurView: UIVisualEffectView?
    
    weak var pickerShowerDelegate: SkinPikerHandler?
    
    var selectedSkinIndex = Int()
    lazy var model = SkinEditorVCModel()
    
    
    // MARK: - Outlets
    private var footerCell: UIView?
    private weak var downloadButton: UIButton?
    private var filterText: String?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuCollectionView()
        addFooterView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.updateSkinsArray()
        menuCollectionView.layoutIfNeeded()
        menuCollectionView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuCollectionView.reloadData()
    }
    
    
    // MARK: - Setup
    
    private func setupMenuCollectionView() {
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.backgroundColor = .clear
        
        let nib = UINib(nibName: "SkinEditorCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "SkinEditorCollectionViewCell")
        let nib2 = UINib(nibName: "CreateNewItemCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib2, forCellWithReuseIdentifier: "CreateNewItemCollectionViewCell")
    }
    
    private func addFooterView() {
        footerCell = UIView(frame: CGRect(x: 0, y: 0, width: menuCollectionView.bounds.width, height: 70))
        footerCell?.backgroundColor = UIColor.clear
        menuCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
    }
}

//MARK: Collection Delegate Methods

extension SkinCreatorMainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func filteredSkins() -> [SkinCreatedModel] {
        if let filterText, !filterText.isEmpty {
            return model.getSkins().filter({$0.name.containsCaseInsesetive(filterText)})
        } else {
            return model.getSkins()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredSkins().count + 1 // +1 for first cell for plusMode
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == 0 {
            let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "CreateNewItemCollectionViewCell", for: indexPath) as! CreateNewItemCollectionViewCell
            cell.setCrateTitle("Create skin")
            return cell
            
        } else {
            let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "SkinEditorCollectionViewCell", for: indexPath) as! SkinEditorCollectionViewCell
            let skinModel = filteredSkins()[indexPath.item - 1]
            
            cell.publicMode(skinInfo: skinModel)
            cell.onDownloadButtonTapped = { [weak self] button in
                guard NetworkStatusMonitor.shared.isNetworkAvailable else {
                    self?.showNoInternetMess()
                    return
                }
                
                self?.downloadButton = button
                let image = skinModel.is128sizeSkin ? skinModel.skinAssemblyDiagram128 : skinModel.skinAssemblyDiagram
                self?.handleDownloadButtonTap(skinDiagram: image, name: skinModel.name)
            }
            
            cell.onDeleteButtonTapped = { [weak self] in
                guard let correctIndex = self?.menuCollectionView.indexPath(for: cell) else {
                    AppDelegate.log("Error: checkUp indexPath!!!")
                    return
                }
                self?.handleDeleteButtonTap(indexPath: correctIndex)
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.selectedSkinIndex = indexPath.item - 1 //to get correct index of choosed skin, as we always have +1 cell because of plusMode
        
        if indexPath.item == 0 {
            pickerShowerDelegate?.showSkinPicker(for: model.getSelectedSkinModel())
        } else {
            pickerShowerDelegate?.showEditSkinPicker(for: model.getSelectedSkinModel())
        }
        model.updateSkinsArray()
    }
}

//MARK: Cell Handlers

extension SkinCreatorMainVC {
    
    private func handleDeleteButtonTap(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Delete Skin", message: "Are you sure you want to delete this skin?", preferredStyle: .alert)

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
        if let selectedCell = self.menuCollectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                selectedCell.alpha = 0.0
                selectedCell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { [weak self] _ in
                let deletedSkinIndex = indexPath.item - 1
                self?.model.deleteSkin(at: deletedSkinIndex)
                self?.model.updateSkinsArray()
                
                // Firstly update UI
                self?.menuCollectionView.performBatchUpdates({
                    self?.menuCollectionView.deleteItems(at: [indexPath])
                }, completion: nil)
            }
        }
    }
    
    private func handleDownloadButtonTap(skinDiagram: UIImage?, name: String) {
        guard let image = skinDiagram else { return }
        
        guard let data = image.pngData() else {
            AppDelegate.log("Failed to convert image to PNG data.")
            return
        }
        let fileURL = FileManager.default.cachesDirectory.appendingPathComponent("\(name).png")
        
        do {
            try data.write(to: fileURL)
            AppDelegate.log("Image saved successfully at: \(fileURL.path)")
        } catch {
            AppDelegate.log("Failed to save image: \(error)")
            return
        }
        
        minecraftSkinManager.start(fileURL) { [weak self] url in
            self?.share(url: url, from: self?.downloadButton)
        }
    }
}

// MARK: - FlowLayout
extension SkinCreatorMainVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2 - 5
        let cellHeight = cellWidth * 1.15
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
}

extension SkinCreatorMainVC: CollectionSearchable {
    func filterData(with text: String?) {
        filterText = text
        menuCollectionView.reloadData()
    }
}
