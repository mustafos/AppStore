//
//  OuterTableViewCell.swift
//  ExampleApp
//
//  Created by Максим Складанюк on 11.07.2023.
//

import UIKit
import PinLayout

class OuterTableViewCell: UITableViewCell, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    let innerTableView = UITableView()
    var isExpanded = false // Track the expand/collapse state
    let titleTextLabel = UILabel() // Add a text label
    let switchControl = UISwitch()
    var completion: ((Bool) -> ())?
    var dataSource: [String: Any]?
    var expandedHeight: CGFloat? = 0.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(innerTableView)
        innerTableView.pin.top(to: titleTextLabel.edge.bottom).left().right().bottom().marginTop(8) // Pin innerTableView to the bottom of titleTextLabel with margin
        innerTableView.delegate = self
        innerTableView.dataSource = self
        
        innerTableView.register(CustomTableViewCellWithText.self, forCellReuseIdentifier: "CustomTableViewCellWithText")
        contentView.addSubview(titleTextLabel) 
        contentView.roundCorners(10)
    }
    
    func configure(boolean: Bool, dataSource: [String: Any]?) {
        self.dataSource = (dataSource?[(dataSource?.keys.first)!])! as? [String: Any]
        titleTextLabel.textColor = .white
        innerTableView.isHidden = true
        switchControl.setOn(boolean, animated: true)// Pin the text label to the top-left corner with desired margins
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.backgroundColor = UIColor(named: "PopularGrayColor")
        switchControl.roundCorners(.allCorners, radius: switchControl.bounds.height / 2)
        switchControl.addTarget(self, action: #selector(valueChangedSwitcher), for: .valueChanged)
        contentView.addSubview(switchControl)
        
        if self.dataSource?.values.count == 0 {
            innerTableView.isHidden = true
        } else {
            innerTableView.isHidden = false
        }
        layoutSubviews()
    }

    func layout() {
        switchControl.pin.right(16).top(8).sizeToFit()
        innerTableView.pin.left().right()
        titleTextLabel.pin.vCenter(to: switchControl.edge.vCenter).left().marginLeft(8).sizeToFit() 
        innerTableView.reloadData()
    }
    
    @objc func valueChangedSwitcher() {
        completion?(switchControl.isOn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setExpanded(_ expanded: Bool) {
        isExpanded = expanded
        innerTableView.isHidden = !expanded
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        innerTableView.reloadData() // Reload the innerTableView to update its content
        
        // Calculate the height based on the content size of innerTableView
        let contentSize = innerTableView.contentSize
        let expandedHeight = contentSize.height + titleTextLabel.frame.height + 16 // Add extra space for titleTextLabel and margins
        AppDelegate.log(contentSize, expandedHeight)
        if self.dataSource?.values.count == 0 {
            self.expandedHeight = 54.0
        } else {
            self.expandedHeight = expandedHeight
        }
        // Update the height constraint of innerTableView
        innerTableView.pin.height(expandedHeight)
        layout()
    }
    
//    override func prepareForReuse() {
//        innerTableView.isHidden = true
//        self.dataSource = [:]
//        self.layoutSubviews()
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCellWithText", for: indexPath) as! CustomTableViewCellWithText
        if let keys = self.dataSource?.keys {
            let stringArray = Array(keys.map { String($0) })
            AppDelegate.log(stringArray)
            let str = stringArray[indexPath.row]
            cell.titleLabel.text = stringArray[indexPath.row]
            cell.valueTextField.text = "\(self.dataSource?[str] ?? "")" // Set the initial value or assign the desired value
        }
        // Set the text field's delegate and handle value changes
        cell.valueTextField.delegate = self
        cell.valueTextField.tag = indexPath.row // Assign a unique tag to identify the text field
        return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of cells in the outer table view
        return self.dataSource?.count ?? 0
    }
}
