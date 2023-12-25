//
//  ServersTabViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 12.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit
import RealmSwift

class ServerRealmSession: Object, Identifiable {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name: String
    @Persisted var imageFilePath: String
    @Persisted var address: String
    
    @Persisted var imageData: Data?
    @Persisted var descrip: String
    @Persisted var status: String
    var statusEnum: Server.Status {
        get {
            Server.Status(rawValue: status) ?? .Online
        }
        set {
            status = newValue.rawValue
        }
    }

    convenience init(id: String, name: String, imageFilePath: String, address: String, imageData: Data?, descrip: String, status: Server.Status) {
        self.init()
        self.id = UUID().uuidString
        self.name = name
        self.imageFilePath = imageFilePath
        self.address = address
        self.descrip = descrip
        self.imageData = imageData
        statusEnum = status
    }
    
    var serverModel: Server {
        .init(id: Int(bitPattern: id),
              imageFilePath: imageFilePath,
              imageData: imageData,
              name: name,
              address: address,
              descrip: descrip,
              status: statusEnum)
    }
}


struct Server: Codable {
    enum Status: String, Codable {
        case Online
        case Offline
    }
    
    let id: Int
    let imageFilePath: String
    var imageData: Data?
    let name: String
    let address: String
    let descrip: String
    let status: Server.Status
    
    enum CodingKeys: String, CodingKey {
        case id = "kw09px2"
        case address = "cac38"
        case name = "54dbg6p5"
        case status = "1xnjs"
        case imageFilePath = "eyb28ihfli"
        case descrip = "knl57r"
    }
    
    var realmModel: ServerRealmSession {
        .init(id: "\(id)",
              name: name,
              imageFilePath: imageFilePath,
              address: address,
              imageData: imageData,
              descrip: descrip,
              status: status)
    }
}

class ServersTabViewController: UIViewController {
    
    @IBOutlet weak var navigationBarContainerView: UIView!
    @IBOutlet weak var searchBarView: SearchBarView!
    private var suggestionsTableView: UITableView?
    private var tableViewContainer: UIView?
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var serversTableView: UITableView!
    
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.acme.serial")
        
        return queue
    }()
    
    private var navbarSearchMode: Bool = false {
        didSet {
            navBarSearchMode(predicate: navbarSearchMode)
        }
    }
    
    var servers: [ServerRealmSession] = []
    private var notifictionToken: NotificationToken?
    
    private var filteredText: String? = nil {
        didSet {
            updateDataSource()
        }
    }
    
    
    var dataSourceServers: [ServerRealmSession] = [] {
        didSet {
            serversTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        setupSearchBar()
        setUpPageModel()
        setupRealmObserver()
    }
    
    deinit {
        notifictionToken?.invalidate()
    }
    
    private func setupRealmObserver() {
        notifictionToken = RealmServiceProviding.shared.getServersRealmObservable().observe { [weak self] (changes) in
            guard let self else { return }
            switch changes {
            case .update(_, _, let insertions, _):
                guard insertions.count != 0 else { return }
                self.setUpPageModel()
            case .initial, .error: break
            }
        }
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let nextVC = SettingsViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        navbarSearchMode.toggle()
    }
    private func configTableView() {
        serversTableView.register(UINib(nibName: "ServerTableViewCell", bundle: nil), forCellReuseIdentifier: ServerTableViewCell.identifier)
        serversTableView.rowHeight = UITableView.automaticDimension
        serversTableView.showsVerticalScrollIndicator = false
    }
    
    private func setUpPageModel() {
        servers =  RealmServiceProviding.shared.getAllServers()
        updateDataSource()
    }
    
    private func updateDataSource() {
        if filteredText == nil {
            dataSourceServers = servers
        } else {
            dataSourceServers = servers.filter({$0.name.containsCaseInsesetive(filteredText ?? "")})
        }
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
        
        searchBarView.onStartSearch = {[weak self] in
            guard let self else { return }
            self.showSuggestionsTableView()
        }
        
        searchBarView.onEndSearch = { [weak self] in
            guard let self else { return }
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

}

extension ServersTabViewController: TabBarConfigurable {
    var tabBarIcon: UIImage? {
        return UIImage(named: "Servers TabBar Icon")
    }

    var tabBarTitle: String {
        return "Servers"
    }
}

// MARK: – ServersTabViewController
extension ServersTabViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == suggestionsTableView {
            return numberOfRowsInTableView
        }
        return dataSourceServers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == suggestionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchSuggestionCell.identifier) as! SearchSuggestionCell
            if dataSourceServers.count > indexPath.row {
                cell.titleLabel.text = dataSourceServers[indexPath.row].name
                cell.titleLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
                cell.titleLabel.textColor = UIColor(named: "EerieBlackColor")
            }
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ServerTableViewCell.identifier) as! ServerTableViewCell
        
        let server = dataSourceServers[indexPath.row]
        
        if server.imageData == nil {
            cell.configWithOutImageData(server: server, queue: dropboxQueue) {[weak self] data in
                guard let self, let data else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    guard let visibleRowsIndexPath = self.serversTableView.indexPathsForVisibleRows, visibleRowsIndexPath.contains(indexPath) else { return }
                    RealmServiceProviding.shared.loadServerImage(id: "\(server.id)", serverImageData: data)
                }
            }
        } else {
            cell.configWithImageData(server: server)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == suggestionsTableView {
            let selectedText = dataSourceServers[indexPath.row].name
            searchBarView.setSearchBarText(selectedText)
            searchBarView.endEditing(true)
            return
        }
        let server = dataSourceServers[indexPath.row]
        let detailsVC = ServerDetailsViewController(server: server)
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
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
            tableViewContainer?.clipsToBounds = true
            tableViewContainer?.layer.cornerRadius = 30
            
            
            //TODO: – SEPARATOR DESIGN
            suggestionsTableView?.separatorStyle = .singleLine
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
        return dataSourceServers.count
    }
}
