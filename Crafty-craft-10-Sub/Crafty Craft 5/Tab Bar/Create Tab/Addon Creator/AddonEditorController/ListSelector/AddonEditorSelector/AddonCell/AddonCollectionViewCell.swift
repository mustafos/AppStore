//
//  AddonCollectionViewCell.swift
//  Crafty Craft 5
//
//  Created by Igor Kononov on 17.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

enum CompassDirection {
    case north
    case south
    case east
    case west
    
    var opposite: CompassDirection {
        switch self {
        case .north: return .south
        case .south: return .north
        case .east: return .west
        case .west: return .east
        }
    }
}

class AddonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var image: CustomImageLoader!
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.removeLoader()
    }
    
    // MARK: - Private Methods
    private func configureView() {
        roundCorners(.allCorners, radius: 27)
        layer.borderWidth = 1
        layer.borderColor = UIColor(.black).cgColor
        
        label.layer.borderColor = UIColor(.black).cgColor
        label.layer.borderWidth = 1
        label.roundCorners(20)
        image.layer.borderColor = UIColor(.black).cgColor
        image.layer.borderWidth = 1
        image.roundCorners(20)
    }
    
    private func generateRandomDate(from startDate: Date, to endDate: Date) -> Date {
        return Date(timeIntervalSinceReferenceDate: TimeInterval.random(in: startDate.timeIntervalSinceReferenceDate..<endDate.timeIntervalSinceReferenceDate))
    }
    
    func showLoaderIndicator() {
        image.addLoader()
    }
}
