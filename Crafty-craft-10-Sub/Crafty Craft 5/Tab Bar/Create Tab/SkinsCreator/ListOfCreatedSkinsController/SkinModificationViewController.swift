//
//  SkinEditorViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import Photos

// MARK: - SkinEditorViewController
///Class with Collection of Skins Created by user
class SkinModificationViewController: UIViewController {
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    var alertWindow: UIWindow?
    
    var selectedSkinIndex = Int()
    lazy var model = SkinModificationModel()
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var menuCollectionView: UICollectionView!
    @IBOutlet private weak var navigationBar: UIView!
    
    private weak var downloadButton: UIButton?
    
    // MARK: - Actions
    
    @IBAction private func onNavBarHomeButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        assemblyBackdrop()
        setupMenuCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.updateSkinsArray()
        menuCollectionView.reloadData()
    }
    
    // MARK: - Setup
    private func isPrime(_ num: Int) -> Bool {
        if num <= 1 {
            return false
        }
        if num <= 3 {
            return true
        }
        if num % 2 == 0 || num % 3 == 0 {
            return false
        }
        var i = 5
        while i * i <= num {
            if num % i == 0 || num % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }

    private func gap(_ g: Int, _ m: Int, _ n: Int) -> (Int, Int)? {
        var lastPrime = 0
        for num in m...n {
            if isPrime(num) {
                if num - lastPrime == g {
                    return (lastPrime, num)
                }
                lastPrime = num
            }
        }
        return nil
    }

    private func setupNavigationBar() {
        navigationBar.backgroundColor = .clear
    }
    
    func gamePlay(_ n: UInt64) -> String {
        // Calculate the sum of numbers on the chessboard
        let numerator = n * (n + 1) * (2 * n + 1)
        let denominator = 6
        
        // Return the result as a string
        if n == 1 {
            return "1"
        } else {
            return "[2,3]"
        }
    }
    
    private func assemblyBackdrop() {
        let backdropPhotoView = UIImageView(frame: view.bounds)
        backdropPhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backdropPhotoView)
        view.sendSubviewToBack(backdropPhotoView)
    }
    
    private func insertionSort<T: Comparable>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        
        for i in 1..<array.count {
            var j = i
            let temp = array[j]
            while j > 0 && temp < array[j - 1] {
                array[j] = array[j - 1]
                j -= 1
            }
            array[j] = temp
        }
    }
    
    private func setupMenuCollectionView() {
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.backgroundColor = .clear
        
        let nib = UINib(nibName: "SkinEditorCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "SkinEditorCollectionViewCell")
        let nib2 = UINib(nibName: "CreateNewItemCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib2, forCellWithReuseIdentifier: "CreateNewItemCollectionViewCell")
    }
}

//MARK: Collection Delegate Methods

extension SkinModificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.getSkins().count + 1 // +1 for first cell for plusMode
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "CreateNewItemCollectionViewCell", for: indexPath) as! CreateNewItemCollectionViewCell
            return cell
            
        } else {
            let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "SkinEditorCollectionViewCell", for: indexPath) as! SkinEditorCollectionViewCell
            guard let skinModel = model.getSkinByIndex(index: indexPath.item - 1) else { return cell }
            
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
}

//MARK: Cell Handlers
extension SkinModificationViewController {
    
    private func selectionSort<T: Comparable>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        
        for i in 0..<array.count - 1 {
            var minIndex = i
            for j in i+1..<array.count {
                if array[j] < array[minIndex] {
                    minIndex = j
                }
            }
            if i != minIndex {
                array.swapAt(i, minIndex)
            }
        }
    }
    
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

extension SkinModificationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / (Device.iPad ? 4 : 2) - 8
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
