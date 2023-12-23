import UIKit


class SettingsViewController: UIViewController {
    
    //MARK: propertirs
    
    private var model: SettingsModel?
    
    //MARK: Iboutlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var vcTitleLab: UILabel!
    
    
    @IBOutlet weak var termsContaienr: UIView!
    @IBOutlet weak var privacyContainer: UIView!
    @IBOutlet weak var clearCacheContainer: UIView!
    @IBOutlet weak var cachesizeLab: UILabel!
    @IBOutlet weak var doneView: UIView!
    
    lazy var alertViewContainer: UIView = {
        var view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        self.view.addSubview(view)

        return view
    }()

    //MARK: Init
    
    init() {
        self.model = SettingsModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    deinit{
        print("SettingsVC is successfully deinited !!")
    }

    
    //MARK: Setup Functions
    
    private func setupActions() {
        
        //terms Container
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(termsViewIsTapped(_:)))
        termsContaienr.addGestureRecognizer(termsTap)
        termsContaienr.isUserInteractionEnabled = true
        
        //privacy Container
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(privacyViewIsTapped(_:)))
        privacyContainer.addGestureRecognizer(privacyTap)
        privacyContainer.isUserInteractionEnabled = true
        
        //ClearCacheBtn Container
        let cearCacheTap = UITapGestureRecognizer(target: self, action: #selector(clearCacheIsTapped(_:)))
        clearCacheContainer.addGestureRecognizer(cearCacheTap)
        clearCacheContainer.isUserInteractionEnabled = true
        
        let alertViewContainerTap = UITapGestureRecognizer(target: self, action: #selector(clearCacheContainerTapped(_:)))
        alertViewContainer.addGestureRecognizer(alertViewContainerTap)
        alertViewContainer.isUserInteractionEnabled = true
        
    }
    
    //MARK: ConfigUI

    private func setupUI() {
        configClearCacheAlertUI()
        configCorners()
        updateCacheLab()
        
        // Set the background color of doneView
        doneView.layer.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8).cgColor
    }

    private func configCorners() {
        termsContaienr.layer.cornerRadius = 32
        privacyContainer.layer.cornerRadius = 32
        clearCacheContainer.layer.cornerRadius = 32
    }

    
    //MARK: private Functions
    
    private func updateCacheLab() {
        cachesizeLab.text = model?.cacheInKB
    }

//MARK: Actions

    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func termsViewIsTapped(_ sender: UITapGestureRecognizer) {
        // Action when the view is tapped
        model?.openUrl(urlToOpen: Configurations.termsLink)
    }
    
    @objc func privacyViewIsTapped(_ sender: UITapGestureRecognizer) {
        // Action when the view is tapped
        model?.openUrl(urlToOpen: Configurations.policyLink)
    }
    
    //clearCacheBtn
    @objc func clearCacheIsTapped(_ sender: UITapGestureRecognizer) {
        doneView.isHidden = false
        model?.clearCache()
        updateCacheLab()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
           
            UIView.transition(with: self.doneView, duration: 0.3,
                              options: .curveEaseOut,
                              animations: { [weak self] in
                self?.doneView.alpha = 0
            }) { [weak self] _ in
                self?.doneView.alpha = 1
                self?.doneView.isHidden = true
            }
        }
    }
    


}


//MARK: ClearCacheAlert functions

extension SettingsViewController {

    //unhiddenAlertContainer
    @objc func clearCacheContainerTapped(_ sender: UITapGestureRecognizer)  {
        alertViewContainer.isHidden = true
    }
    
    private func callClearCacheAlert() {
        alertViewContainer.isHidden = false
    }
    
    private func configClearCacheAlertUI() {
        // Create the parent container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertViewContainer.addSubview(containerView)
        containerView.backgroundColor = UIColor(named: "blackCCRedesign") ?? .black
        containerView.roundCorners(.allCorners, radius: 12)
        
        // Create the label at the top
        let label = UILabel()
        label.text = "CACHE CLEARED"
        label.font = UIFont(name: "Blinker-Bold", size: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        // Create the custom square image view at the bottom
        let squareImageView = UIImageView()
        squareImageView.image = UIImage(named: "done filter") // Customize the image view as needed
        squareImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(squareImageView)
        
        // Define constraints for the container view
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: alertViewContainer.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: alertViewContainer.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: alertViewContainer.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: alertViewContainer.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        // Define constraints for the label
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Define constraints for the square image view
        NSLayoutConstraint.activate([
            squareImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            squareImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            squareImageView.heightAnchor.constraint(equalToConstant: 32),
            squareImageView.widthAnchor.constraint(equalTo: squareImageView.heightAnchor)
        ])
    }
}
