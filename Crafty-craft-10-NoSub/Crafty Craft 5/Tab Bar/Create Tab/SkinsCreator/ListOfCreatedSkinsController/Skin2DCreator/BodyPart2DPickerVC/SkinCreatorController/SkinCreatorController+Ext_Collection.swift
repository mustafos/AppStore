//
//  SkinCreatorController+Ext_Collection.swift
//  Crafty Craft 5
//
//  Created by 1 on 31.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

extension SkinCreatorViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let colorsAmount = colorsManager.getColors().count

        return colorsAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = colorsCollection.dequeueReusableCell(withReuseIdentifier: "ColorCollectionCell", for: indexPath) as? ColorCollectionCell else {
            return UICollectionViewCell()
        }

        let cellColor = colorsManager.getColor(by: indexPath.item)
        let cellIsSelcted = colorsManager.isSelctedColor(index: indexPath.item)
        
        cell.configCell(bgColor: cellColor, isSelected: cellIsSelcted)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionCell

        _currentDrawingColor = colorsManager.getColor(by: indexPath.item)
        
        cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
}

extension SkinCreatorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight = colorsCollection.bounds.size.height - 8
        let cellWidth = cellHeight
        
        let size = CGSize(width: cellHeight, height: cellWidth)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Set the padding for the first cell only
        let padding: CGFloat = 10
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
    }
}

//MARK: ColorManager Delegate
extension SkinCreatorViewController: ColorAble {
    func updateCollection() {
        colorsCollection.reloadData()
    }
}
