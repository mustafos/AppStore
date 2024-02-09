import UIKit
import BetterSegmentedControl

private enum CreateTabState {
    case skin
    case addon
}

final class CreateTabViewController: UIViewController {
    private var skinCollectonScreen: SkinCreatorMainVC?
    private var addonCollectionScreen: AddonCreatorMainVC?
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    
    // MARK: - Properties
    
    var alertWindow: UIWindow?
    var blurEffectView: UIVisualEffectView?
    private var state: CreateTabState = .skin {
        didSet {
            self.updateCollectionForCurrentState()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var navigationBarContainerView: UIView!
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
        setupSearchBar()
        updateCollectionForCurrentState()
    }
    // MARK: - Actions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    }
    
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        // TODO: - add settings VC
        let nextVC = SettingsViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navbarSearchMode.toggle()
    }
    
    private func configureView() {
        controlSwitcher.segments = LabelSegment.segments(withTitles: ["Skins", "Addons"],
                                                         normalFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                         normalTextColor: UIColor(named: "EerieBlackColor"),
                                                         selectedFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                         selectedTextColor: UIColor(named: "BeigeColor"))
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
}

extension CreateTabViewController: TabBarConfigurable {
    var tabBarIcon: UIImage? {
        return UIImage(named: "create")
    }
    
    var tabBarSelectedIcon: UIImage? {
        return UIImage(named: "createSelect")
    }

    var tabBarTitle: String {
        return "Create"
    }
}

// MARK: – CreateTabViewController
extension CreateTabViewController: UITableViewDelegate, UITableViewDataSource {
    var tableViewContainerHeight: CGFloat {
        return searchViewHeightWith(itemsCount: min(numberOfRowsInTableView, 4))
    }
    
    private func searchViewHeightWith(itemsCount: Int, rowHeight: CGFloat = 44) -> CGFloat {
        rowHeight * CGFloat(itemsCount) + searchBarView.frame.size.height
    }
    
    func showSuggestionsTableView() {
        if tableViewContainer == nil {
            let topPadding = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            let containerY = topPadding + 20
            tableViewContainer = UIView(frame: CGRect(x: searchBarView.frame.origin.x,
                                                      y: containerY,
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
            
            tableViewContainer?.backgroundColor = UIColor(named: "YellowSelectiveColor")

            // corners
            tableViewContainer?.layer.borderWidth = 1
            tableViewContainer?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
            tableViewContainer?.clipsToBounds = true
            tableViewContainer?.clipsToBounds = true
            tableViewContainer?.layer.cornerRadius = 30
            
            suggestionsTableView?.separatorStyle = .singleLine
            suggestionsTableView?.layoutMargins = UIEdgeInsets.zero
            suggestionsTableView?.separatorInset = UIEdgeInsets.zero
            suggestionsTableView?.separatorColor = UIColor(named: "EerieBlackColor")
            
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
                cell.titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
                cell.titleLabel.textColor = UIColor(named: "EerieBlackColor")
            }
        case .addon:
            if let addonCollectionScreen {
                let addons = addonCollectionScreen.filteredAddon()
                cell.titleLabel.text = addons[indexPath.row].displayName
                cell.titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
                cell.titleLabel.textColor = UIColor(named: "EerieBlackColor")
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
