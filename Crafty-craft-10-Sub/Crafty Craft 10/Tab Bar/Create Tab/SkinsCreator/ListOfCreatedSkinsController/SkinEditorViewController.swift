import UIKit
import Photos


// MARK: - SkinEditorViewController
///Class with Collection of Skins Created by user
class SkinEditorViewController: UIViewController {
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    var alertWindow: UIWindow?
    var blurView: UIVisualEffectView?
    
    var selectedSkinIndex = Int()
    lazy var model = SkinEditorVCModel()
    
    
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
        setupBackground()
        setupMenuCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.updateSkinsArray()
        menuCollectionView.reloadData()
    }
    
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationBar.backgroundColor = .clear
    }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "Green Background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
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


// MARK: - CustomAlertViewControllerDelegate

extension SkinEditorViewController: CustomAlertViewControllerDelegate {
    
    func open2DEditor() {
        
        let selectedSkin = model.getSelectedSkinModel()
        let nextVC = BodyPartPickerViewController(currentEditableSkin: selectedSkin)
        
        dismissCustomAlert()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func open3DEditor() {
        let nextVC = Skin3DTestViewController(currentEditableSkin: model.getSelectedSkinModel(), skinAssemblyDiagramSize: .size64x64)
        
        dismissCustomAlert()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func open3DEditor128x128() {
        let nextVC = Skin3DTestViewController(currentEditableSkin: model.getSelectedSkinModel(), skinAssemblyDiagramSize: .size128x128)
        
        dismissCustomAlert()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func importSkinFromGallery() {
        dismissCustomAlert()
        
        photoGalleryManager.getImageFromPhotoLibrary(from: self) { [unowned self] image in
            
            let selectedSkin = model.getSelectedSkinModel()
            guard let pixelizedImg = image.resizeAspectFit(targetScale: 1).squared else { return }
            
            selectedSkin.skinAssemblyDiagram = pixelizedImg
            let nextVC = Skin3DTestViewController(currentEditableSkin: selectedSkin, skinAssemblyDiagramSize: .size64x64)
            
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func dismissCustomAlert() {
        alertWindow?.isHidden = true
        alertWindow = nil
        blurView?.removeFromSuperview()
    }
    
    private func presentCustomAlert(savedSkin: Bool, is128sizeSkin: Bool?) {
        
        let customAlert = PopUpViewController(showFor: savedSkin, is128sizeSkin: is128sizeSkin, delegate: self)
        
        let alertWindow = UIWindow(frame: view.frame)
        alertWindow.windowLevel = .alert
        alertWindow.rootViewController = UIViewController()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = alertWindow.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alertWindow.rootViewController?.view.addSubview(blurView)
        
        alertWindow.rootViewController?.addChild(customAlert)
        alertWindow.rootViewController?.view.addSubview(customAlert.view)
        customAlert.didMove(toParent: alertWindow.rootViewController)
        
        alertWindow.makeKeyAndVisible()
        alertWindow.windowScene = view.window?.windowScene
        
        customAlert.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customAlert.view.topAnchor.constraint(equalTo: alertWindow.rootViewController!.view.topAnchor),
            customAlert.view.bottomAnchor.constraint(equalTo: alertWindow.rootViewController!.view.bottomAnchor),
            customAlert.view.leadingAnchor.constraint(equalTo: alertWindow.rootViewController!.view.leadingAnchor),
            customAlert.view.trailingAnchor.constraint(equalTo: alertWindow.rootViewController!.view.trailingAnchor)
        ])
        
        self.alertWindow = alertWindow
        self.blurView = blurView
    }
}


//MARK: Collection Delegate Methods

extension SkinEditorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.selectedSkinIndex = indexPath.item - 1 //to get correct index of choosed skin, as we always have +1 cell because of plusMode
        
        if indexPath.item == 0 {
            presentCustomAlert(savedSkin: false, is128sizeSkin: nil)
        } else {
            let is128Value = model.getSkinByIndex(index: (indexPath.item - 1))?.is128sizeSkin
            presentCustomAlert(savedSkin: true, is128sizeSkin: is128Value)
        }
        
        model.updateSkinsArray()
    }
}

//MARK: Cell Handlers

extension SkinEditorViewController {
    
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

extension SkinEditorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2 - 5
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
