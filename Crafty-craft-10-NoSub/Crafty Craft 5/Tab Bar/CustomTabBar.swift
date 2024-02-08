//
//  CustomTabBar.swift
//  Crafty Craft 10.2
//
//  Created by dev on 24.01.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class CustomTabBar: UIStackView {
    
    //Tab Bar Items
    private let tabBarTabs: [CustomTabBarItem]
    
    private var customTabItemViews: [CustomTabItemView] = []
    
    var onTabSelected: ((Int) -> Void)
    
    init(tabBarTabs: [CustomTabBarItem], onTabSelected: @escaping ((Int) -> Void)) {
        self.tabBarTabs = tabBarTabs
        self.onTabSelected = onTabSelected
        super.init(frame: .zero)
        
        setupTabBartabs()
        setupHierarchy()
        setupProperties()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        selectItem(index: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTabBartabs() {
        self.tabBarTabs.forEach { tabBarItem in
            customTabItemViews.append(CustomTabItemView(with: tabBarItem, callback: { index in
                self.selectItem(index: index)
            }))
        }
    }
    
    private func setupHierarchy() {
        addArrangedSubviews(customTabItemViews)
    }
    
    private func setupProperties() {
        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.alignment = .center
        
        self.backgroundColor = UIColor(named: "YellowSelectiveColor")
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.roundCorners(38)
        
        customTabItemViews.forEach { tab in
            tab.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tab.topAnchor.constraint(equalTo: topAnchor),
                tab.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            tab.clipsToBounds = true
        }
    }
    
    private func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
    
    private func selectItem(index: Int) {
        customTabItemViews.forEach { item in
            item.isSelected = item.index == index
        }
        onTabSelected(index)
    }
}
