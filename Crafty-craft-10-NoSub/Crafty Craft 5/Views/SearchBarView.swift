import UIKit

class SearchBarView: UIView, UITextFieldDelegate {
    var onTextChanged: ((String) -> Void)?
    var buttonTapAction: (() -> Void)?
    var onStartSearch: (() -> Void)?
    var onEndSearch: (() -> Void)?
    var isShowSearchResult = false
    
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
        button.setImage(UIImage(named: "cancel filter"), for: .normal)
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
        isShowSearchResult.toggle()
        
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
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        setDeafultBackgroundWithCorner()
        
        NSLayoutConstraint.activate([
            searchIcon.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            searchIcon.widthAnchor.constraint(equalTo: searchIcon.heightAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            searchTextField.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 10),
            searchTextField.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -5),
            searchTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            closeButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func setDeafultBackgroundWithCorner() {
        backgroundColor = UIColor(named: "YellowSelectiveColor")
        if isShowSearchResult {
            roundCorners([.topLeft, .topRight], radius: 23)
        } else {
            roundCorners(23)
        }
    }
}
