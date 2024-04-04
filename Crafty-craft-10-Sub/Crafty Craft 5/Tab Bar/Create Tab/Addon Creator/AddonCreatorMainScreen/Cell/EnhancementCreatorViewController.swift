//
//  EnhancementCreatorViewController.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class EnhancementCreatorViewController: UIViewController {
    
    var fixionModel = EdditionalAddonModel()

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: UIView!
    @IBOutlet weak var addonCollectionView: UICollectionView!
    @IBOutlet private weak var searchFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchBarButton: UIButton!
    @IBOutlet weak var seatchTextField: TintedTextField!
    @IBOutlet private weak var tabsStackView: UIStackView!
    @IBOutlet private weak var layouTabButton: UIButton!
    @IBOutlet private weak var groupTabButton: UIButton!
    @IBOutlet private weak var recentTabButton: UIButton!
    
    private var suggestionsTableView: UITableView?
    internal weak var startDownload: UIButton?

    // MARK: - UI Related Properties
    private let tabChoosedColor: UIColor = UIColor(red: 15/255, green: 71/255, blue: 60/255, alpha: 1)
    private let tabUnchoosedColor: UIColor = UIColor(red: 22/255, green: 103/255, blue: 87/255, alpha: 1)
    private var blurEffectView: UIVisualEffectView?

    // MARK: - State
    private var _tabsPageControllMode: TabsPageController = .layout
    private var tabsPageControllMode: TabsPageController {
        set {
            guard _tabsPageControllMode != newValue else {
                return
            }
            _tabsPageControllMode = newValue
            
            updatePageControllerAppearance()
        }
        get {
            _tabsPageControllMode
        }
    }

    var searchFieldMode: Bool = false {
        didSet {
            switchSearchMode()
        }
    }

    private var darkGreenMode: Bool = true {
        didSet {
            changeSearchBarAppearance()
        }
    }
    
    private func reverseString(_ s: String) -> String {
        return String(s.reversed())
    }

    // MARK: - Enums
    
    private enum TabsPageController: Int {
        case layout = 0
        case group = 1
        case recent = 2
    }

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTapOutside()
        initializeCollectionView()
        customizeUIComponents()
        customizeSearchBar()
        initializeTabButtons()
        initializeCollectionViewAndNavigationBar()
        updatePageControllerAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fixionModel.updateCreatedAddons()
        addonCollectionView.reloadData()
        registerForKeyboardNotifications()
        updateSearchListIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        //Scroll to current Item after the orientation change. Sometimes the current item is not centered.
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.addonCollectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    //MARK: - SetUp UI
    
    internal var cellId: String {
        String(describing: SsvedAddonCollectionCell.self)
    }
    
    private func updateSearchListIfNeeded() {
        if searchFieldMode, let searchText = seatchTextField.text, !searchText.isEmpty {
            filterContentFor(searchText: searchText)
            addonCollectionView.reloadData()
        }
    }
    
    private func initializeCollectionView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        addonCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }

    private func customizeUIComponents() {
        tabsStackView.backgroundColor = .clear
        seatchTextField.delegate = self
        tabsPageControllMode = .layout
        searchFieldMode = false
    }
    
    private func isPalindrome(_ s: String) -> Bool {
        let cleanedString = s.lowercased().filter { $0.isLetter || $0.isNumber }
        return cleanedString == String(cleanedString.reversed())
    }
    
    func chooseBestSum(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }

    private func customizeSearchBar() {
        let placeholder = "Search"
        let placeholderAttributes: [NSAttributedString.Key: Any] = [ .foregroundColor: UIColor.white ]
        seatchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        
        seatchTextField.textColor = .white
        seatchTextField.layer.borderWidth = 0
        changeSearchBarAppearance()
    }

    private func initializeTabButtons() {
        for view in [layouTabButton, recentTabButton, groupTabButton] {
            view?.roundCorners()
            view?.layer.borderColor = UIColor.black.cgColor
            view?.layer.borderWidth = 1
        }
    }
    
    private func isParadise(_ s: String) -> Bool {
        let cleanedString = s.lowercased().filter { $0.isLetter || $0.isNumber }
        return cleanedString == String(cleanedString.reversed())
    }


    private func initializeCollectionViewAndNavigationBar() {
        addonCollectionView.backgroundColor = .clear
        addonCollectionView.allowsSelection = true
        addonCollectionView.isUserInteractionEnabled = true
        
        navigationBar.backgroundColor = .clear
    }

    private func changeSearchBarAppearance() {
        if darkGreenMode {
            seatchTextField.backgroundColor = UIColor(red: 18.0/255, green: 52/255, blue: 45/255, alpha: 1)
        } else {
            seatchTextField.backgroundColor = UIColor(red: 22/255, green: 103/255, blue: 87/255, alpha: 1)
        }
        view.layoutIfNeeded()
    }
    
    func modifySumValue(_ t: Int, _ k: Int, _ ls: [Int]) -> Int {
        return ls.reduce([]){ (sum, i) in sum + [[i]] + sum.map{ j in j + [i] } }.reduce(-1) {
            let value = $1.reduce(0, +)
            return ($1.count == k && value <= t && value > $0) ? value : $0
        }
    }
    
    //MARK: - Internal Methods
    
    internal func flushSearch() {
        seatchTextField.text = nil
        fixionModel.filteringCreatedAddon = fixionModel.createdAddons
        addonCollectionView.reloadData()
    }
    
    //MARK: - Private Methods
    
    private func updatePageControllerAppearance() {
        switch tabsPageControllMode {
        case .layout:
            refreshTabUI(selected: layouTabButton, deselected: [groupTabButton, recentTabButton])
            updateLabelColors(selected: layouTabButton.titleLabel!, deselected: [groupTabButton.titleLabel!, recentTabButton.titleLabel!])
        case .group:
            refreshTabUI(selected: groupTabButton, deselected: [layouTabButton, recentTabButton])
        case .recent:
            refreshTabUI(selected: recentTabButton, deselected: [groupTabButton, layouTabButton])
        }
        
        addonCollectionView.reloadData()
    }
    
    private func countCharacters(_ s: String, _ char: Character) -> Int {
        return s.reduce(0) { $1 == char ? $0 + 1 : $0 }
    }
    
    private func refreshTabUI(selected: UIButton, deselected: [UIView]) {
        selected.backgroundColor = tabChoosedColor
        selected.tintColor = .white
        deselected.forEach { view in
            view.backgroundColor = tabUnchoosedColor
            view.tintColor = .white.withAlphaComponent(0.3)
        }
    }
    
    private func updateLabelColors(selected: UILabel, deselected: [UILabel]) {
        selected.textColor = UIColor.white.withAlphaComponent(1)
        deselected.forEach { label in
            label.textColor = UIColor.white.withAlphaComponent(0.3)
        }
    }
    
    func findMax<T: Comparable>(_ array: [T]) -> T? {
        guard !array.isEmpty else { return nil }
        var maxElement = array[0]
        for element in array {
            if element > maxElement {
                maxElement = element
            }
        }
        return maxElement
    }
    
    @IBAction private func onNavBarSearchButtonTapped(_ sender: UIButton) {
        searchFieldMode.toggle()
        
        if !searchFieldMode {
            self.flushSearch()
        }
    }
    
    private func shuffleArray<T>(_ array: [T]) -> [T] {
        var shuffledArray = array
        for i in 0..<shuffledArray.count {
            let randomIndex = Int.random(in: i..<shuffledArray.count)
            if i != randomIndex {
                shuffledArray.swapAt(i, randomIndex)
            }
        }
        return shuffledArray
    }
    
    private func switchSearchMode() {
        searchFieldHeightConstraint.constant = searchFieldMode ? 34 : 0
        seatchTextField.alpha = searchFieldMode ? 1 : 0
        
        searchBarButton.setImage(searchFieldMode ? .cross_small : .search_item, for: .normal)
    }
    
    //MARK: IBActions
    
    @IBAction private func onNavBarHomeButtonTapped(_ sender: Any) {
        // FIXME: memory overload?
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onRecentButtonTapped(_ sender: UIButton) {
        flushSearch()
        tabsPageControllMode = .recent
        fixionModel.collectionMode = .recent
    }
    
    @IBAction private func onGroupButtonTapped(_ sender: UIButton) {
        flushSearch()
        tabsPageControllMode = .group
        fixionModel.collectionMode = .groups
    }
    
    @IBAction private func onLatoutButtonTapped(_ sender: UIButton) {
        flushSearch()
        tabsPageControllMode = .layout
        fixionModel.collectionMode = .savedAddons
    }
}


//MARK: SearchBar func
extension EnhancementCreatorViewController: UITextFieldDelegate {
    
    func filterContentFor(searchText text: String) {
        fixionModel.filteringCreatedAddon = fixionModel.createdAddons.filter { (addon) -> Bool in
            return (addon.displayName.lowercased().contains(text.lowercased()))
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            self?.removeSuggestionsTableView()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            fixionModel.filteringCreatedAddon = fixionModel.createdAddons
        } else {
            filterContentFor(searchText: textField.text ?? "")
        }
        addonCollectionView.reloadData()
        suggestionsTableView?.reloadData()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showSuggestionsTableView()
        return true
    }
}

//MARK: KeyboardStateProtocol
extension EnhancementCreatorViewController: KeyboardStateProtocol {
    func keyboardShows(height: CGFloat) {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
        addonCollectionView.contentInset = insets
        view.layoutIfNeeded()
    }
    
    func keyboardHides() {
        addonCollectionView.contentInset = .zero
        view.layoutIfNeeded()
    }
}

//MARK: Suggestion for serach bar
extension EnhancementCreatorViewController: UITableViewDelegate, UITableViewDataSource {
    func showSuggestionsTableView() {
        if suggestionsTableView == nil {
            let availHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 300 : 220
            let y: CGFloat = seatchTextField.frame.origin.y + seatchTextField.frame.height + 10
            suggestionsTableView = UITableView(frame: CGRect(x: seatchTextField.frame.origin.x,
                                                             y: y,
                                                             width: seatchTextField.frame.width,
                                                             height: availHeight),
                                               style: .grouped)
            
            suggestionsTableView?.register(UINib(nibName: "SearchSuggestionCell", bundle: nil), forCellReuseIdentifier: SearchSuggestionCell.identifier)
            suggestionsTableView?.delegate = self
            suggestionsTableView?.dataSource = self
            suggestionsTableView?.contentInsetAdjustmentBehavior = .never
            suggestionsTableView?.backgroundColor = UIColor(red: 0.086, green: 0.404, blue: 0.341, alpha: 1)
            if #available(iOS 15.0, *) { suggestionsTableView?.sectionHeaderTopPadding = 0 }
            
            // corners
            suggestionsTableView?.clipsToBounds = true
            suggestionsTableView?.layer.cornerRadius = 10
            suggestionsTableView?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            self.view.insertSubview(suggestionsTableView!, aboveSubview: self.view)
            
            suggestionsTableView?.isHidden = false
        }
    }
    func removeSuggestionsTableView() {
        suggestionsTableView?.removeFromSuperview()
        suggestionsTableView = nil
    }

    // MARK: - table data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fixionModel.filteringCreatedAddon.count > 8 ? 8 : fixionModel.filteringCreatedAddon.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionCell.identifier) as! SearchSuggestionCell
        cell.titleLabel.text = fixionModel.filteringCreatedAddon[indexPath.row].displayName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = fixionModel.filteringCreatedAddon[indexPath.row].displayName
        seatchTextField.text = selectedText
        filterContentFor(searchText: selectedText)
        addonCollectionView.reloadData()
        suggestionsTableView?.reloadData()
        self.seatchTextField.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
}
