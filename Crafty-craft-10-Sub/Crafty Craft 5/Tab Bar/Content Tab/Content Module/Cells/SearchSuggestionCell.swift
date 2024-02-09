//
//  SearchSuggestionCell.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 24.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class SearchSuggestionCell: UITableViewCell {
    static let identifier = "SearchSuggestionCell"
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
