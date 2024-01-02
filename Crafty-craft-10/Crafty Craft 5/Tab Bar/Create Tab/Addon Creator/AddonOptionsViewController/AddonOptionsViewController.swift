

import UIKit

// MARK: - AddonOptionsViewController

class AddonOptionsViewController: UIViewController {
    
    private enum Constant {
        static let listCellIdentifier = "ListTableViewCell"
        static let optionsCellIdentifier = "AddonsOptionsTableViewCell"
        static let searchItemImageName = "Search Item"
        static let saveItemImageName = "Save Item"
    }
    
    lazy var model = MainAddonCreatorModel()
    var addons: [AddonForDisplay] = []
    var categoryName: String = ""
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var tableViewToNavBarConstraint: NSLayoutConstraint!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addons = model.savedAddons.filter({$0.type == categoryName})
        setupViews()
    }
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        navigationBar.backgroundColor = .clear
        setupBackground()
        setupTableView()
    }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupTableView() {
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.backgroundColor = .clear
        
        let listNib = UINib(nibName: Constant.listCellIdentifier, bundle: nil)
        optionsTableView.register(listNib, forCellReuseIdentifier: Constant.listCellIdentifier)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension AddonOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addons.count // this should be replaced by your data count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.listCellIdentifier) as! ListTableViewCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.config(addonModel: addons[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addonModel = addons[indexPath.row]
        let covertedModel = SavedAddon(realmModel: addonModel)
        navigationController?.pushViewController(AddonEditorViewController(addonModel: covertedModel), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Replace with the desired height for your cells
    }
}
