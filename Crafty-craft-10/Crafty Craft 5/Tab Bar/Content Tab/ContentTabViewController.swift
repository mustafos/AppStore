import UIKit
import BetterSegmentedControl
import Foundation
import SwiftUI
import RealmSwift

class ContentTabViewController: UIViewController, TabBarConfigurable {
    
    // MARK: - Outlets
    @IBOutlet private weak var navigationBarContainerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var contentCollectionView: UICollectionView!
    @IBOutlet private var roundedViewContainers: [UIView]!
    @IBOutlet private weak var sortButtonsContainerView: UIView!
    
    
    @IBOutlet weak var controlSwitcher: BetterSegmentedControl!
    
    @IBOutlet private weak var tabChooseStackView: UIStackView!
    @IBOutlet private weak var skinsButtonRoundedView: UIView!
    @IBOutlet private weak var mapsButtonRoundedView: UIView!
    @IBOutlet private weak var addonsButtonRoundedView: UIView!
    @IBOutlet private weak var mapsPageControllerLabel: UILabel!
    @IBOutlet private weak var addonsPageControllerLabel: UILabel!
    @IBOutlet private weak var skinsPageControllerLabel: UILabel!
    
    @IBOutlet private weak var searchBarView: SearchBarView!
    
    private var suggestionsTableView: UITableView?
    private var tableViewContainer: UIView?
    
    private var contentFilterView: ContentFilterView! = nil
    private var lockedCategoryName: String?
    
    private var skinNotifictionToken: NotificationToken?
    private var mapsNotifictionToken: NotificationToken?
    private var addonNotifictionToken: NotificationToken?
    
    
    // MARK: - Properties
    
    private var purchIsValid: Bool = false
    private var isShowedSubsription: Bool = false
    
    private func updatePurchaseStatus(isPurchased: Bool, isAfterSubscription: Bool = false) {
        let oldValue = purchIsValid
        purchIsValid = isPurchased
        if !oldValue, oldValue != isPurchased{
            if isAfterSubscription {
                let setFilterCategory: Set<String> = Set(pageModel.map { $0.filterCategory })
                let sortedCategory = setFilterCategory.sorted()
                if let firstCategory = sortedCategory.first {
                    segmentedControllMode = .filter(firstCategory)
                }
                
                setupFilterView(selectedIndex: 2)
            } else {
                segmentedControllMode = .latest
                setupFilterView()
            }
        }
    }
    
    private var filteredPageModel: [TabPagesCollectionCellModel] = []
    private var pageModel: [TabPagesCollectionCellModel] = []
    
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.acme.serial")
        
        return queue
    }()
    
    private func setUpPageModel() -> [TabPagesCollectionCellModel] {
        switch tabsPageControllMode {
            
        case .skins:
            let allSkins = RealmServiceProviding.shared.getAllSkins()
            return allSkins.map { TabPagesCollectionCellModel(id: $0.id, name: $0.name, image: $0.skinImagePath, isContentNew: Bool($0.isNew) ?? false, description: "", isFavorite: $0.isFavorite, imageData: $0.skinImageData, filterCategory: $0.filterCategory, file: $0.skinSourceImagePath) }
            
        case .addons:
            let allAddons = RealmServiceProviding.shared.getAllAddons()
            return allAddons.map { TabPagesCollectionCellModel(id: $0.id, name: $0.addonTitle, image: $0.addonImages.first ?? "", isContentNew: Bool($0.isNew) ?? false, description: $0.addonDescription, isFavorite: $0.isFavorite, imageData: $0.addonImageData, filterCategory: $0.filterCategory, file: $0.file) }
        case .maps:
            let allMaps = RealmServiceProviding.shared.getAllMap()
            return allMaps.map { TabPagesCollectionCellModel(id: $0.id, name: $0.mapTitle, image: $0.mapImages.first ?? "", isContentNew: Bool($0.isNew) ?? false, description: $0.mapDescription, isFavorite: $0.isFavorite, imageData: $0.mapImageData, filterCategory: $0.filterCategory, file: $0.file) }
        }
    }
    
    private var navbarSearchMode: Bool = false {
        didSet {
            navBarSearchMode(predicate: navbarSearchMode)
        }
    }
    
    public var tabBarIcon: UIImage? {
        return UIImage(named: "Content TabBar Icon")
    }
    
    public var tabBarTitle: String {
        return "Content"
    }
    
    private var segmentedControllMode: SegmentedController = .latest {
        didSet {
            updateFilteredData()
        }
    }
    
    private var tabsPageControllMode: TabsPageController = .addons {
        didSet {
            if tabsPageControllMode != oldValue {
                pageModel = setUpPageModel()
                segmentedControllMode = .latest
                updatePageControllerUI()
                setupFilterView()
            }
        }
    }
    
    private func setupFilterView(selectedIndex: Int = 0) {
        let setFilterCategory: Set<String> = Set(pageModel.map { $0.filterCategory })
        
        var buttons: [ContentFilterModel] = [
            ContentFilterModel(label: "All", filter: .latest),
            ContentFilterModel(label: "Favorite \(tabsPageControllMode.name)", filter: .popular)
        ]
        
        let sortedCategory = setFilterCategory.sorted()
        guard let firstCategory = sortedCategory.first else { return }
        self.lockedCategoryName = firstCategory
        
        buttons.append(contentsOf: sortedCategory.map({ ContentFilterModel(label: $0, filter: .filter($0), isLocked: !purchIsValid &&  ($0 == firstCategory)) }))
        
        contentFilterView.updateButtons(newButtons: buttons, selectedIndex: selectedIndex)
    }
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCollectionView()
        configureView()
        setupViews()
        setupSearchBar()
        setupAppearance()
        tabsPageControllMode = .skins
        IAPManager.shared.contentProductDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        validateSub()
        updateData()
        registerForKeyboardNotifications()
//        flushSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    deinit {
        skinNotifictionToken?.invalidate()
        mapsNotifictionToken?.invalidate()
        addonNotifictionToken?.invalidate()
    }
    
    private func setupRealmObserver() {
        skinNotifictionToken = RealmServiceProviding.shared.getSkinRealmObservable().observe { [weak self] (changes) in
            guard let self else { return }
            switch changes {
            case .update(_, _, let insertions, _):
                guard insertions.count != 0 else { return }
                print("SKIN OBSERVERS ACTION")
                self.updateDataSourceIfNeeded()
            case .initial, .error: break
            }
        }
        
        
        mapsNotifictionToken = RealmServiceProviding.shared.getMapsRealmObservable().observe { [weak self] (changes) in
            guard let self else { return }
            switch changes {
            case .update(_, _, let insertions, _):
                guard insertions.count != 0 else { return }
                self.updateDataSourceIfNeeded()
            case .initial, .error: break
            }
        }
        
        addonNotifictionToken = RealmServiceProviding.shared.getAddonRealmObservable().observe { [weak self] (changes) in
            guard let self else { return }
            switch changes {
            case .update(_, _, let insertions, _):
                guard insertions.count != 0 else { return }
                self.updateDataSourceIfNeeded()
            case .initial, .error: break
            }
        }
    }
    
    private func updateDataSourceIfNeeded() {
        guard pageModel.count != setUpPageModel().count else { return }
        pageModel = setUpPageModel()
        updateFilteredData()
        
        if contentFilterView.viewModel.buttons.count < 2 {
            setupFilterView()
        }
    }
    
    func validateSub() {
        if let localPurchIsValid = IAPManager.shared.contentSubIsVaild {
            updatePurchaseStatus(isPurchased: localPurchIsValid, isAfterSubscription: isShowedSubsription)
            isShowedSubsription = false
        } else {
            IAPManager.shared.validateSubscriptions(productIdentifiers: [Configurations.unlockContentSubscriptionID]) { [weak self] results in
    //            Vaildate Content
                guard let self else { return }
                if let value = results[Configurations.unlockContentSubscriptionID] {
                    self.updatePurchaseStatus(isPurchased: value)
                } else {
                    self.updatePurchaseStatus(isPurchased: self.isShowedSubsription)
                }
                IAPManager.shared.contentSubIsVaild = self.purchIsValid
                self.isShowedSubsription = false
            }
        }

    }
    
    private func updateData() {
        pageModel = setUpPageModel()
        
        updateFilteredData(false)
    }
    
    
    private func updateFilteredData(_ isScrollToTopContent: Bool = true) {
        updateFilteredData(searchText: searchBarView.searchTextField.text, isScrollToTopContent: isScrollToTopContent)
    }
    
    private func updateFilteredData(searchText: String?, isScrollToTopContent: Bool = true) {
        switch segmentedControllMode {
        case .latest:
            filteredPageModel = pageModel
            if navbarSearchMode, let searchText, !searchText.isEmpty {
                filteredPageModel = filteredPageModel.filter({ $0.name.containsCaseInsesetive(searchText)})
            }
        case .popular:
            filteredPageModel = pageModel.filter({ $0.isFavorite == true })
            if navbarSearchMode, let searchText, !searchText.isEmpty {
                filteredPageModel = filteredPageModel.filter({ $0.name.containsCaseInsesetive(searchText)})
            }
        case .filter(let name):
            setUpFilter(name: name)
        }
        
        updateUI(isScrollToTop: isScrollToTopContent)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard view.window != nil else {
            // skip, view is disappeared
            return
        }
        
        //Scroll to current Item after the orientation change. Sometimes the current item is not centered.
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.contentCollectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    // MARK: - Setup Methods
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

    
    private func setUpFilter(name: String) {
        let selectedFilterNames = [name]
        
        filteredPageModel = pageModel.compactMap { pageMode in
            if selectedFilterNames.contains(pageMode.filterCategory) {
                if navbarSearchMode, let searchText = searchBarView.searchTextField.text, !searchText.isEmpty {
                    return pageMode.name.containsCaseInsesetive(searchText) ? pageMode : nil
                } else {
                    return pageMode
                }
            } else {
                return nil
            }
        }
        contentCollectionView.reloadData()
    }
    
    private var cellId: String {
        String(describing: ContentCollectionViewCell.self)
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        contentCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }
    
    private func setupAppearance() {
        sortButtonsContainerView.roundCorners(25)
        
        for view in roundedViewContainers {
            view.roundCorners(25)
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
    
    private func setupViews() {
        let responderButtons = createResponderButtons(for: [skinsButtonRoundedView, addonsButtonRoundedView, mapsButtonRoundedView])
        
        for (index, button) in responderButtons.enumerated() {
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            view.addSubview(button)
            setupConstraints(for: button, matching: roundedViewContainers[index])
        }
        
        setupContentFilter()
    }
    
    func applyContent(filter:  ContentFilter) {
        
        switch filter {
        case .latest:
            segmentedControllMode = .latest
        case .popular:
            segmentedControllMode = .popular
        case .filter(let name):
            if purchIsValid || (self.lockedCategoryName != name) {
                segmentedControllMode = .filter(name)
                setUpFilter(name: name)
            } else {
                segmentedControllMode = .latest
                setupFilterView()

                let nextVC = PremiumMainController()
                nextVC.productBuy = .unlockContentProduct
                navigationController?.pushViewController(nextVC, animated: true)
                isShowedSubsription = true
            }
        }
        
    }
    
    private func setupContentFilter() {
        // Create the SwiftUI view model
        let contentFilterViewModel = ContentFilterViewModel(buttons: [
            ContentFilterModel(label: "", filter: .latest),
        ]) { [weak self] filter in
            self?.flushSearch()
            self?.applyContent(filter: filter)
            
        }
        
        // Create the SwiftUI view
        contentFilterView = ContentFilterView(viewModel: contentFilterViewModel)
        
        // Create a UIHostingController with the SwiftUI view
        let hostingController = UIHostingController(rootView: contentFilterView)
        hostingController.view.backgroundColor = .clear
        
        // Add as a child of the current view controller
        addChild(hostingController)
        
        // Add the SwiftUI view to the view controller view hierarchy
        sortButtonsContainerView.addSubview(hostingController.view)
        
        // Set constraints to define the SwiftUI view's layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: sortButtonsContainerView.leadingAnchor, constant: 2),
            hostingController.view.trailingAnchor.constraint(equalTo: sortButtonsContainerView.trailingAnchor, constant: -2),
            hostingController.view.topAnchor.constraint(equalTo: sortButtonsContainerView.topAnchor, constant: 2),
            hostingController.view.bottomAnchor.constraint(equalTo: sortButtonsContainerView.bottomAnchor, constant: -2)
        ])
        
        // Notify the hosting controller that it has moved to the parent view controller
        hostingController.didMove(toParent: self)
    }
    
    private func createResponderButtons(for views: [UIView]) -> [UIButton] {
        return views.map { view in
            let button = UIButton()
            button.backgroundColor = .clear
            return button
        }
    }
    
    private func setupConstraints(for button: UIButton, matching view: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBarView.buttonTapAction = { [weak self] in
            self?.flushSearch()
        }
        searchBarView.onTextChanged = { [weak self] searchText in
            self?.updateFilteredData(searchText: searchText, isScrollToTopContent: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.updateSearchViewIfNeeed()
                self?.suggestionsTableView?.reloadData()
            }
        }
        
        searchBarView.onStartSearch = { [weak self] in
            guard let self else {return}
            self.showSuggestionsTableView()
        }
        
        searchBarView.onEndSearch = { [weak self] in
            guard let self else {return}
            self.removeSuggestionsTableView()
        }
    }
    
    
    //MARK: UPD Methods
    
    private func flushSearch() {
        navbarSearchMode = false
        searchBarView.searchTextField.resignFirstResponder()
        searchBarView.searchTextField.text = nil
        updateFilteredData()
    }
    
    private func updatePageControllerUI() {
        switch tabsPageControllMode {
        case .skins:
            updateTabUI(selected: skinsButtonRoundedView, deselected: [addonsButtonRoundedView, mapsButtonRoundedView])
            updateLabelColors(selected: skinsPageControllerLabel, deselected: [addonsPageControllerLabel, mapsPageControllerLabel])
            headerLabel.text = "SKINS"
        case .addons:
            updateTabUI(selected: addonsButtonRoundedView, deselected: [skinsButtonRoundedView, mapsButtonRoundedView])
            updateLabelColors(selected: addonsPageControllerLabel, deselected: [skinsPageControllerLabel, mapsPageControllerLabel])
            headerLabel.text = "ADDONS"
        case .maps:
            updateTabUI(selected: mapsButtonRoundedView, deselected: [skinsButtonRoundedView, addonsButtonRoundedView])
            updateLabelColors(selected: mapsPageControllerLabel, deselected: [skinsPageControllerLabel, addonsPageControllerLabel])
            headerLabel.text = "MAPS"
        }
        
        contentCollectionView.reloadData()
    }
    
    private func updateTabUI(selected: UIView, deselected: [UIView]) {
        selected.backgroundColor = UIColor(named: "EerieBlackColor")
        selected.layer.cornerRadius = 25
        selected.layer.borderWidth = 4
        selected.layer.borderColor = UIColor(red: 0.97, green: 0.81, blue: 0.38, alpha: 1).cgColor
        deselected.forEach { view in
            view.backgroundColor = UIColor(named: "YellowSelectiveColor")
        }
    }
    
    private func updateLabelColors(selected: UILabel, deselected: [UILabel]) {
        selected.textColor = UIColor.white.withAlphaComponent(1)
        deselected.forEach { label in
            label.textColor = UIColor.black.withAlphaComponent(1)
        }
    }
    
    private func updateUI(isScrollToTop: Bool = true) {
        if isScrollToTop {
            scrollTop()
        }
        contentCollectionView.reloadData()
    }
    
    private func scrollTop() {
        let itemCount = contentCollectionView.numberOfItems(inSection: 0)
        
        if itemCount > 0 {
            let indexPath = IndexPath(item: 0, section: 0) // Assuming you want to scroll to the first item in the first section
            contentCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
//    private func updateSegmentedControlUI(selected: UIButton, deselected: UIButton) {
//        selected.backgroundColor = UIColor(named: "darkGreenBackground")
//        selected.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
//        selected.layer.borderWidth = 1.0
//        selected.setTitleColor(.white, for: .normal)
//        
//        deselected.backgroundColor = UIColor(named: "lightGreenBachgroundColor")
//        deselected.layer.borderColor = UIColor.clear.cgColor
//        deselected.layer.borderWidth = 0
//        deselected.setTitleColor(.lightGray, for: .normal)
//    }
    
    @IBAction private func onNavBarSearchButtonTapped(_ sender: UIButton) {
        navbarSearchMode.toggle()
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        guard let selectedTab = TabsPageController(rawValue: sender.tag) else { return }
        flushSearch()
        tabsPageControllMode = selectedTab
    }
    
    @IBAction func settingsBtnTapped(_ sender: UIButton) {
        let nextVC = SettingsViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func configureView() {
        controlSwitcher.segments = LabelSegment.segments(withTitles: ["Skins", "Maps", "Addons"],
                                                         normalFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                         normalTextColor: UIColor(named: "EerieBlackColor"),
                                                         selectedFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                         selectedTextColor: UIColor(named: "BeigeColor"))
    }
    
    @IBAction func segmentControlChangeAction(_ sender: BetterSegmentedControl) {
        switch sender.index {
        case 0:
            self.tabsPageControllMode = .skins
        case 1:
            self.tabsPageControllMode = .maps
        case 2:
            self.tabsPageControllMode = .addons
        default:
            break
        }
    }
}

extension ContentTabViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contentViewController = ContentViewController(model: filteredPageModel[indexPath.item], mode: tabsPageControllMode )
        presentFullScreenViewController(contentViewController)
    }
}

extension ContentTabViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPageModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ContentCollectionViewCell
        
        var cellModel: TabPagesCollectionCellModel
        cellModel = filteredPageModel[indexPath.item]
        
        if cellModel.imageData == nil {
            let mode = tabsPageControllMode
            let imageID = cellModel.id
            
            cell.configure(model: cellModel, queue: dropboxQueue) { [weak self] data in
                if let data, let me = self, me.filteredPageModel.count > indexPath.item, me.filteredPageModel[indexPath.item].id == imageID {
                    me.filteredPageModel[indexPath.item].imageData = data
                    if let idx = me.pageModel.firstIndex(where: {$0.id == me.filteredPageModel[indexPath.item].id}) {
                        me.pageModel[idx].imageData = data
                    }
                    
                    // save to realm
                    DispatchQueue.main.async {
                        switch mode {
                        case .skins:
                            RealmServiceProviding.shared.loadSkinImage(id: imageID, skinImageData: data)
                        case .addons:
                            RealmServiceProviding.shared.loadAddonImage(id: imageID, addonImageData: data)
                        case .maps:
                            RealmServiceProviding.shared.loadMapImage(id: imageID, mapImageData: data)
                        }
                    }
                }
            }
        } else {
            // show image from realm
            if let image = cellModel.imageData {
                cell.contentImageView.image = UIImage(data: image)
            } else {
                // show image from realm if realm == nil
                cell.contentImageView.image = UIImage()
                AppDelegate.log(cellModel.name)
                AppDelegate.log(cellModel.imageData as Any)
            }
        }
        
        cell.headerLabel.text = cellModel.name
        
        return cell
    }
}

// MARK: – UICollectionViewDelegateFlowLayout
extension ContentTabViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width / 2 - 5
        let cellHeight = cellWidth * 1.15
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}


//MARK: KeyboardStateDelegate
extension ContentTabViewController: KeyboardStateProtocol {
    func keyboardShows(height: CGFloat) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        contentCollectionView.contentInset = insets
        view.layoutIfNeeded()
    }
    
    func keyboardHides() {
        contentCollectionView.contentInset = .zero
        view.layoutIfNeeded()
    }
}

// MARK: – ContentTabViewController
extension ContentTabViewController: UITableViewDelegate, UITableViewDataSource {
    
    var tableViewContainerHeight: CGFloat {
        return searchViewHeightWith(itemsCount: min(numberOfRowsInTableView, 4))
    }
    
    private func searchViewHeightWith(itemsCount: Int, rowHeight: CGFloat = 44) -> CGFloat {
        rowHeight * CGFloat(itemsCount) + searchBarView.frame.size.height
    }
    
    func showSuggestionsTableView() {
        if tableViewContainer == nil {
            let y: CGFloat = navigationBarContainerView.frame.height - 5
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
            
            tableViewContainer?.backgroundColor = UIColor(named: "YellowSelectiveColor")

            // corners
            tableViewContainer?.layer.borderWidth = 1
            tableViewContainer?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
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
    
    private var numberOfRowsInTableView: Int {
        if let searchText = searchBarView.searchTextField.text, searchText.isEmpty {
            return 0
        }
        return filteredPageModel.count
    }

    // MARK: – UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInTableView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionCell.identifier) as! SearchSuggestionCell
        if filteredPageModel.count > indexPath.row {
            cell.titleLabel.text = filteredPageModel[indexPath.row].name
            cell.titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
            cell.titleLabel.textColor = UIColor(named: "EerieBlackColor")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = filteredPageModel[indexPath.row].name
        searchBarView.setSearchBarText(selectedText)
        searchBarView.endEditing(true)
    }
}

extension ContentTabViewController: IAPManagerContentProtocol{
    func contnetDidUnlocked() {
        // update UI
        if let _ = navigationController?.viewControllers.last as? PremiumMainController {
            navigationController?.popViewController(animated: true)
        }
    }
}
