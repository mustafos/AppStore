//
//  TabBarViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//
import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - Private properties -
    private let networkingMonitor = NetworkStatusMonitor.shared
    
    private let isIpad = Device.iPad
    
    private let createTab = CustomTabBarItem(
        index: 0,
        icon: TabViewControllerFactory().tabBarIcon?.withTintColor(.black, renderingMode: .alwaysOriginal),
        selectedIcon: TabViewControllerFactory().tabBarSelectedIcon?.withRenderingMode(.alwaysOriginal),
        viewController: TabViewControllerFactory())
    
    private let contentTab = CustomTabBarItem(
        index: 1,
        icon: ContentTabViewController().tabBarIcon?.withTintColor(.black, renderingMode: .alwaysOriginal),
        selectedIcon: ContentTabViewController().tabBarSelectedIcon?.withRenderingMode(.alwaysOriginal),
        viewController: ContentTabViewController())
    
    private let seedsTab = CustomTabBarItem(
        index: 2,
        icon: SeedTabViewController().tabBarIcon?.withTintColor(.black, renderingMode: .alwaysOriginal),
        selectedIcon: SeedTabViewController().tabBarSelectedIcon?.withRenderingMode(.alwaysOriginal),
        viewController: SeedTabViewController())
    
    private let serverTab = CustomTabBarItem(
        index: 3,
        icon: ServersTabViewController().tabBarIcon?.withTintColor(.black, renderingMode: .alwaysOriginal),
        selectedIcon: ServersTabViewController().tabBarSelectedIcon?.withRenderingMode(.alwaysOriginal),
        viewController: ServersTabViewController())
    
    private lazy var tabBarTabs: [CustomTabBarItem] = [createTab, contentTab, seedsTab, serverTab]
    
    private var customTabBar: CustomTabBar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        setupConstraints()
        setupProperties()
        setupManagers()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !networkingMonitor.isNetworkAvailable {
            showMess()
        }
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Methods -
    
    private func setupCustomTabBar() {
        self.customTabBar = CustomTabBar(tabBarTabs: tabBarTabs, onTabSelected: { [weak self] index in
            self?.selectTabWith(index: index)
        })
    }
    
    private func setupConstraints() {
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        if isIpad {
            NSLayoutConstraint.activate([
                customTabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                customTabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18),
                customTabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                customTabBar.heightAnchor.constraint(equalToConstant: 76)
            ])
        } else {
            NSLayoutConstraint.activate([
                customTabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -21),
                customTabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                customTabBar.heightAnchor.constraint(equalToConstant: 76)
            ])
        }
    }
    
    private func setupProperties() {
        tabBar.isHidden = true
        customTabBar.addShadow()
        
        self.selectedIndex = 0
        let controllers = tabBarTabs.map { item in
            return item.viewController
        }
        self.setViewControllers(controllers, animated: true)
    }
    
    private func selectTabWith(index: Int) {
        self.selectedIndex = index
    }
    
    private func setupManagers() {
        self.networkingMonitor.delegate = self
    }
}

// MARK: - NetworkStatusMonitorDelegate
extension TabBarViewController: NetworkStatusMonitorDelegate {
    func goodInnet() {}
    
    func showMess() {
        self.showNoInternetMess()
    }
}
