//
//  SeedTabViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit
import RealmSwift

struct Seed {
    let id: String
    let imageFilePath: String
    let descrip: String
    let seedNumber: String
    let name: String
    var imageData: Data?
    
    init(id: String, imageFilePath: String, descrip: String, seedNumber: String, name: String, imageData: Data? = nil) {
        self.id = id
        self.imageFilePath = imageFilePath
        self.descrip = descrip
        self.seedNumber = seedNumber
        self.name = name
        self.imageData = imageData
    }
    
    init(_ seedSession: SeedSession) {
        self.id = seedSession.id
        self.imageFilePath = seedSession.seedImagePath
        self.descrip = seedSession.seedDescrip
        self.seedNumber = seedSession.seed
        self.name = seedSession.name
        self.imageData = seedSession.imageData
    }
}

class SeedTabViewController: UIViewController {
    
    @IBOutlet weak var navigationBarContainerView: UIView!
    @IBOutlet weak var searchBarView: SearchBarView!
    private var suggestionsTableView: UITableView?
    private var tableViewContainer: UIView?
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var seedsTableView: UITableView!
    private var emptyMessageLabel: UILabel?
    private var footerCell: UIView?
    private var navbarSearchMode: Bool = false {
        didSet {
            navBarSearchMode(predicate: navbarSearchMode)
        }
    }
    
    var seeds: [Seed] = []
    private var notifictionToken: NotificationToken?
    
    private var filteredText: String? = nil {
        didSet {
            updateDataSource()
        }
    }
    
    var dataSourceSeed: [Seed] = [] {
        didSet {
            seedsTableView.reloadData()
        }
    }
    
    
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.acme.serial")
        
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        setupSearchBar()
        
        setupDataSource()
        setupRealmObserver()
    }
    
    deinit {
        notifictionToken?.invalidate()
    }
    
    private func setupRealmObserver() {
        notifictionToken = RealmServiceProviding.shared.getSeedRealmObservable().observe { [weak self] (changes) in
            guard let self else { return }
            switch changes {
            case .update(_, _, let insertions, _):
                guard insertions.count != 0 else { return }
                self.setupDataSource()
            case .initial, .error: break
            }
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        navbarSearchMode.toggle()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let nextVC = SettingsViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func getRealmSeedWith(id: String) -> SeedRealmSession? {
        RealmServiceProviding.shared.getSeedWithID(id: id)
    }
    
    private func setupDataSource() {
        seeds = RealmServiceProviding.shared.getAllSeed().map(Seed.init)
        updateDataSource()
    }
    
    private func updateDataSource() {
        if filteredText == nil {
            dataSourceSeed = seeds
        } else {
            dataSourceSeed = seeds.filter({$0.name.containsCaseInsesetive(filteredText ?? "")})
        }
        
        if dataSourceSeed.isEmpty {
            showEmptyMessage()
        } else {
            hideEmptyMessage()
        }
        
        seedsTableView.reloadData()
    }
    
    private func showEmptyMessage() {
        if emptyMessageLabel == nil {
            emptyMessageLabel = UILabel()
            emptyMessageLabel?.text = "Nothing found in seed"
            emptyMessageLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
            emptyMessageLabel?.textColor = UIColor(named: "BeigeColor")
            emptyMessageLabel?.textAlignment = .center
            emptyMessageLabel?.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(emptyMessageLabel!)
            
            NSLayoutConstraint.activate([
                emptyMessageLabel!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyMessageLabel!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
        
        emptyMessageLabel?.isHidden = false
    }
    
    private func hideEmptyMessage() {
        emptyMessageLabel?.isHidden = true
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
    
    private func configTableView() {
        seedsTableView.register(UINib(nibName: "SeedTableViewCell", bundle: nil), forCellReuseIdentifier: SeedTableViewCell.identifier)
        seedsTableView.rowHeight = UITableView.automaticDimension
        seedsTableView.showsVerticalScrollIndicator = false
        addFooterView()
    }
    
    private func addFooterView() {
        footerCell = UIView(frame: CGRect(x: 0, y: 0, width: seedsTableView.bounds.width, height: 70))
        footerCell?.backgroundColor = UIColor.clear
        seedsTableView.tableFooterView = footerCell
    }
    
    private func setupSearchBar() {
        searchBarView.buttonTapAction = { [weak self] in
            self?.flushSearch()
        }
        searchBarView.onTextChanged = { [weak self] searchText in
            self?.filterData(with: searchText)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.updateSearchViewIfNeeed()
                self?.suggestionsTableView?.reloadData()
            }
        }
        
        searchBarView.onStartSearch = { [weak self] in
            guard let self else {return}
            self.showSuggestionsTableView()
        }
        
        searchBarView.onEndSearch = {[weak self] in
            guard let self else {return}
            self.removeSuggestionsTableView()
        }
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
    
    private func flushSearch() {
        navbarSearchMode = false
        searchBarView.searchTextField.text = nil
        filteredText = nil
    }
    
    private func filterData(with searchText: String) {
        let search: String? = !searchText.isEmpty ? searchText : nil
        filteredText = search
    }
}

extension SeedTabViewController: TabBarVersatile {
    
    var tabBarIcon: UIImage? {
        return UIImage(named: "seeds")
    }
    
    var tabBarSelectedIcon: UIImage? {
        return UIImage(named: "seedsSelect")
    }
    var tabBarTitle: String {
        return "Seeds"
    }
}

// MARK: – UITableView Extension
extension SeedTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestionsTableView {
            return numberOfRowsInTableView
        }
        return dataSourceSeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == suggestionsTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionCell.identifier) as! SearchSuggestionCell
            if dataSourceSeed.count > indexPath.row {
                cell.titleLabel.text = dataSourceSeed[indexPath.row].name
                cell.titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
                cell.titleLabel.textColor = UIColor(named: "EerieBlackColor")
            }
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SeedTableViewCell.identifier) as! SeedTableViewCell
        
        let seed = dataSourceSeed[indexPath.row]
        
        if seed.imageData == nil {
            cell.configWithOutImageData(seed: seed, queue: dropboxQueue) { [weak self] data in
                guard let data else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    guard let visibleRowsIndexPath = self.seedsTableView.indexPathsForVisibleRows, visibleRowsIndexPath.contains(indexPath) else { return }
                    self.dataSourceSeed[indexPath.row].imageData = data
                    
                    if let idx = self.seeds.firstIndex(where: {$0.id == self.dataSourceSeed[indexPath.row].id}) {
                        self.seeds[idx].imageData = data
                    }
                    RealmServiceProviding.shared.loadSeedImage(id: "\(seed.id)", seedImageData: data)
                }
            }
        } else {
            cell.configWithImageData(seed: seed)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == suggestionsTableView {
            let selectedText = dataSourceSeed[indexPath.row].name
            searchBarView.setSearchBarText(selectedText)
            searchBarView.endEditing(true)
            return
        }
        let seedModel = dataSourceSeed[indexPath.row]
        guard let realmSeedModel = getRealmSeedWith(id: seedModel.id) else { return }
        
        
        let detailsVC = SeedDetailsViewController(seed: realmSeedModel)
        self.navigationController?.pushViewController(detailsVC, animated: true)
        
        navbarSearchMode = false
        searchBarView.setSearchBarText("")
        searchBarView.endEditing(true)
    }
    
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
    
    private var numberOfRowsInTableView: Int {
        if let searchText = searchBarView.searchTextField.text, searchText.isEmpty {
            return 0
        }
        return dataSourceSeed.count
    }
}
