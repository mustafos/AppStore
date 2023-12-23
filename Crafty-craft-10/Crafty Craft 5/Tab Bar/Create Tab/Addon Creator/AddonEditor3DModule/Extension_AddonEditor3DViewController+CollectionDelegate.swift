//
//  Extension_AddonEditor3DViewController+CollectionDelegate.swift
//  Crafty Craft 5
//
//  Created by 1 on 08.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Collections Delegate

extension AddonEditor3DViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let colorsAmount = vcModel?.editorAddonModel.colorManager3D.getColors().count else {
            return 0
        }

        return colorsAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = color3DCollection.dequeueReusableCell(withReuseIdentifier: "Color3DCollectionCell", for: indexPath) as? Color3DCollectionCell else {

            return UICollectionViewCell()
        }

        guard let cellColor = vcModel?.editorAddonModel.colorManager3D.getColor(by: indexPath.item),
              let cellIsSelcted = vcModel?.editorAddonModel.colorManager3D.isSelctedColor(index: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.configCell(bgColor: cellColor, isSelected: cellIsSelcted)
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? Color3DCollectionCell
        guard let currentColor = vcModel?.editorAddonModel.colorManager3D.getColor(by: indexPath.item) else { return }
        vcModel?.editorAddonModel.currentDrawingColor = currentColor
        
        cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }

}

extension AddonEditor3DViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellHeight = color3DCollection.bounds.size.height - 8
        let cellWidth = cellHeight

        let size = CGSize(width: cellHeight, height: cellWidth)

        return size
    }
    
    
}

//MARK: ColorManager Delegate

extension AddonEditor3DViewController: ColorAble3D {

    func updateCollection() {
        color3DCollection.reloadData()
    }
    
    
}
