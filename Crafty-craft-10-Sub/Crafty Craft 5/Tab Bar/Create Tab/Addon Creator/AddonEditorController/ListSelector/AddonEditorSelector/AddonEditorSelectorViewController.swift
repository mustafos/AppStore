//
//  AddonEditorSelectorViewController.swift
//  Crafty Craft 5
//
//  Created by dev on 17.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

protocol AddonEditorSelectorDelegate: AnyObject {
    func didSaveAddon(at url: URL, preview: Data)
}

class AddonEditorSelectorViewController: UIViewController {
    
    private lazy var photoGalleryManager: ImageGalleryCoordinatorProtocol = ImageGalleryCoordinator()
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomConstrains: NSLayoutConstraint!
    
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let addonModel: SavedAddonEnch
    
    private var selectedResourcePack: ResourcePack?
    private var resourcePack: [ResourcePack]
    private var resourcePackForFilter: [ResourcePack] = []
    
    private let mcAddonFileManager: AddonFileManagerProtocol
    
    private weak var delegate: AddonEditorSelectorDelegate?
    
    init(addonModel: SavedAddonEnch, resourcePack: [ResourcePack], mcAddonFileManager: AddonFileManagerProtocol, delegate: AddonEditorSelectorDelegate) {
        self.addonModel = addonModel
        let removedUV6Packs = resourcePack.compactMap({if let _ = $0.geometry as? MinecraftGeometryModel {
            return $0
        }
            return nil
        })
        self.resourcePack = removedUV6Packs
        self.resourcePackForFilter = removedUV6Packs
        self.mcAddonFileManager = mcAddonFileManager
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewButtons()
        setupSearchBar()
        setupCollectionView()
                dismissKeyboardOnTapOutside()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    private func filterData(with searchText: String) {
        if searchText.isEmpty {
            resourcePack = resourcePackForFilter
            collectionView.reloadData()
        } else {
            resourcePack = resourcePack.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            collectionView.reloadData()
        }
    }
    
    private func setupSearchBar() {
        searchBar.overrideUserInterfaceStyle = .dark
        searchBar.searchTextField.clearButtonMode = .never
    }
    
    func setupViewButtons() {
        contentView.roundCorners(26)
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
        
        importButton.roundCorners(26)
        
        doneButton.roundCorners(26)
        doneButton.borderColor = .black
        doneButton.borderWidth = 1
        
        cancelButton.roundCorners(26)
        cancelButton.borderColor = .black
        cancelButton.borderWidth = 1
    }
    
    private var cellId: String {
        String(describing: AddonCollectionViewCell.self)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: cellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        collectionView.register(FooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterCell")
        collectionView.backgroundColor = .clear
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchBar.isHidden.toggle()
        backButton.isHidden.toggle()
        titleLabel.isHidden.toggle()
        searchButton.isHidden.toggle()
        
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func importTapped(_ sender: UIButton) {
        photoGalleryManager.getImageFromPhotoLibrary(from: self) { [weak self] image in
                        
            guard let resourcePack = self?.resourcePack.first else { return }
            
            let texture = UIImage(data: resourcePack.image)
            
            guard let size = texture?.size, let newImage = image.pixelateAndResize(to: size)?.resizeAspectFit(to: size, targetScale: 1) else {
                return
            }
            
            let newPack = resourcePack.copy(with: newImage.pngData()!)
            
            self?.selectedResourcePack = newPack
            
            self?.openEditor(for: newPack)
        }
    }
    
    private func dismiss() {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        transition.subtype = .fromBottom
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popViewController(animated: false)
    }

    private func openEditor(for resourcePack: ResourcePack) {
        let vc = AddonEditor3DViewController(resourcePack: resourcePack, savingDelegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AddonEditorSelectorViewController: AddonSaveable {
    func saved(name: String, geometry: URL, texture: URL, preview: URL) -> URL? {
        guard let resource = selectedResourcePack else {
            assert(false, "missed Resource Pack")
            
            return nil
        }
        
        guard let saveUrl = mcAddonFileManager.save(resource, name: name, geometry: geometry, texture: texture, preview: preview) else {
            
            return nil
        }
        
        var previewData: Data?
        
        if let data = try? Data(contentsOf: preview) {
            previewData = data
            
            if let image = UIImage(data: data)?.trimmingTransparentPixels(maximumAlphaChannel: 10) {
                let resizedImage = image.resizeAspectFit(to: .init(width: 100, height: 100), targetScale: 1)
                
                if let squaredImage = resizedImage.squared {
                    previewData = squaredImage.pngData()
                    
                    try? previewData?.write(to: preview, options: .atomic)
                }
            }
        }
        
        guard let textureData = try? Data(contentsOf: texture) else {
            return nil
        }
        
        delegate?.didSaveAddon(at: saveUrl, preview: previewData ?? textureData)
        
        return saveUrl
    }
}

extension AddonEditorSelectorViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedResourcePack = resourcePack[indexPath.item]
        
        guard let selectedResourcePack else { return }
        
        openEditor(for: selectedResourcePack)
    }
}

extension AddonEditorSelectorViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resourcePack.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AddonCollectionViewCell
        
        var cellModel: ResourcePack
        cellModel = resourcePack[indexPath.item]
        let skinName = cellModel.name.split(separator: ":").last ?? ""
        let skinTitle = skinName.replacingOccurrences(of: "_", with: " ")
        
        cell.label.text = skinTitle
        
        if let image = ImageCacheManager.shared.image(forKey: cellModel.name) {
            cell.image.image = image
        } else {
            if let skinVariant = addonModel.skin_variants.first(where: { $0.name == skinName }) {
                DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: skinVariant.path) { url in
                    guard url != nil else {
                        cell.image.image = UIImage(data: cellModel.image)
                        return
                    }
                    
                    cell.image.loadImage(from: url!, id: cellModel.name) { _ in }
                }
            } else {
                cell.image.image = UIImage(data: cellModel.image)
            }
        }
        
        return cell
    }
}

extension AddonEditorSelectorViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterCell", for: indexPath)
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 136)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2 - 11
        let cellHeight = cellWidth * 1.3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 4, left: 8, bottom: 4, right: 8)
    }
}

extension AddonEditorSelectorViewController: KeyboardStateProtocol {
    func keyboardShows(height: CGFloat) {
        bottomConstrains.constant = height
        view.layoutIfNeeded()
    }
    
    func keyboardHides() {
        bottomConstrains.constant = 16
        view.layoutIfNeeded()
    }
}

extension AddonEditorSelectorViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterData(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden.toggle()
        backButton.isHidden.toggle()
        titleLabel.isHidden.toggle()
        searchButton.isHidden.toggle()
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterData(with: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterData(with: "")
        searchBar.resignFirstResponder()
    }
}
