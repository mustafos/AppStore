//  Created by Melnykov Valerii on 14.07.2023
//


import UIKit

protocol TransactionViewEvents : AnyObject {
    func userSubscribed()
    func transactionTreatment_TOC(title: String, message: String)
    func transactionFailed()
    func privacyOpen()
    func termsOpen()
}

class TransactionView: UIView,AnimatedButtonEvent,IAPManagerProtocol, NetworkStatusMonitorDelegate {
    func showMess() {
        transactionTreatment_TOC(title: NSLocalizedString( "ConnectivityTitle", comment: ""), message: NSLocalizedString("ConnectivityDescription", comment: ""))
    }
    
    
    private let xib = "TransactionView"
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private(set) weak var title: UILabel!
    @IBOutlet private weak var sliderStack: UIStackView!
    @IBOutlet private weak var trialLb: UILabel!
    @IBOutlet private weak var descriptLb: UILabel!
    @IBOutlet private weak var purchaseBtn: AnimatedButton!
    @IBOutlet private weak var privacyBtn: UIButton!
    @IBOutlet private weak var policyBtn: UIButton!
    @IBOutlet private weak var sliderWight: NSLayoutConstraint!
    @IBOutlet private weak var sliderTop: NSLayoutConstraint!
    @IBOutlet private weak var conteinerWidth: NSLayoutConstraint!
    @IBOutlet private weak var heightView: NSLayoutConstraint!
    //@IBOutlet private weak var trialWight: NSLayoutConstraint!
    @IBOutlet weak var trialView: UIView!
    
    private let currentFont = Configurations.getSubFontName()
    public let inapp = IAPManager.shared
    private let locale = NSLocale.current.languageCode
    public weak var delegate : TransactionViewEvents?
    private let networkingMonitor = NetworkStatusMonitor.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Init()
    }
    
    private func Init() {
        Bundle.main.loadNibNamed(xib, owner: self, options: nil)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Устройство является iPhone
            if UIScreen.main.nativeBounds.height >= 2436 {
                heightView.constant = 163
            } else {
//                sliderTop.constant = 60
                heightView.constant = 152
            }
        } else {
            conteinerWidth.constant = 400
            heightView.constant = 167
//            sliderTop.constant = 45
        }
        contentView.fixInView(self)
        contentView.backgroundColor = .clear
        buildConfigs_TOC()
    }
    
    private func buildConfigs_TOC(){
        configScreen_TOC()
        setSlider_TOC()
        setConfigLabels_TOC()
        setConfigButtons_TOC()
        setLocalization_TOC()
        configsInApp_TOC()
    }
    
    private func setSlider_TOC(){
        
        title.text = (localizedString(forKey: "SliderID1").uppercased())
        var texts: [String] = ["\(localizedString(forKey: "SliderID2"))",
                               "\(localizedString(forKey: "SliderID3"))",
                               "\(localizedString(forKey: "SliderID4"))",
                               ]
        for t in texts {
            sliderStack.addArrangedSubview(SliderCellView(title: t, subTitle: t.lowercased()))
        }
    }
    
    //MARK: config labels
    
    private func setConfigLabels_TOC(){
        //slider
        title.textColor = .white
        title.font = UIFont(name: currentFont, size: 24)
//        title.adjustsFontSizeToFitWidth = true
        title.numberOfLines = 4
        title.setShadow()
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            title.textAlignment = .right
        }
        title.lineBreakMode = .byClipping
        if UIDevice.current.userInterfaceIdiom == .pad {
            title.font = UIFont(name: currentFont, size: 24)
        }
        trialLb.setShadow()
        trialLb.font = UIFont(name: currentFont, size: 13)
        trialLb.textColor = .white
        trialLb.textAlignment = .center
        trialLb.numberOfLines = 2
        trialLb.adjustsFontSizeToFitWidth = true
        
        descriptLb.setShadow()
        descriptLb.textColor = .white
        descriptLb.textAlignment = .center
        descriptLb.numberOfLines = 0
        descriptLb.font = UIFont.systemFont(ofSize: 15)
        
        privacyBtn.titleLabel?.setShadow()
        privacyBtn.titleLabel?.numberOfLines = 2
        privacyBtn.titleLabel?.textAlignment = .center
        
        privacyBtn.setTitleColor(.white, for: .normal)
        privacyBtn.tintColor = .white
        
        policyBtn.titleLabel?.setShadow()
        policyBtn.titleLabel?.numberOfLines = 2
        policyBtn.titleLabel?.textAlignment = .center
        policyBtn.setTitleColor(.white, for: .normal)
        policyBtn.tintColor = .white
        privacyBtn.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        policyBtn.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
    }
    
    //MARK: config button
    
    private func setConfigButtons_TOC(){
        self.purchaseBtn.delegate = self
        self.purchaseBtn.style = .native
    }
    
    //MARK: config localization
    
    public func setLocalization_TOC() {
        
//        title.labelTextsForSlider = "\(localizedString(forKey: "SliderID1").uppercased())|n\(localizedString(forKey: "SliderID2").uppercased())|n\(localizedString(forKey: "SliderID3").uppercased()) |n\(localizedString(forKey: "SliderID4").uppercased()) |n\(localizedString(forKey: "SliderID5").uppercased())"
        
        let localizedPrice = inapp.localizedPrice()
        descriptLb.text = localizedString(forKey: "iOSAfterID").replacePriceWithNewPrice(newPriceString: localizedPrice)
        
        if locale == "en" {
            trialLb.text = "Start 3-days for FREE\n Then \(localizedPrice)/week".uppercased()
        } else {
            trialLb.text = ""
            trialView.isHidden = true
        }
        privacyBtn.titleLabel?.lineBreakMode = .byWordWrapping
        privacyBtn.setAttributedTitle(localizedString(forKey: "TermsID").underLined, for: .normal)
        policyBtn.titleLabel?.lineBreakMode = .byWordWrapping
        policyBtn.setAttributedTitle(localizedString(forKey: "PrivacyID").underLined, for: .normal)
    }
    
    //MARK: screen configs
    
    private func configScreen_TOC(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            //trialWight.setValue(0.28, forKey: "multiplier")
            //sliderWight.setValue(0.5, forKey: "multiplier")
        } else {
            //trialWight.setValue(0.46, forKey: "multiplier")
            //sliderWight.setValue(0.8, forKey: "multiplier")
        }
    }
    
    //MARK: configs
    
    private func configsInApp_TOC(){
        self.inapp.transactionsDelegate = self
        self.networkingMonitor.delegate = self
    }
    
    public func restoreAction(){
        inapp.doRestore()
    }
    
    //MARK: actions
    
    @IBAction func privacyAction(_ sender: UIButton) {
        
        self.delegate?.termsOpen()
    }
    
    @IBAction func termsAction(_ sender: UIButton) {
        self.delegate?.privacyOpen()
    }
    
    func onClick() {
        UIApplication.shared.impactFeedbackGenerator(type: .heavy)
        if networkingMonitor.checkInternetConnectivity() {
            inapp.doPurchase()
            purchaseBtn.isUserInteractionEnabled = false
        } else {
            showMess()
        }
    }
    
    //inapp
    
    func transactionTreatment_TOC(title: String, message: String) {
        purchaseBtn.isUserInteractionEnabled = true
        self.delegate?.transactionTreatment_TOC(title: title, message: message)
    }
    
    func infoAlert(title: String, message: String) {
        purchaseBtn.isUserInteractionEnabled = true
        self.delegate?.transactionTreatment_TOC(title: title, message: message)
    }
    
    func goToTheApp() {
        purchaseBtn.isUserInteractionEnabled = true
        self.delegate?.userSubscribed()
    }
    
    func failed() {
        purchaseBtn.isUserInteractionEnabled = true
        self.delegate?.transactionFailed()
    }
}

extension String {
    
    func replacePriceWithNewPrice(newPriceString: String) -> String {
        var result = self.replacingOccurrences(of: "4.99", with: newPriceString.replacingOccurrences(of: "$", with: ""))
        result = result.replacingOccurrences(of: "4,99", with: newPriceString.replacingOccurrences(of: "$", with: ""))
        return result
    }
    
}
