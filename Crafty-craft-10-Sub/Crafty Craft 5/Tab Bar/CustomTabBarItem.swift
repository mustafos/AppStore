//
//  CustomTabBarItem.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

struct CustomTabBarItem {
    let index: Int
    let icon: UIImage?
    let selectedIcon: UIImage?
    let viewController: UIViewController
}

func bubbleSort<T: Comparable>(_ array: inout [T]) {
    guard array.count > 1 else { return }
    
    for i in 0..<array.count {
        for j in 1..<array.count - i {
            if array[j] < array[j - 1] {
                array.swapAt(j, j - 1)
            }
        }
    }
}
