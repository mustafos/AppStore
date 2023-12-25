import UIKit

class SearchBarView: UIView, UITextFieldDelegate {
    var onTextChanged: ((String) -> Void)?
    var buttonTapAction: (() -> Void)?
    var onStartSearch: (() -> Void)?
    var onEndSearch: (() -> Void)?
    
    lazy var searchTextField: TintedTextField = {
            let textField = TintedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: "Montserrat-Regular", size: 14)
        textField.textColor = UIColor(named: "EerieBlackColor")
        textField.tintColor = UIColor(named: "EerieBlackColor")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "EerieBlackColor") ?? .clear]
        )
        textField.autocorrectionType = .no
        return textField
    }()
    
    let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // configure the imageView here
        imageView.image = UIImage(named: "Search")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close cross"), for: .normal)
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
        // MARK: – Shadow
        //        layer.masksToBounds = false
        //        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        //        layer.shadowOpacity = 1
        //        layer.shadowRadius = 6
        //        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
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
        closeButton.sizeThatFits(CGSize(width: 32, height: 32))
        
        closeButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func setDeafultBackground() {
        backgroundColor = UIColor(red: 0.97, green: 0.81, blue: 0.38, alpha: 1)
    }
}
