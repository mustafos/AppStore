//
//  AddonEditorViewController.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

enum AddonEditorModifier {
    case create
    case modify
}

class AddonEditorViewController: UIViewController {
    
    private var model: EnhancementEditorModel
    private var mode: AddonEditorModifier
    
    //MARK: IBOutlets
    
    @IBOutlet private weak var customNavBarView: UIView!
    
    @IBOutlet private weak var iconLeadingContrains: NSLayoutConstraint!
    
    @IBOutlet private weak var topContainerView: UIView!
    
    @IBOutlet private weak var backBtn: UIButton!
    
    @IBOutlet private weak var saveBtn: UIButton!
    
    @IBOutlet weak var skinEditorLabel: UILabel!
    @IBOutlet weak var rightArrowIcon: UIImageView!
    
    @IBOutlet weak var indicatorContainerView: UIView!
    @IBOutlet weak var saveIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var editorBtnActivity: UIActivityIndicatorView! {
        didSet {
            editorBtnActivity.hidesWhenStopped = true
        }
    }
    
    @IBOutlet private weak var addonPreview: CustomImageLoader!
    
    @IBOutlet private weak var addonMainInfoTable: UITableView!
    
    //MARK: IBActions
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        if model.isEdited {
            saveChangeAsk()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func skinEditorTapped() {
        if model.allow3dEditing {
            setTopContainerViewDownloadMode(isActive: true)
            model.localMCAddonFileUrl { [weak self] url in
                guard let self else { return }
                self.setTopContainerViewDownloadMode(isActive: false)
                self.promptSelectionForEditor(url)
            }
        } else if model.allow2dEditing {
            open2dEditor()
        }
    }
    
    private func setTopContainerViewDownloadMode(isActive: Bool) {
        topContainerView.isUserInteractionEnabled = !isActive
        skinEditorLabel.textColor = isActive ? .darkGray : .black
        
        if isActive {
            editorBtnActivity.startAnimating()
        } else {
            editorBtnActivity.stopAnimating()
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        //in general addon save preccess is long
        //so show activity indicator
        if model.allow3dEditing, !self.model.isSavedAddonFile {
            showSaveIndicatorView()
        }
        
        saveNewAddon()
    }
    
    //MARK: Init
    
    init(addonModel: SavedAddonEnch, mode: AddonEditorModifier = .create) {
        self.model = EnhancementEditorModel(addonModel: addonModel)
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                dismissKeyboardOnTapOutside()
        
        setupViews()
        
        let idshka = model.addonModel.idshka
        
        if let imageData = model.addonModel.displayImageData, let image = UIImage(data: imageData) {
            addonPreview.image = image
        }  else if let image = ImageCacheManager.shared.image(forKey: idshka) {
            addonPreview.image = image
        } else {
            DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: model.addonModel.displayImage) { [weak self] url in
                guard url != nil else { return }
                
                self?.addonPreview.loadImage(from: url!, id: idshka) { img in
                    self?.model.addonModel.displayImageData = img?.pngData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapTopContainerGesture = UITapGestureRecognizer(target: self, action: #selector(skinEditorTapped))
        topContainerView.addGestureRecognizer(tapTopContainerGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        saveChangeAsk()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTopContainerView()
    }
    
    //MARK: Set UI
    
    private func setupViews() {
        setupCustomNavBar()
        settupTables()
        setupButtons()
        setupImageViews()
    }
    
    private func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if topContainerView.layer.cornerRadius != topContainerView.bounds.height / 2 {
            topContainerView.roundCorners(topContainerView.bounds.height / 2)
        }
    }
    private func setupCustomNavBar() {
        customNavBarView.backgroundColor = .clear
        saveBtn.setImage(UIImage(named: !isCurrentAddonIsNew ? "Save Item" : "Dowmload Item"), for: .normal)
    }
    
    private func setupTopContainerView() {
        topContainerView.roundCorners(topContainerView.bounds.height / 2)
    }
    
    private var cellId: String {
        String(describing: AddonsOptionsTableViewCell.self)
    }
    
    private func settupTables() {
        let cellnib = UINib(nibName: cellId, bundle: nil)
        addonMainInfoTable.register(cellnib, forCellReuseIdentifier: cellId)
        addonMainInfoTable.delegate = self
        addonMainInfoTable.dataSource = self
    }
    
    private func setupButtons() {
        let allow3dEditing = model.allow3dEditing
        let allow2dEditing = model.allow2dEditing
    
        setSkinEditorLabelEnabled(false)
        if !allow3dEditing && !allow2dEditing {
            skinEditorLabel.isHidden = true
            rightArrowIcon.isHidden = true
        }
        
        
//        iconLeadingContrains.isActive = editorBtn.isHidden == false
        
        if allow3dEditing {
            editorBtnActivity.startAnimating()
            model.localMCAddonFileUrl { [weak self] url in
                if let url, let destination = self?.model.unzipAddon(at: url) {
                    if let resourcePack = self?.model.resourcePack(at: destination) {
                        if !resourcePack.isEmpty {
                            DispatchQueue.main.async { [weak self] in
                                self?.setSkinEditorLabelEnabled(true)
                            }
                        }
                    }
                }
                
                self?.editorBtnActivity.stopAnimating()
            }
        } else if allow2dEditing {
            setSkinEditorLabelEnabled(true)
        }
    }
    
    private func showSaveIndicatorView() {
        indicatorContainerView.isHidden = false
        indicatorContainerView.isUserInteractionEnabled = true
        saveIndicator.startAnimating()
    }
    
    private func hideSaveIndicatorView() {
        indicatorContainerView.isHidden = true
        indicatorContainerView.isUserInteractionEnabled = false
        saveIndicator.stopAnimating()
    }
    
    private func setupImageViews() {
        addonPreview.image = nil
    }
    
    private func setSkinEditorLabelEnabled(_ isEnable: Bool) {
        skinEditorLabel.isUserInteractionEnabled = isEnable
        skinEditorLabel.textColor = isEnable ? .black :.darkGray
    }
}

extension AddonEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getPropretirs().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AddonsOptionsTableViewCell
        
        let propModel = model.getPropretirs()[indexPath.row]
        cell.cellConfigure(propModel: propModel)
        cell.delegate = self
        
        if indexPath.row == 0 {
            cell.mainContainer.roundCorners(24)
            cell.mainContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
        } else if model.getPropretirs().count - 1 == indexPath.row {
            cell.mainContainer.roundCorners(24, onlyBottomCorners: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    private func promptSelectionForEditor(_ url: URL?) {
        if let resourcePack = model.resourcePack {
            let vc = AddonEditorSelectorViewController(addonModel:  model.addonModel, resourcePack: resourcePack, mcAddonFileManager: model.mcAddonFileManager, delegate: self)
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .moveIn
            transition.subtype = .fromTop
            navigationController?.view.layer.add(transition, forKey: kCATransition)
            
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    private func open2dEditor() {
        let idshka = model.addonModel.idshka
        
        var image: UIImage?
        
        if let imageData = model.addonModel.displayImageData, let img = UIImage(data: imageData) {
            image = img
        }  else if let img = ImageCacheManager.shared.image(forKey: idshka) {
            image = img
        } else {
            DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: model.addonModel.displayImage) { [weak self] url in
                guard url != nil else { return }
                
                self?.addonPreview.loadImage(from: url!, id: idshka) { img in
                    self?.model.addonModel.displayImageData = img?.pngData()
                }
            }
        }
        
        var size = image?.size ?? .zero
        if size.width > 64 || size.height > 64 {
            size = .init(width: 64, height: 64)
            image = image?.resizeAspectFit(to: size, targetScale: 1)
        }
    
        guard let img = image?.pngData() else {
            self.showNoInternetMess()
            return
        }
    
        let vc = SkinDesignViewController(convasWidth: Int(size.width), convasHeight: Int(size.width),
                                           currentEditableSkin: .init(image: img)) { [weak self] skin in
            self?.model.addonModel.displayImageData = skin.skinAssemblyDiagram?.pngData()
            self?.model.addonModel.previewData = self?.model.addonModel.displayImageData
            
            self?.saveNewAddon()
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationController?.pushViewController(vc, animated: false)
    }
}

extension AddonEditorViewController: AddonEditorSelectorDelegate {
    func didSaveAddon(at url: URL, preview: Data) {
        
        let name = url.deletingPathExtension().lastPathComponent
        switch mode {
        case .create:
            saveAddon(name: name, file: url, preview: preview)
        case .modify:
            updateAddon(name: name, file: url, preview: preview)
        }
        
//        navigationController?.pop(to: AddonCreatorViewController.self)
    
    }
}

extension AddonEditorViewController: ModPropertiesChangeable {
    
    func didToggleSwitch(sender: UISwitch) {
        model.isEdited = true
        AppDelegate.log("didToggleSwitch")
        model.addonModel.isEnabled = sender.isOn
    }
    
    func textFieldChanged(value: String, cellName: String, sender: UITextField) {
        AppDelegate.log("\(cellName): \(value)")
        
        model.isEdited = true
        
        switch cellName {
        case EnhancementEditorModel.Field.amount:
            guard let amount = Int(value) else {
                sender.text = "\(model.addonModel.amount)"
                self.showAlert(title: "Error", message: "Can't set this wrong value to amount")
                return
            }
            model.addonModel.amount = amount
        case EnhancementEditorModel.Field.health:
            guard let health = Float(value) else {
                sender.text = "\(model.addonModel.health)"
                self.showAlert(title: "Error", message: "Can't set this wrong value to health")
                return
            }
            
            model.addonModel.health = health
        case EnhancementEditorModel.Field.attackSpeed:
            guard let ranged_attack_atk_speed = Double(value) else {
                sender.text = "\(model.addonModel.ranged_attack_atk_speed)"
                self.showAlert(title: "Error", message: "Can't set this wrong value to ranged_attack_atk_speed")
                return
            }
            
            model.addonModel.ranged_attack_atk_speed = ranged_attack_atk_speed
        case EnhancementEditorModel.Field.moveSpeed:
            guard let move_speed = Float(value) else {
                sender.text = "\(model.addonModel.move_speed)"
                self.showAlert(title: "Error", message: "Can't set this wrong value to move_speed")
                return
            }
            
            model.addonModel.move_speed = move_speed
        case EnhancementEditorModel.Field.attackRadius:
            guard let ranged_attack_atk_radius = Double(value) else {
                sender.text = "\(model.addonModel.ranged_attack_atk_radius)"
                self.showAlert(title: "Error", message: "Can't set this wrong value to ranged_attack_atk_radius")
                return
            }
            
            model.addonModel.ranged_attack_atk_radius = ranged_attack_atk_radius
        default: break
        }
    }
    
    private var isCurrentAddonIsNew: Bool {
        RealmService.shared.getArrayOfSavedAddons().contains(where: {$0.idshka == model.addonModel.idshka}) == false
    }
    
    private func saveNewAddon() {
        
        let realm = RealmService.shared
        let fileManger = FileManager.default
        
        var addon: SavedAddonRM?
        
        
        
        let isNewAddon = isCurrentAddonIsNew
        
        if !isNewAddon {
            addon = realm.getArrayOfSavedAddons().first(where: {$0.idshka == model.addonModel.idshka})
        }
        
        let queue = DispatchQueue(label: "saveFileQueue")
        queue.async(qos: .userInteractive) { [weak self] in
            guard let self else { return }
            self.model.localMCAddonFileUrl({ addonFileUrl in
                guard let addonFileUrl else {
                    print("Error - Can't download addon from server")
                    self.showAlert(title: "Error", message: "Can't download addon from server")
                    self.hideSaveIndicatorView()
                    return
                }
                var destinatioUrl = fileManger.documentDirectory.appendingPathComponent(addonFileUrl.lastPathComponent)
                
                if fileManger.secureSafeCopyItem(at: addonFileUrl, to: destinatioUrl), let addon {
                    DispatchQueue.main.async {
                        RealmService.shared.editFilePathToAddon(for: addon, newFilePath: destinatioUrl.lastPathComponent)
                    }
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.hideSaveIndicatorView()
                    if !isNewAddon {
                        if let addon {
                            let realm = RealmService.shared
                            realm.editCreatedSkinName(addon: addon, newAddon: self.model.addonModel)
                            realm.editRecentProprty(for: addon, newDate: Date())
                            
                            
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            AppDelegate.log("RealmService.shared.getSavedAddons().first error")
                        }
                    } else {
                        self.saveAddon(name: self.model.addonModel.displayName, file: destinatioUrl)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            })
            
        }
    }
    
    private func updateAddon(name: String, file: URL? = nil, preview: Data? = nil) {
        let updatedAddon = SavedAddonRM()
        updatedAddon.displayName = name
        updatedAddon.idshka = model.addonModel.idshka
        updatedAddon.displayImage = model.addonModel.displayImage
        updatedAddon.displayImageData = preview ?? model.addonModel.displayImageData
        updatedAddon.id = model.addonModel.id
        updatedAddon.type = model.addonModel.type
        updatedAddon.skin_variants.append(objectsIn: model.addonModel.skin_variants.map { AddonSkinVariantObj(name: $0.name, path: $0.path) })
        updatedAddon.health = model.addonModel.health
        updatedAddon.move_speed = model.addonModel.move_speed
        updatedAddon.ranged_attack_enabled = model.addonModel.ranged_attack_enabled
        updatedAddon.ranged_attack_atk_speed = model.addonModel.ranged_attack_atk_speed
        updatedAddon.ranged_attack_atk_radius = model.addonModel.ranged_attack_atk_radius
        updatedAddon.ranged_attack_burst_shots = model.addonModel.ranged_attack_burst_shots
        updatedAddon.ranged_attack_burst_interval = model.addonModel.ranged_attack_burst_interval
        updatedAddon.ranged_attack_atk_types = model.addonModel.ranged_attack_atk_types
        updatedAddon.isEnabled = model.addonModel.isEnabled
        updatedAddon.editingDate = model.addonModel.editingDate
        updatedAddon.file = file?.lastPathComponent
        updatedAddon.amount = model.addonModel.amount
        updatedAddon.editingDate = Date()
        
        let realm = RealmService.shared
        guard let addon = realm.getArrayOfSavedAddons().first(where: {$0.idshka == model.addonModel.idshka})  else {
            return
        }
        realm.edit(addon: addon, newAddon: updatedAddon)
            
    }
    
    private func saveAddon(name: String, file: URL? = nil, preview: Data? = nil) {
        let newAddon = SavedAddonRM()
        newAddon.idshka = UUID().uuidString
        newAddon.displayName = name
        newAddon.displayImage = model.addonModel.displayImage
        newAddon.displayImageData = preview ?? model.addonModel.displayImageData
        newAddon.id = model.addonModel.id
        newAddon.type = model.addonModel.type
        newAddon.skin_variants.append(objectsIn: model.addonModel.skin_variants.map { AddonSkinVariantObj(name: $0.name, path: $0.path) })
        newAddon.health = model.addonModel.health
        newAddon.move_speed = model.addonModel.move_speed
        newAddon.ranged_attack_enabled = model.addonModel.ranged_attack_enabled
        newAddon.ranged_attack_atk_speed = model.addonModel.ranged_attack_atk_speed
        newAddon.ranged_attack_atk_radius = model.addonModel.ranged_attack_atk_radius
        newAddon.ranged_attack_burst_shots = model.addonModel.ranged_attack_burst_shots
        newAddon.ranged_attack_burst_interval = model.addonModel.ranged_attack_burst_interval
        newAddon.ranged_attack_atk_types = model.addonModel.ranged_attack_atk_types
        newAddon.isEnabled = model.addonModel.isEnabled
        newAddon.editingDate = model.addonModel.editingDate
        newAddon.file = file?.lastPathComponent
        newAddon.amount = model.addonModel.amount
        newAddon.editingDate = Date()
        
        RealmService.shared.addAddonEditable(addon: newAddon)
    }
    
    private func saveChangeAsk() {
        if model.isEdited {
            let alert = UIAlertController(title: "Do you want to save change?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.saveNewAddon()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }
}

// Showing keyboard
extension AddonEditorViewController {
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.addonMainInfoTable.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        addonMainInfoTable.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        addonMainInfoTable.contentInset = contentInset
    }
}
