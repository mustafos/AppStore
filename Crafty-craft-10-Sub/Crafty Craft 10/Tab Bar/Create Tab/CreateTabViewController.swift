import UIKit
import BetterSegmentedControl

extension UIColor {
    static let greenCC = UIColor(red: 0/255, green: 151/255, blue: 78/255, alpha: 1.00)
}

enum CreateTabState {
    case skin
    case addon
}

final class CreateTabViewController: UIViewController {
    private var skinCollectonScreen: SkinCreatorMainVC?
    private var addonCollectionScreen: AddonCreatorMainVC?
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    
    // MARK: - Properties
    
    var alertWindow: UIWindow?
    var blurView: UIVisualEffectView?
    private var state: CreateTabState = .skin {
        didSet {
            self.updateCollectionForCurrentState()
        }
    }
    @IBOutlet weak var navigationBarContainerView: UIView!
    // MARK: - Outlets
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var controlSwitcher: BetterSegmentedControl!
    @IBOutlet weak var searchBarView: SearchBarView!
    
    private var suggestionsTableView: UITableView?
    private var tableViewContainer: UIView?
    private var selectedSkinModel: SkinCreatedModel?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupBackground()
        setupSearchBar()
        updateCollectionForCurrentState()
    }
    // MARK: - Actions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "Green Background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.skinCollectonScreen?.view.frame = self.collectionContainer.bounds
        self.addonCollectionScreen?.view.frame = self.collectionContainer.bounds
        self.skinCollectonScreen?.view.layoutIfNeeded()
        self.addonCollectionScreen?.view.layoutIfNeeded()
    }
    
    private func updateSearchViewIfNeeed() {
        guard tableViewContainer != nil else { return }
        
        if let tableViewFrame = tableViewContainer?.frame {
            tableViewContainer?.frame = .init(origin: tableViewFrame.origin,
                                              size: .init(width: tableViewFrame.size.width,
                                                          height: tableViewContainerHeight))
            tableViewContainer?.layoutIfNeeded()
        }
        
        if let suggestTableViewFrame = suggestionsTableView?.frame {
            suggestionsTableView?.frame = .init(origin: suggestTableViewFrame.origin,
                                                size: .init(width: suggestTableViewFrame.size.width,
                                                            height: tableViewContainerHeight - searchBarView.frame.size.height))
            suggestionsTableView?.layoutIfNeeded()
            
        }
    }
    
    
    private func updateCollectionForCurrentState() {
        switch state {
        case .skin:
            if skinCollectonScreen == nil {
                self.skinCollectonScreen = SkinCreatorMainVC()
                self.skinCollectonScreen?.pickerShowerDelegate = self
                self.skinCollectonScreen!.view.frame = self.collectionContainer.bounds
                self.addChild(self.skinCollectonScreen!)
                self.collectionContainer.addSubview(self.skinCollectonScreen!.view)
            }
            
            self.addonCollectionScreen?.view.isHidden = true
            self.skinCollectonScreen?.view.isHidden = false
        case .addon:
            if addonCollectionScreen == nil {
                self.addonCollectionScreen = AddonCreatorMainVC()
                self.addonCollectionScreen!.view.frame = self.collectionContainer.bounds
                self.addChild(self.addonCollectionScreen!)
                self.collectionContainer.addSubview(self.addonCollectionScreen!.view)
            }
            self.addonCollectionScreen?.view.isHidden = false
            self.skinCollectonScreen?.view.isHidden = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    private var navbarSearchMode: Bool = false {
        didSet {
            navBarSearchMode(predicate: navbarSearchMode)
        }
    }
    
    private func navBarSearchMode(predicate: Bool) {
        if predicate {
            for subview in navigationBarContainerView.subviews {
                subview.isHidden = true
            }
            searchBarView.isHidden = false
        } else {
            for subview in navigationBarContainerView.subviews {
                subview.isHidden = false
            }
            searchBarView.isHidden = true
        }
    }
    
    @IBAction func onCreateSkinButtonTapped(_ sender: UIButton) {
        let nextVC = SkinEditorViewController() // ListOfCreatedSkinsController
        navigationController?.pushViewController(nextVC, animated: true)
//        if skinCreateSubIsValid == true {
//            let nextVC = SkinEditorViewController() // ListOfCreatedSkinsController
//            navigationController?.pushViewController(nextVC, animated: true)
//
//        } else {
//            //SUB CONTROLLER
//            let nextVC = PremiumMainController()
//            nextVC.productBuy = .unlockOther
//            navigationController?.pushViewController(nextVC, animated: true)
//        }
    }
    
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        // TODO: - add settings VC
        let nextVC = SettingsViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navbarSearchMode.toggle()
    }
    
    
    
//    @IBAction func onCreateAddonButtonTapped(_ sender: UIButton) {
//        let nextVC = AddonCreatorViewController()
//        navigationController?.pushViewController(nextVC, animated: true)
////        if addonCreateSubIsValid == true {
////            let nextVC = AddonCreatorViewController()
////            navigationController?.pushViewController(nextVC, animated: true)
////
////        } else {
////            //SUB CONTROLLER
////            let nextVC = PremiumMainController()
////            nextVC.productBuy = .unlockFuncProduct
////            navigationController?.pushViewController(nextVC, animated: true)
//////            UIApplication.shared.setRootVC(nextVC)
////        }
//    }
    
    
    // MARK: - Private Methods
//    private func setExclusiveTouchForButtons() {
//        self.createSkinBtn.isExclusiveTouch = true
//        self.createAddonBtn.isExclusiveTouch = true
//    }
    
    private func configureView() {
//        let backgroundImageView = UIImageView(frame: view.bounds)
//        backgroundImageView.image = UIImage(named: "Green Background")
//        backgroundImageView.contentMode = .scaleAspectFill
//        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(backgroundImageView)
//        view.sendSubviewToBack(backgroundImageView)
        
        controlSwitcher.segments = LabelSegment.segments(withTitles: ["SKINS", "ADDONS"],
                                                         normalFont: UIFont.blinkerFont(.semiBold, size: 14),
                                                         normalTextColor: UIColor.greenCC,
                                                         selectedFont: UIFont.blinkerFont(.semiBold, size: 14),
                                                         selectedTextColor: .white)
        
//        LabelSegment.segments(withTitles: ["SKINS", "ADDONS"],
//                                                         normalTextColor: UIColor.greenCC,
//                                                         selectedTextColor: .white)
        
//        headerLabel.textColor = .white
//        navigationBarContainerView.backgroundColor = .clear
    }
    
    
    @IBAction func segmentControlChangeAction(_ sender: BetterSegmentedControl) {
        switch sender.index {
        case 0: // SKINS
            self.state = .skin
        default:
            self.state = .addon

        }
        searchBarView.searchTextField.resignFirstResponder()
        self.flushSearch()
    }
    
    private func setupSearchBar() {
        searchBarView.buttonTapAction = { [weak self] in
            self?.flushSearch()
        }
        searchBarView.onTextChanged = { [weak self] searchText in
            self?.filterData(with: searchText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.suggestionsTableView?.reloadData()
                self?.updateSearchViewIfNeeed()
            }
        }
        
        searchBarView.onStartSearch = { [weak self] in
            guard let self else {return}
            self.showSuggestionsTableView()
            self.updateSearchViewIfNeeed()
        }
        
        searchBarView.onEndSearch = { [weak self] in
            guard let self else {return}
            self.removeSuggestionsTableView()
            self.updateSearchViewIfNeeed()
        }
    }
    
    private func flushSearch() {
        navbarSearchMode = false
        searchBarView.searchTextField.text = nil
        self.filterData(with: "")
    }
    
    private func filterData(with searchText: String) {
        let search: String? = !searchText.isEmpty ? searchText : nil
            
        switch state {
        case .skin:
            self.skinCollectonScreen?.filterData(with: search)
        case .addon:
            self.addonCollectionScreen?.filterData(with: search)
        }
    }
    
//    @IBAction func segmentControlChangeAction(_ sender: BetterSegmentedControl) {

//    }
    ///Checks up if products had been successfully validated
    ///if not, and we still have no response, runs own validation
//    private func checkProducts() {
//        //CheckSkinProduct
//        if IAPManager.shared.skinCreatorSubIsValid == nil {    // nil - if subscription have not loaded in sceneDelegate
//            validateSub(for: Configurations.unlockerThreeSubscriptionID)
//            disableOrEnableCreateSkins(isEnabled: false)
//        }
//
//        if IAPManager.shared.addonCreatorIsValid == nil { // nil - if subscription have not loaded in sceneDelegate
//            validateSub(for: Configurations.unlockFuncSubscriptionID)
//            disableOrEnableCreateAddon(isEnabled: false)
//        }
//    }
    
//    private func disableOrEnableCreateSkins(isEnabled: Bool) {
//        if isEnabled == true {
//            skinActivityIndicator.stopAnimating()
//        } else {
//            skinActivityIndicator.startAnimating()
//        }
//        skinActivityIndicator.isHidden = isEnabled
//        createSkinBtn.isEnabled = isEnabled
//        createSkinBtn.isUserInteractionEnabled = isEnabled
//    }
//
//    private func disableOrEnableCreateAddon(isEnabled: Bool) {
//        if isEnabled == true {
//            addonActivityIndicator.stopAnimating()
//        } else {
//            addonActivityIndicator.startAnimating()
//        }
//        addonActivityIndicator.isHidden = isEnabled
//        createAddonBtn.isEnabled = isEnabled
//        createAddonBtn.isUserInteractionEnabled = isEnabled
//    }
    
    
    //Should never work - validation should be done in scene
//    private func validateSub(for productName: String) {
//        IAPManager.shared.validateSubscriptions(productIdentifiers: [productName]) { [weak self] results in
//            switch productName {
//            case Configurations.unlockerThreeSubscriptionID:
//                if let value = results[Configurations.unlockerThreeSubscriptionID] {
//                    self?.skinCreateSubIsValid = value
//                } else {
//                    self?.skinCreateSubIsValid = false
//                }
//                IAPManager.shared.skinCreatorSubIsValid = self?.skinCreateSubIsValid
//            case Configurations.unlockerThreeSubscriptionID:
//                if let value = results[Configurations.unlockerThreeSubscriptionID] {
//                    self?.skinCreateSubIsValid = value
//                } else {
//                    self?.skinCreateSubIsValid = false
//                }
//                IAPManager.shared.skinCreatorSubIsValid = self?.skinCreateSubIsValid
//            case Configurations.unlockFuncSubscriptionID:
//                if let value = results[Configurations.unlockFuncSubscriptionID] {
//                    self?.addonCreateSubIsValid = value
//                } else {
//                    self?.addonCreateSubIsValid = false
//                }
//
//                IAPManager.shared.addonCreatorIsValid = self?.addonCreateSubIsValid
//            default:
//                break
//
//            }
//        }
//    }
    
//    private func lockUnlockCreator() {
//        if let skinCreateSubIsValid = skinCreateSubIsValid {
//            let unlockedImg = UIImage(named: "Create Skin Button")
//            let lockedImg = UIImage(named: "skinCreatorBlured")
//
//            createSkinBtn.setBackgroundImage(skinCreateSubIsValid ? unlockedImg : lockedImg, for: .normal)
//        }
//
//        if let addonCreateSubIsValid = addonCreateSubIsValid {
//            let unlockedImg = UIImage(named: "Create Addon Button")
//            let lockedImg = UIImage(named: "AddonCreatorBlured")
//
//            createAddonBtn.setBackgroundImage(addonCreateSubIsValid ? unlockedImg : lockedImg, for: .normal)
//        }
//    }
    
}

extension CreateTabViewController: TabBarConfigurable {
    var tabBarIcon: UIImage? {
        return UIImage(named: "Create TabBar Icon")
    }

    var tabBarTitle: String {
        return "Create"
    }
}

// Suggest view
extension CreateTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    var tableViewContainerHeight: CGFloat {
        return searchViewHeightWith(itemsCount: min(numberOfRowsInTableView, 4))
    }
    
    private func searchViewHeightWith(itemsCount: Int, rowHeight: CGFloat = 44) -> CGFloat {
        rowHeight * CGFloat(itemsCount) + searchBarView.frame.size.height
    }
    
    func showSuggestionsTableView() {
        if tableViewContainer == nil {
            let y: CGFloat = navigationBarContainerView.frame.origin.y + 2  //+ navigationBarContainerView.frame.height + 10
            tableViewContainer = UIView(frame: CGRect(x: searchBarView.frame.origin.x,
                                                          y: y,
                                                          width: searchBarView.frame.width,
                                                          height: tableViewContainerHeight))
            
            suggestionsTableView = UITableView(frame: CGRect(x: 0,
                                                             y: searchBarView.frame.size.height,
                                                             width: tableViewContainer!.frame.width,
                                                             height: tableViewContainer!.frame.size.height - searchBarView.frame.size.height))
            
            suggestionsTableView?.register(UINib(nibName: "SearchSuggestionCell", bundle: nil), forCellReuseIdentifier: SearchSuggestionCell.identifier)
            suggestionsTableView?.delegate = self
            suggestionsTableView?.dataSource = self
            suggestionsTableView?.contentInsetAdjustmentBehavior = .never
            suggestionsTableView?.backgroundColor = .clear
            
            tableViewContainer?.backgroundColor = UIColor(red: 0.086, green: 0.404, blue: 0.341, alpha: 1)

            // corners
            tableViewContainer?.clipsToBounds = true
            tableViewContainer?.layer.cornerRadius = 20
            
            view.bringSubviewToFront(navigationBarContainerView!)
            
            tableViewContainer!.addSubview(suggestionsTableView!)
            
            view.insertSubview(tableViewContainer!, belowSubview: navigationBarContainerView)
        }
    }
    
    func removeSuggestionsTableView() {
        tableViewContainer?.removeFromSuperview()
        tableViewContainer = nil
        suggestionsTableView = nil
    }
    
    var numberOfRowsInTableView: Int {
        if let searchText = searchBarView.searchTextField.text, searchText.isEmpty {
            return 0
        }
        
        switch state {
        case .skin:
            if let skinCollectonScreen {
                let skins = skinCollectonScreen.filteredSkins()
                return skins.count > 8 ? 8 : skins.count
            }
            return 0
        case .addon:
            if let addonCollectionScreen {
                let addons = addonCollectionScreen.filteredAddon()
                return addons.count > 8 ? 8 : addons.count
            }
            return 0
        }
    }
    
    // MARK: - table data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInTableView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionCell.identifier) as! SearchSuggestionCell
        
        switch state {
        case .skin:
            if let skinCollectonScreen {
                let skins = skinCollectonScreen.filteredSkins()
                cell.titleLabel.text = skins[indexPath.row].name
            }
        case .addon:
            if let addonCollectionScreen {
                let addons = addonCollectionScreen.filteredAddon()
                cell.titleLabel.text = addons[indexPath.row].displayName
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedText = ""
        switch state {
        case .skin:
            if let skinCollectonScreen {
                let skins = skinCollectonScreen.filteredSkins()
                selectedText = skins[indexPath.row].name
            }
        case .addon:
            if let addonCollectionScreen {
                let addons = addonCollectionScreen.filteredAddon()
                selectedText = addons[indexPath.row].displayName
            }
        }
        
        searchBarView.setSearchBarText(selectedText)
        searchBarView.endEditing(true)
    }
}

extension CreateTabViewController: SkinPikerHandler {
    func showEditSkinPicker(for item: SkinCreatedModel) {
        selectedSkinModel = item
        let vc = SkinVariantsViewController()
        vc.state = .edit
        vc.presenterDelegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    func showSkinPicker(for item: SkinCreatedModel) {
        selectedSkinModel = item
        let vc = SkinVariantsViewController()
        vc.presenterDelegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
}

extension CreateTabViewController: SkinVariantsPrsenter {
    func edit2dTapped() {
        create2dTapped()
    }
    
    func edit3dTapped() {
        create3dTapped()
    }
    
    func create2dTapped() {
        guard let selectedSkinModel else { return }
        let nextVC = BodyPartPickerViewController(currentEditableSkin: selectedSkinModel)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func create3dTapped() {
        guard let selectedSkinModel else { return }
        let nextVC = Skin3DTestViewController(currentEditableSkin: selectedSkinModel, skinAssemblyDiagramSize: .size64x64)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func create3d128Tapped() {
        guard let selectedSkinModel else { return }
        let nextVC = Skin3DTestViewController(currentEditableSkin: selectedSkinModel, skinAssemblyDiagramSize: .size128x128)
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func importTapped() {
        let alert = UIAlertController(title: "Import Texture", message: "Are you sure you want to import texture from the Photo library?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            self.photoGalleryManager.getImageFromPhotoLibrary(from: self) { [unowned self] image in
                guard var selectedSkinModel = self.selectedSkinModel else { return }
                guard let pixelizedImg = image.resizeAspectFit(targetScale: 1).squared else { return }
                
                selectedSkinModel.skinAssemblyDiagram = pixelizedImg
                let nextVC = Skin3DTestViewController(currentEditableSkin: selectedSkinModel, skinAssemblyDiagramSize: .size64x64)
                
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true)
    }
}


////MARK: KeyboardStateDelegate
//
//extension CreateTabViewController: KeyboardStateProtocol {
//    func keyboardShows(height: CGFloat) {
//        let insets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
//        contentCollectionView.contentInset = insets
//        view.layoutIfNeeded()
//    }
//
//    func keyboardHides() {
//        contentCollectionView.contentInset = .zero
//        view.layoutIfNeeded()
//    }
//}
