import UIKit
import AVKit
import AVFoundation

enum PremiumMainControllerStyle {
    case mainProduct,unlockContentProduct,unlockFuncProduct,unlockOther
}

class PremiumMainController: UIViewController {
    
    private weak var player: Player!
    private var view0 = ReusableView()
    private var view1 = ReusableView()
    private var viewTransaction = TransactionView()
    
    @IBOutlet private weak var freeform: UIView!
    @IBOutlet private weak var videoElement: UIView!
    @IBOutlet private weak var restoreBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    public var productBuy : PremiumMainControllerStyle = .mainProduct
    
    private var intScreenStatus = 0
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initVideoElement()
        startMaked()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !NetworkStatusMonitor.shared.isNetworkAvailable {
            showMess()
        }
    }
    
    deinit {
        deinitPlayer()
    }
    
    private func initVideoElement(){
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            BGPlayer()
        }
    }
    
    
    //MARK: System events
    
    private func deinitPlayer() {
        if let player {
          self.player.volume = 0
          self.player.url = nil
          self.player.didMove(toParent: nil)
        }
        player = nil
      }

    // MARK: - Setup Video Player

    private func BGPlayer() {
        var pathUrl = Bundle.main.url(forResource: ConfigurationMediaSub.nameFileVideoForPhone, withExtension: ConfigurationMediaSub.videoFileType)
        if UIDevice.current.userInterfaceIdiom == .pad {
            pathUrl = Bundle.main.url(forResource: ConfigurationMediaSub.nameFileVideoForPad, withExtension: ConfigurationMediaSub.videoFileType)
        }else{
            pathUrl = Bundle.main.url(forResource: ConfigurationMediaSub.nameFileVideoForPhone, withExtension: ConfigurationMediaSub.videoFileType)
        }

       let player = Player()
        //player.muted = true
        player.playerDelegate = self
        player.playbackDelegate = self
        player.view.frame = self.view.bounds

        addChild(player)
        view.addSubview(player.view)
        player.didMove(toParent: self)
        player.url = pathUrl
        if UIDevice.current.userInterfaceIdiom == .pad {
            player.playerView.playerFillMode = .resizeAspectFill
        }else{
            player.playerView.playerFillMode = .resize
        }
        player.playbackLoops = true
        view.sendSubviewToBack(player.view)
        self.player = player
    }
    
    private func loopVideoMB(videoPlayer:AVPlayer){
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: .zero)
            videoPlayer.play()
        }
    }
    
    // MARK: - Make UI/UX
    
    private func startMaked() {
        setRestoreBtn()
        if productBuy == .mainProduct {
            setReusable(config: .first, isHide: false)
            setReusable(config: .second, isHide: true)
            setTransaction(isHide: true)
        } else {
            setTransaction(isHide: false)
            self.showRestore()
        }
    }
    
    //reusable setup
    
    private func generateContentForView(config: configView) -> [ReusableContentCell] {
        var contentForCV : [ReusableContentCell] = []
        switch config {
        case .first:
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text1ID"), image: UIImage(named: "2_1des")!, selectedImage: UIImage(named: "2_1sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text2ID"), image: UIImage(named: "2_2des")!, selectedImage: UIImage(named: "2_2sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text3ID"), image: UIImage(named: "2_3des")!, selectedImage: UIImage(named: "2_3sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text4ID"), image: UIImage(named: "2_4des")!, selectedImage: UIImage(named: "2_4sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text5ID"), image: UIImage(named: "2_5des")!, selectedImage: UIImage(named: "2_5sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text1ID"), image: UIImage(named: "2_1des")!, selectedImage: UIImage(named: "2_1sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text2ID"), image: UIImage(named: "2_2des")!, selectedImage: UIImage(named: "2_2sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text3ID"), image: UIImage(named: "2_3des")!, selectedImage: UIImage(named: "2_3sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text4ID"), image: UIImage(named: "2_4des")!, selectedImage: UIImage(named: "2_4sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text5ID"), image: UIImage(named: "2_5des")!, selectedImage: UIImage(named: "2_5sel")!))
            return contentForCV
        case .second:
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text1ID"), image: UIImage(named: "2_1des")!, selectedImage: UIImage(named: "2_1sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text2ID"), image: UIImage(named: "2_2des")!, selectedImage: UIImage(named: "2_2sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text3ID"), image: UIImage(named: "2_3des")!, selectedImage: UIImage(named: "2_3sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text4ID"), image: UIImage(named: "2_4des")!, selectedImage: UIImage(named: "2_4sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text5ID"), image: UIImage(named: "2_5des")!, selectedImage: UIImage(named: "2_5sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text1ID"), image: UIImage(named: "2_1des")!, selectedImage: UIImage(named: "2_1sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text2ID"), image: UIImage(named: "2_2des")!, selectedImage: UIImage(named: "2_2sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text3ID"), image: UIImage(named: "2_3des")!, selectedImage: UIImage(named: "2_3sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text4ID"), image: UIImage(named: "2_4des")!, selectedImage: UIImage(named: "2_4sel")!))
            contentForCV.append(ReusableContentCell(title: localizedString(forKey:"Text5ID"), image: UIImage(named: "2_5des")!, selectedImage: UIImage(named: "2_5sel")!))
            return contentForCV
        case .transaction: return contentForCV
        }
    }
    
    private func setReusable(config : configView, isHide : Bool){
        var currentView : ReusableView? = nil
        var viewModel : ReusableViewModel? = nil
        switch config {
        case .first:
            viewModel =  ReusableViewModel(title: localizedString(forKey: "TextTitle1ID").uppercased(), items: self.generateContentForView(config: config))
            currentView = self.view0
        case .second:
            viewModel =  ReusableViewModel(title: localizedString(forKey: "TextTitle2ID").uppercased(), items: self.generateContentForView(config: config))
            currentView = self.view1
        case .transaction:
            currentView = nil
        }
        guard let i = currentView else { return }
        i.protocolElement = self
        i.viewModel = viewModel
        i.configView = config
        freeform.addSubview(i)
        freeform.bringSubviewToFront(i)
        
        i.snp.makeConstraints { make in
            make.height.equalTo(338)
            make.width.equalTo(freeform).multipliedBy(1)
            make.centerX.equalTo(freeform).multipliedBy(1)
            make.bottom.equalTo(freeform).offset(0)
        }
        i.isHidden = isHide
    }
    //transaction setup
    
    private func setTransaction( isHide : Bool) {
        self.viewTransaction.inapp.productBuy = self.productBuy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewTransaction.setLocalization_TOC()
        }
        freeform.addSubview(self.viewTransaction)
        freeform.bringSubviewToFront(self.viewTransaction)
        self.viewTransaction.inapp.productBuy = self.productBuy
        self.viewTransaction.snp.makeConstraints { make in
            //            make.height.equalTo(338)
            make.width.equalTo(freeform).multipliedBy(1)
            make.centerX.equalTo(freeform).multipliedBy(1)
            make.bottom.equalTo(freeform).offset(0)
        }
        self.viewTransaction.isHidden = isHide
        self.viewTransaction.delegate = self
    }
    
    // restore button setup
    
    private func setRestoreBtn(){
        self.restoreBtn.isHidden = true
        self.restoreBtn.titleLabel?.font = UIFont(name: "SFProDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 12 : 22)
        self.restoreBtn.setTitle(localizedString(forKey: "restore"), for: .normal)
        self.restoreBtn.titleLabel?.setShadow()
        self.restoreBtn.tintColor = .white
        self.restoreBtn.setTitleColor(.white, for: .normal)
    }
    
    private func openApp(){
        let tabBarVC = TabBarViewController()
        let navVC = UINavigationController(rootViewController: tabBarVC)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.navigationBar.isHidden = true
        
        UIApplication.shared.setRootVC(navVC)

        UIApplication.shared.notificationFeedbackGenerator(type: .success)
        deinitPlayer()
    }

    
    private func showRestore(){
        self.restoreBtn.isHidden = false
        if productBuy != .mainProduct {
            self.closeBtn.isHidden = false
        }
    }
    
    @IBAction func restoreAction(_ sender: UIButton) {
        self.viewTransaction.restoreAction()
    }
    
    @IBAction func closeController(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension PremiumMainController : ReusableViewEvent {
    func nextStep(config: configView) {
        switch config {
        case .first:
            self.view0.fadeOut()
            self.view1.fadeIn()
            UIApplication.shared.impactFeedbackGenerator(type: .medium)
            ThirdPartyServicesManager.shared.makeATT()
        case .second:
            self.view1.fadeOut()
            self.viewTransaction.fadeIn()
            self.showRestore()
            //            self.viewTransaction.title.restartpageControl()
            UIApplication.shared.impactFeedbackGenerator(type: .medium)
        case .transaction: break
        }
    }
}

extension PremiumMainController: NetworkStatusMonitorDelegate {
    func showMess() {
        transactionTreatment_TOC(title: NSLocalizedString( "ConnectivityTitle", comment: ""), message: NSLocalizedString("ConnectivityDescription", comment: ""))
    }
}

extension PremiumMainController : TransactionViewEvents {
    
    func userSubscribed() {
        self.openApp()
    }
    
    func transactionTreatment_TOC(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        UIApplication.shared.notificationFeedbackGenerator(type: .warning)
    }
    
    func transactionFailed() {
        print(#function)
        UIApplication.shared.notificationFeedbackGenerator(type: .error)
    }
    
    func privacyOpen() {
        Configurations_REFACTOR.policyLink.openURL()
    }
    
    func termsOpen() {
        Configurations_REFACTOR.termsLink.openURL()
    }
}

extension PremiumMainController: PlayerDelegate, PlayerPlaybackDelegate {
    func playerReady(_ player: Player) { }

    func playerPlaybackStateDidChange(_ player: Player) { }

    func playerBufferingStateDidChange(_ player: Player) { }

    func playerBufferTimeDidChange(_ bufferTime: Double) { }

    func player(_ player: Player, didFailWithError error: Error?) { }

    func playerCurrentTimeDidChange(_ player: Player) { }

    func playerPlaybackWillStartFromBeginning(_ player: Player) { }

    func playerPlaybackDidEnd(_ player: Player) { }

    func playerPlaybackWillLoop(_ player: Player) { }

    func playerPlaybackDidLoop(_ player: Player) { }
}

