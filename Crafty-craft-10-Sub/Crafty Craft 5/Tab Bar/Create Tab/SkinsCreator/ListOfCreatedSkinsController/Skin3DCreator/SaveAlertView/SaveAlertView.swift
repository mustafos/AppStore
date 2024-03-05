import UIKit

class SaveAlertView: UIView {
    
    @IBOutlet var mainSaveAlertView: UIView!
        
    @IBOutlet weak var saveSkButton: UIButton!
    
    @IBOutlet weak var cancelSaveSkButton: UIButton!
    
    @IBOutlet var setSkinNameSaveTextField: UITextField!
    
    @IBOutlet var dialogTextLabel: UILabel!
    
    weak var delegate: SkinSavebleDialogDelegate?
    
    var withExit = false
    
    var withoutTextField = false
    
    var nameCharachterLimit = 15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        saveAlertViewNibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        saveAlertViewNibSetup()
    }
    
    
    private func saveAlertViewNibSetup() {
        mainSaveAlertView = loadSaveAlertViewFromNib()
        mainSaveAlertView.frame = bounds
        mainSaveAlertView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainSaveAlertView.translatesAutoresizingMaskIntoConstraints = true
        setSkinNameSaveTextField.layer.borderColor = UIColor.black.cgColor
        setSkinNameSaveTextField.layer.borderWidth = 1
        setSkinNameSaveTextField.delegate = self
        
        let tapGestureOnBlureView = UITapGestureRecognizer(target: self, action: #selector(tapOnBlureViewPressed(_:)))
        mainSaveAlertView.addGestureRecognizer(tapGestureOnBlureView)
        
        addSubview(mainSaveAlertView)
    }
    
    @IBAction func saveSkButtonPressed(_ sender: UIButton) {

        if withoutTextField {
            if let name = setSkinNameSaveTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.isEmpty == false {
                delegate?.saveSkin(with: name, withExit: withExit)
            } else if let name = setSkinNameSaveTextField.placeholder, name.isEmpty == false {
                delegate?.saveSkin(with: name, withExit: withExit)
            }
        } else {
            if setSkinNameSaveTextField.isHidden {
                setSkinNameSaveTextField.isHidden = false
                dialogTextLabel.text = "Select a name for your skin."
            } else {
                guard let nameSkin = setSkinNameSaveTextField.text else {
                    showInputInvalidAllert(title: "Invalid Name", message: "Please provide another name")
                    return
                }

                if nameSkin.isEmpty {
                    guard let placeholder = setSkinNameSaveTextField.placeholder  else {
                        showInputInvalidAllert(title: "Invalid Name", message: "Please provide another name")
                        return
                    }
                    delegate?.saveSkin(with: placeholder, withExit: withExit)
                } else if !isInputValid(nameSkin) {
                    showInputInvalidAllert(title: "Warning!", message: "Invalid name, please provide another name")
                } else {
                    
                    delegate?.saveSkin(with: nameSkin, withExit: withExit)
                }
            }
        }
    }
    
    @IBAction func cancelSaveSkButtonPressed(_ sender: UIButton) {
        delegate?.cancelSave(withExit: withExit)
    }
    
    private func loadSaveAlertViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}

extension SaveAlertView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 15 characters
        guard updatedText.count <= nameCharachterLimit else {
            showInputInvalidAllert(title: "Name Too Long", message: "The name must be \(nameCharachterLimit) characters or fewer.")
            return false
        }

        // name can't starts from whitespace
        guard updatedText.hasPrefix(" ") == false else {
            return false
        }

        // If the updated text is empty, it means we are deleting characters, so allow it.
        if updatedText.isEmpty {
            return true
        }

        var characterSet = CharacterSet.alphanumerics
        // only need the decimal character added to the character set
        characterSet.insert(charactersIn: "._- ")

        return updatedText.rangeOfCharacter(from: characterSet) != nil
    }


}

extension SaveAlertView {
    @objc func tapOnBlureViewPressed(_ sender: UITapGestureRecognizer) {
        if setSkinNameSaveTextField.isFirstResponder {
            setSkinNameSaveTextField.resignFirstResponder()
        }
    }
}

extension SaveAlertView {

//Checks if user provided allowed skin name
    func isInputValid(_ input: String) -> Bool {
        
        // Remove leading and trailing whitespaces and newlines
        let cleanedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the cleaned input is not empty (contains at least one visible character)
        return !cleanedInput.isEmpty
    }
    
    func showInputInvalidAllert(title: String, message: String) {
        let warningAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let warningAlertControllerOkAction = UIAlertAction(title: "Ok", style: .default)
        warningAlertController.addAction(warningAlertControllerOkAction)
        delegate?.warningNameAlert(presentAlert: warningAlertController)
    }
}
