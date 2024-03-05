
import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var filterOptionName: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
    
    @IBOutlet weak var selectedCheckBoxImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
