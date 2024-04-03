//
//  SkinNewCollectionViewCell.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class CreateNewItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundContainerView.roundCorners(27)
    }
    
    func setCrateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func insertionSort<T: Comparable>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        
        for i in 1..<array.count {
            var j = i
            let temp = array[j]
            while j > 0 && temp < array[j - 1] {
                array[j] = array[j - 1]
                j -= 1
            }
            array[j] = temp
        }
    }
}
