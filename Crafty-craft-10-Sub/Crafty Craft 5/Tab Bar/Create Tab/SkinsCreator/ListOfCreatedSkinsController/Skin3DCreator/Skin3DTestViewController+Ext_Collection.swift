//
//  Skin3DTestViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

//MARK: Colors Collection
extension ThreeDSkinTestViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let colorsAmount = colorManager3D.getColors().count

        return colorsAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = color3DCollection.dequeueReusableCell(withReuseIdentifier: "Color3DCollectionCell", for: indexPath) as? Color3DCollectionCell else {
            return UICollectionViewCell()
        }

        let cellColor = colorManager3D.getColor(by: indexPath.item)
        let cellIsSelcted = colorManager3D.isSelctedColor(index: indexPath.item)
        
        cell.configCell(bgColor: cellColor, isSelected: cellIsSelcted)
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? Color3DCollectionCell

        editorSkinModel.currentDrawingColor = colorManager3D.getColor(by: indexPath.item)
        
        cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

    }
    

}

extension ThreeDSkinTestViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellHeight = color3DCollection.bounds.size.height - 8
        let cellWidth = cellHeight

        let size = CGSize(width: cellHeight, height: cellWidth)

        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Set the padding for the first cell only
        let padding: CGFloat = 5
        return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
    }
}

//MARK: ColorManager Delegate
extension ThreeDSkinTestViewController: ColorAble3D {
    func updateCollection() {
        color3DCollection.reloadData()
    }
}
