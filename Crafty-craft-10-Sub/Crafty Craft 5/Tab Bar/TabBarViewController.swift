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
        viewController.tabBarItem = createCustomTabBarItem(unselectedImage: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        return viewController
    }()
    
    private lazy var createViewController: UIViewController = {
        let viewController = CreateTabViewController()
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        viewController.tabBarItem = createCustomTabBarItem(unselectedImage: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        return viewController
    }()
    
    private lazy var seedsViewController: UIViewController = {
        let viewController = SeedTabViewController()
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        viewController.tabBarItem = createCustomTabBarItem(unselectedImage: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        return viewController
    }()
    
    private lazy var serversViewController: UIViewController = {
        let viewController = ServersTabViewController()
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarSelectedIcon
        viewController.tabBarItem = createCustomTabBarItem(unselectedImage: unselectedImage, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
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
    private func createCustomTabBarItem(unselectedImage: UIImage?, selectedImage: UIImage?) -> UITabBarItem {
        return UITabBarItem(title: nil, image: unselectedImage, selectedImage: selectedImage)
    }
    
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
        
        tabBar.itemPositioning = .centered
        
        roundLayer.strokeColor = UIColor.black.cgColor
        roundLayer.lineWidth = 1.0
        roundLayer.fillColor = UIColor(red: 0.97, green: 0.81, blue: 0.38, alpha: 1).cgColor
        roundLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        roundLayer.shadowOpacity = 1
        roundLayer.shadowRadius = 4
        roundLayer.shadowOffset = CGSize(width: 0, height: 4)
        
        tabBar.unselectedItemTintColor = UIColor(named: "EerieBlackColor")
        
        if let items = tabBar.items {
            for (index, item) in items.enumerated() {
                if index == 0 {
                    item.imageInsets = UIEdgeInsets(top: 6, left: min(25, tabBar.bounds.width / 2 - 10), bottom: -6, right: -min(25, tabBar.bounds.width / 2 - 10))
                } else if index == 3 {
                    item.imageInsets = UIEdgeInsets(top: 6, left: -min(25, tabBar.bounds.width / 2 - 10), bottom: -6, right: min(25, tabBar.bounds.width / 2 - 10))
                } else {
                    item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                }
            }
        }
    }
    
    private func setupManagers() {
        self.networkingMonitor.delegate = self
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarViewController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        let index = self.tabBar.items?.firstIndex(of: item)
        let subView = tabBar.subviews[index!+1].subviews.first as! UIImageView
        self.performSpringAnimation(imgView: subView)
    }

    //func to perform spring animation on imageview
    private func performSpringAnimation(imgView: UIImageView) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)

            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Add your custom transition animation here
        if let items = tabBar.items, let selectedIndex = viewControllers?.firstIndex(of: viewController) {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .fade
            tabBar.layer.add(transition, forKey: nil)
            
            for (index, item) in items.enumerated() {
                if index == selectedIndex {
                    // Apply animation or customization when the selected item is changed
                }
            }
        }
    }
}

// MARK: - NetworkStatusMonitorDelegate
extension TabBarViewController: NetworkStatusMonitorDelegate {
    func goodInnet() {}
    
    func showMess() {
        self.showNoInternetMess()
    }
}
