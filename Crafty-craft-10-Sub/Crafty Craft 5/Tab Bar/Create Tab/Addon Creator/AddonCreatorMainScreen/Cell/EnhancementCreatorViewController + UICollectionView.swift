//
//  EnhancementCreatorViewController.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

extension EnhancementCreatorViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            flushSearch()
            
            let nextVC = AddonCategoryOptionsViewController()
            navigationController?.pushViewController(nextVC, animated: true)
            
        } else {
            guard let savedAddon = fixionModel.getSavedAddon(by: indexPath.item - 1) else { return }
            fixionModel.updateRecentForAddon(savedAddon: savedAddon)
            
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

extension EnhancementCreatorViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fixionModel.filteringCreatedAddon.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SsvedAddonCollectionCell
        
        if  indexPath.item == 0 {
            cell.configCell(savedAddon: nil, with: .plusMode)
        } else {
            let savedAddonModel = fixionModel.getSavedAddon(by: indexPath.item - 1)
            
            cell.onDownloadButtonTapped = { [weak self] button in
                guard NetworkStatusMonitor.shared.isNetworkAvailable else {
                    self?.showNoInternetMess()
                    return
                }
                
                self?.startDownload = button
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
        }
        
        return cell
    }
}

extension EnhancementCreatorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / (Device.iPad ? 4 : 2) - 8
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


//MARK: Cell Handlers

extension EnhancementCreatorViewController {
    
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
                self.fixionModel.deleteAddon(at: deletedSkinIndex)
                self.fixionModel.updateCreatedAddons()
                
                
                if self.searchFieldMode, let searchText = self.seatchTextField.text, !searchText.isEmpty {
                    self.filterContentFor(searchText: searchText)
                }
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
        
        // Check if the file exists at the specified URL.
        if FileManager.default.fileExists(atPath: url.path) {
            share(url: url, from: startDownload)
        } else {
            // Handle the case where the file does not exist.
            AppDelegate.log("File does not exist at the specified URL.")
        }
    }
}
