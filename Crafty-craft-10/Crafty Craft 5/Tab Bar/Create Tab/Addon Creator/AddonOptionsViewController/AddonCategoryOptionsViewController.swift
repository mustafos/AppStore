//
//  AddonCategoryOptionsViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 22.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

enum AddonCategoryOptionsSection: Int, CaseIterable {
    case category = 0
    case items = 1
}

class AddonCategoryOptionsViewController: UIViewController {
    
    private enum Constant {
        static let listCellIdentifier = "ListTableViewCell"
        static let optionsCellIdentifier = "AddonsOptionsTableViewCell"
        static let greenBackgroundImageName = "Green Background"
        static let searchItemImageName = "Search Item"
        static let saveItemImageName = "Save Item"
    }
    
    lazy var model = MainAddonCreatorModel()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var tableViewToNavBarConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        backgroundImageView.image = UIImage(named: Constant.greenBackgroundImageName)
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

extension AddonCategoryOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        AddonCategoryOptionsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case AddonCategoryOptionsSection.category.rawValue:
            return model.categories.count
        case AddonCategoryOptionsSection.items.rawValue:
            return model.itemsAddons.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.listCellIdentifier) as! ListTableViewCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if indexPath.section == AddonCategoryOptionsSection.items.rawValue {
            cell.config(addonModel: model.itemsAddons[indexPath.row])
        } else {
            cell.configCategory(category: model.categories[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == AddonCategoryOptionsSection.items.rawValue {
            let addonModel = model.itemsAddons[indexPath.row]
            let covertedModel = SavedAddon(realmModel: addonModel)
            navigationController?.pushViewController(AddonEditorViewController(addonModel: covertedModel), animated: true)
        } else {
            let nextVC = AddonOptionsViewController()
            nextVC.categoryName = model.categories[indexPath.row].categoryName
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == AddonCategoryOptionsSection.category.rawValue ? "Groups" : "Items"
        return CategoryOptionHeaderSection(frame: .init(x: 0, y: 0, width: tableView.bounds.width, height: 28), title: title)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListTableViewCell.defaultCellHeiht // Replace with the desired height for your cells
    }
}
