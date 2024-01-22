//
//  CellWithTextField.swift
//  ExampleApp
//
//  Created by Максим Складанюк on 11.07.2023.
//

import UIKit
import PinLayout

class CustomTableViewCellWithText: UITableViewCell {
    let valueTextField = UITextField()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize the appearance of the cell
        selectionStyle = .none
        backgroundColor = Palette.darkGreen
        
        // Set up the value text field
        selectionStyle = .none
        backgroundColor = Palette.darkGreen
        
        contentView.backgroundColor = Palette.darkGreen
        self.backgroundColor = Palette.greenBack
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.textColor = .black
        valueTextField.keyboardType = .decimalPad // Adjust the keyboard type as needed
        valueTextField.textAlignment = .right
        valueTextField.roundCorners(4)
        valueTextField.backgroundColor = Palette.gray
        valueTextField.setRightPadding(8) // Add left padding for text
        
        contentView.addSubview(valueTextField)
        
        // Set up the title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Perform the layout using PinLayout
        titleLabel.pin.left(8).vCenter().sizeToFit()
        valueTextField.pin.right(16).width(100).vCenter().sizeToFit(.width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
