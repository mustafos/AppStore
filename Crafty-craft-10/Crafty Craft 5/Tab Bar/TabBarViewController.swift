//
//  TabBarViewController.swift
//  Crafty Craft 10
//
//  Created by Mustafa Bekirov on 28.12.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    // MARK: - Private properties -
    private let isIpad = Device.iPad
    
    private let networkingMonitor = NetworkStatusMonitor.shared
    
    private var tabBarTitleHorizontalOffset: CGFloat { isIpad ? 80 : 40 }
    
    private lazy var contentViewController: UIViewController = {
        let viewController = ContentTabViewController()
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "content", size: CGSize(width: 122, height: 52))
            unselectedImage = UIImage.resizedImage(named: "content", size: CGSize(width: 24, height: 24))
        }
        viewController.tabBarItem = UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        
        return viewController
    }()
    
    private lazy var createViewController: UIViewController = {
        let viewController = CreateTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "create", size: CGSize(width: 122, height: 52))
            unselectedImage = UIImage.resizedImage(named: "create", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        
        return viewController
    }()
    
    private lazy var seedsViewController: UIViewController = {
        let viewController = SeedTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "seeds", size: CGSize(width: 122, height: 52))
            unselectedImage = UIImage.resizedImage(named: "seeds", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        
        return viewController
    }()
    
    private lazy var serversViewController: UIViewController = {
        let viewController = ServersTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "servers", size: CGSize(width: 122, height: 52))
            unselectedImage = UIImage.resizedImage(named: "servers", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        
        return viewController
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setTabBarAppearance()
        
        setupManagers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !networkingMonitor.isNetworkAvailable {
            showMess()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Methods -
    private func setTabBarAppearance() {
        viewControllers = [createViewController, contentViewController, seedsViewController, serversViewController]
        
        let positionOnX: CGFloat = 10
        let positionOnY: CGFloat = 14
        let width = tabBar.bounds.width - positionOnX * 2
        let height = tabBar.bounds.height + positionOnY * 2
        
        let roundLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath(
            roundedRect: CGRect(
                x: positionOnX,
                y: tabBar.bounds.minY - positionOnY,
                width: width,
                height: height
            ),
            cornerRadius: height / 2
        )
        
        roundLayer.path = bezierPath.cgPath
        
        tabBar.layer.insertSublayer(roundLayer, at: 0)
        
        if let items = tabBar.items {
            for (index, item) in items.enumerated() {
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
        
        roundLayer.strokeColor = UIColor.black.cgColor
        roundLayer.lineWidth = 1.0
        roundLayer.fillColor = UIColor(red: 0.97, green: 0.81, blue: 0.38, alpha: 1).cgColor
        roundLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        roundLayer.shadowOpacity = 1
        roundLayer.shadowRadius = 4
        roundLayer.shadowOffset = CGSize(width: 0, height: 4)

        tabBar.unselectedItemTintColor = UIColor(named: "EerieBlackColor")
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
