
import UIKit

class SearchBarView: UIView, UITextFieldDelegate {
    
    var onTextChanged: ((String) -> Void)?
    var buttonTapAction: (() -> Void)?
    var onStartSearch: (() -> Void)?
    var onEndSearch: (() -> Void)?
    
    var placeholderTextColor = #colorLiteral(red: 0.657982409, green: 0.7550782561, blue: 0.7371580601, alpha: 1)
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .white
        textField.tintColor = .white
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor]
        )
        
        textField.autocorrectionType = .no
        return textField
    }()
    
    let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // configure the imageView here
        imageView.image = UIImage(named: "Search Item")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let closeCross = (UIImage(named: "close cross"))
        let coloredCross = closeCross?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        button.setBackgroundImage((coloredCross), for: .normal)
        button.addTarget(self, action: #selector(buttonCloseTapped), for: .touchUpInside)
        
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        searchTextField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        searchTextField.delegate = self
    }

    @objc func buttonCloseTapped() {
        searchTextField.resignFirstResponder()
        
        buttonTapAction?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Call the onTextChanged closure
        onTextChanged?(updatedText)
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onStartSearch?()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        onEndSearch?()
        return true
    }
    
    func setSearchBarText(_ text: String) {
        searchTextField.text = text
        onTextChanged?(text)
    }
    
    private func setupView() {
        addSubview(searchTextField)
        addSubview(searchIcon)
        addSubview(closeButton)
        
        setDeafultBackground()
        roundCorners(20)
        
        searchIcon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        
        searchIcon.widthAnchor.constraint(equalTo: searchIcon.heightAnchor).isActive = true
        
        searchIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        searchTextField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 10).isActive = true
        searchTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
        
        searchTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        closeButton.backgroundColor = .clear
        
        
        closeButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
        
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func setDeafultBackground() {
        backgroundColor = .init(red: 0, green: 151 / 255, blue: 78 / 255, alpha: 0.4)
    }
}
