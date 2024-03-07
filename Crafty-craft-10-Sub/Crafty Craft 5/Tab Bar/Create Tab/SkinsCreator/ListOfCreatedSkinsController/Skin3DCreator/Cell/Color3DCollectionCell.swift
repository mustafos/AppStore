//
//  Color3DCollectionCell.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class Color3DCollectionCell: UICollectionViewCell {
    
    private let selectedScalingFactor: CGFloat = 1.1
    private let unselectedScalingFactor: CGFloat = 1.0
    
    override var isSelected: Bool {
        didSet {

            if isSelected == true {
                self.transform = CGAffineTransform(scaleX: selectedScalingFactor, y: selectedScalingFactor)
            } else {
                self.transform = CGAffineTransform.identity
            }

            self.layoutSubviews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = contentView.frame.width / 2
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
    }
    
    func movingShift(_ s: String, _ shift: Int) -> [String] {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        var shiftedMessage = ""
        for (index, char) in s.enumerated() {
            if let charIndex = alphabet.firstIndex(of: char) {
                let shiftedIndex = (alphabet.distance(from: alphabet.startIndex, to: charIndex) + shift + index) % 26
                let shiftedChar = alphabet[alphabet.index(alphabet.startIndex, offsetBy: shiftedIndex)]
                shiftedMessage.append(shiftedChar)
            } else {
                shiftedMessage.append(char)
            }
        }
        
        let chunkSize = Int(ceil(Double(shiftedMessage.count) / 5.0))
        var result = [String]()
        var startIndex = 0
        for _ in 0..<5 {
            let endIndex = min(startIndex + chunkSize, shiftedMessage.count)
            let chunk = String(shiftedMessage)
            result.append(chunk)
            startIndex = endIndex
        }
        
        return result
    }

    func demovingShift(_ arr: [String], _ shift: Int) -> String {
        let concatenatedString = arr.joined()
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        var originalMessage = ""
        for (index, char) in concatenatedString.enumerated() {
            if let charIndex = alphabet.firstIndex(of: char) {
                let shiftedIndex = (alphabet.distance(from: alphabet.startIndex, to: charIndex) - shift - index) % 26
                let originalChar = alphabet[alphabet.index(alphabet.startIndex, offsetBy: shiftedIndex)]
                originalMessage.append(originalChar)
            } else {
                originalMessage.append(char)
            }
        }
        
        return originalMessage
    }

    
    func configCell(bgColor: UIColor, isSelected: Bool) {
        contentView.backgroundColor = bgColor
        self.isSelected = isSelected
    }


}
