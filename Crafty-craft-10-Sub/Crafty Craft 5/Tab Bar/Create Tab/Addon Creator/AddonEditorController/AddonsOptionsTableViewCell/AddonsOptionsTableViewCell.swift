import UIKit

enum CellState {
    case switchable
    case textable
    case statictext
}

protocol ModPropertiesChangeable: AnyObject {
    func didToggleSwitch(sender: UISwitch)
    func textFieldChanged(value: String, cellName: String, sender: UITextField)
}

class AddonsOptionsTableViewCell: UITableViewCell {

    //MARK: Properties
    
    var propModel: AddonPropertiable?
    
    var cellState: CellState = .switchable
    weak var delegate: ModPropertiesChangeable?
    
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labVal: UILabel!
    
    @IBOutlet weak var mainContainer: UIView!
    //MARK: LifeCucle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        switcher.backgroundColor = UIColor(named: "PopularGrayColor")
        switcher.layer.cornerRadius = switcher.bounds.height / 2
        switcher.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        self.backgroundColor = .clear
        
        setupTextFiled()
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        
        delegate?.didToggleSwitch(sender: sender)
      }

    
    //MARK: SetUp

    private func setupTextFiled() {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 17
        textField.backgroundColor = UIColor(named: "BeigeColor")
    }
    
    private func setuphelper() {
        switch cellState {

        case .switchable:
            labVal.isHidden = true
            textField.isHidden = true
            switcher.isHidden = false
            

        case .textable:
            labVal.isHidden = true
            textField.isHidden = false
            switcher.isHidden = true

        case .statictext:
            labVal.isHidden = false
            textField.isHidden = true
            switcher.isHidden = true
        }
    }
    
    func cellConfigure(propModel: AddonPropertiable) {
        switch propModel {

        case let switchProperty as SwitchProperty:
            self.cellState = .switchable
            switcher.setOn(switchProperty.switchState, animated: false)
            nameLabel.text = switchProperty.switchName

        case let dynamicTextProperty as DynamicFloatProperty:
            self.cellState = .textable
            self.textField.text = String(dynamicTextProperty.textFieldValue)
            self.nameLabel.text = dynamicTextProperty.textFieldName
            
        case let dynamicTextProperty as DynamicIntProperty:
            self.cellState = .textable
            self.textField.text = String(dynamicTextProperty.textFieldValue)
            self.nameLabel.text = dynamicTextProperty.textFieldName
            
        case let staticTextProperty as StaticTextProperty:
            self.cellState = .statictext
            nameLabel.text = staticTextProperty.labName
            labVal.text = staticTextProperty.labValue

        default:
            // `propModel` is not an instance of any of the above types
            AppDelegate.log("Unknown type")
        }
        
        
        setuphelper()
    }

}

extension AddonsOptionsTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let outputText = textField.text else { return }
        delegate?.textFieldChanged(value: outputText, cellName: nameLabel.text!, sender: textField)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
