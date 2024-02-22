//
//  CellWithSwitcher.swift
//  ExampleApp
//
//  Created by Максим Складанюк on 11.07.2023.
//

import UIKit
import PinLayout

class CustomTableViewCell: UITableViewCell {
    let switchControl = UISwitch()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize the appearance of the cell
        contentView.roundCorners(10)
        
        // Set up the switch control
        switchControl.translatesAutoresizingMaskIntoConstraints = false
//        switchControl.onTintColor = Palette.greenSwitchOn
        contentView.addSubview(switchControl)
        
        // Set up the title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Perform the layout using PinLayout
        switchControl.pin.right(16).vCenter().sizeToFit()
        titleLabel.pin.left(16).vCenter().sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITextField {
    func setRightPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }
}

