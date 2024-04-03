import UIKit
import EzPopup
import ZIPFoundation

class ContentViewController: UIViewController {
    typealias ImageDataCallback = (Data?) -> Void
    
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    @IBOutlet private weak var navigationBarContainerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var isNewImage: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet weak var heightGeneralView: NSLayoutConstraint!
    
    @IBOutlet weak var skinsImage: UIImageView!
    @IBOutlet private weak var pageImage: UIImageView!
    @IBOutlet private weak var pageLabel: UILabel!
    
    @IBOutlet weak var generalContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet private weak var downloadBtnActivity: UIActivityIndicatorView! {
        didSet {
            downloadBtnActivity.hidesWhenStopped = true
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView?
    private var documentPicker: DocumentPicker?
    
    private var isPageFavorite: Bool = false
    
    private var model: TabPagesCollectionCellModel
    private let mode: TabsPageController
    
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.seed.serialContent")
        
        return queue
    }()
    
    private let imageSemaphore = DispatchSemaphore(value: 0)
    private var imageUrl: URL?
    private var image: UIImage?
    
    private lazy var imageService = ImageService()
    private var imageRequest: Cancellable?
    private var imageDataCallback: ImageDataCallback?
    
    private var imageFetchOperation: DispatchWorkItem = .init(block: {})
    private var imageDownloadOperation: DispatchWorkItem = .init(block: {})
    private var imageApplyOperation: DispatchWorkItem = .init(block: {})
    
    init(model: TabPagesCollectionCellModel, mode: TabsPageController) {
        self.model = model
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPropertys()
        textView.delegate = self
        updateContainerBottomConstraint()
        isPageFavorite = model.isFavorite
        
        updateFavoriteButton()
        updateDowloadButton()
        updateTitleLabel()
        
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
    }
    
    private func setUpPropertys() {
        if let image = model.imageData {
            if mode == .skins {
                skinsImage.image = UIImage(data: image)
            } else {
                pageImage.image = UIImage(data: image)
            }
        } else {
            if mode == .skins {
                skinsImage.image = UIImage()
            } else {
                pageImage.image = UIImage()
            }
            loadDropboxImage(imageName: model.image, queue: dropboxQueue)
        }
        pageLabel.text = model.name.uppercased()
        textView.text = model.description
        let isTextViewScrollable = textView.frame.size.height > view.frame.size.height
        scrollView.isScrollEnabled = isTextViewScrollable
        textView.isScrollEnabled = isTextViewScrollable
        generalContainer.roundCorners(30)
        generalContainer.layer.borderWidth = 1
        generalContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        generalContainer.clipsToBounds = true
        
        titleContainer.roundCorners(20)
        titleContainer.layer.borderWidth = 1
        titleContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        titleContainer.clipsToBounds = true
        
        pageImage.roundCorners(25)
        pageImage.setBorder(size: 1, color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
        pageImage.clipsToBounds = true
        pageImage.translatesAutoresizingMaskIntoConstraints = false
        
        if mode == .skins {
            skinsImage.isHidden = false
            generalContainer.isHidden = true
        }
    }
    
    private func loadDropboxImage(imageName: String, queue: DispatchQueue) {
        DispatchQueue.main.async { [weak self] in
            self?.showActivityIndicator()
        }
        
        imageFetchOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageFetchOperation.isCancelled == false else {
                return
            }
            
            self?.fetchDropboxUrl(by: imageName)
        })
        
        imageDownloadOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageDownloadOperation.isCancelled == false else {
                return
            }
            
            guard let url = self?.imageUrl else {
                return
            }
            
            self?.fetchImage(from: url)
        })
        
        imageApplyOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageApplyOperation.isCancelled == false else {
                return
            }
            
            let img = self?.image ?? UIImage()
            
            // Update Thumbnail Image View
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                if self?.mode == .skins {
                    self?.skinsImage.image = img
                } else {
                    self?.pageImage.image = img
                }
            }
            
            if let imageDataCallback = self?.imageDataCallback {
                imageDataCallback(self?.image?.pngData())
            }
        })
        
        queue.async(execute: imageFetchOperation)
        queue.async(execute: imageDownloadOperation)
        queue.async(execute: imageApplyOperation)
    }
    
    private func generateRandomCharacter() -> Character {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomIndex = Int.random(in: 0..<characters.count)
        return characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
    }
    
    private func fetchDropboxUrl(by name: String) {
        DropBoxParserFiles.shared.getBloodyImageURLFromDropBox(img: name) { [weak self] stringUrl in
            if let stringUrl, let url = URL(string: stringUrl) {
                self?.imageUrl = url
            } else {
                // data from url == error
                self?.imageUrl = .none
                self?.image = .none
                
                self?.imageDownloadOperation.cancel()
                
                DispatchQueue.main.async {
                    if self?.mode == .skins {
                        self?.skinsImage.image = UIImage()
                    } else {
                        self?.pageImage.image = UIImage()
                    }
                }
            }
            self?.imageSemaphore.signal()
        }
        imageSemaphore.wait()
    }
    
    private func fetchImage(from url: URL) {
        if let imageUrl {
            imageRequest = imageService.image(for: imageUrl) { [weak self] image in
                self?.image = image
                self?.imageSemaphore.signal()
            }
            imageSemaphore.wait()
        }
    }
    
    private func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.startAnimating()
        guard let activityIndicator else { return }
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        mode == .skins ? skinsImage.addSubview(activityIndicator) : pageImage.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }
    
    private func hideActivityIndicator() {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }
    
    private func generateRandomString(length: Int) -> String {
        return String((0..<length).map { _ in generateRandomCharacter() })
    }
    
    private func updateContainerBottomConstraint() {
        if textView.text.count < 500 {
            heightGeneralView.constant = 250
        } else {
            heightGeneralView.constant = 21
        }
    }
    
    private func updateFavoriteButton() {
        let imageName = isPageFavorite ? "FavButton_selected" : "FavButton_unselected"
        favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func updateDowloadButton() {
        var buttonImage = !isAlreadyDownloadItem ? "Save Item" : "Dowmload Item"
        if mode == .addons, isAlreadyDownloadItem {
            buttonImage = "Dowmload Item"
        }
        
        downloadButton.setImage(UIImage(named: buttonImage), for: .normal)
    }
    
    private func generateFreandString(length: Int) -> String {
        return String((0..<length).map { _ in generateRandomCharacter() })
    }
    
    private func updateTitleLabel() {
        titleLabel.text = titleString
    }
    
    @IBAction private func onNavBarBackButtonTapped(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    @IBAction private func favoriteButtonTapped(_ sender: UIButton) {
        isPageFavorite.toggle()
        
        switch mode {
        case .skins:
            RealmServiceProviding.shared.updateSkin(id: model.id, isFavorit: isPageFavorite)
        case .addons:
            RealmServiceProviding.shared.updateAddon(id: model.id, isFavorit: isPageFavorite)
        case .maps:
            RealmServiceProviding.shared.updateMap(id: model.id, isFavorit: isPageFavorite)
        }
        
        updateFavoriteButton()
    }
    
    @IBAction private func onActionButtonTapped(_ sender: UIButton) {
        guard NetworkStatusMonitor.shared.isNetworkAvailable else {
            self.showNoInternetMess()
            return
        }
        
        if isAlreadyDownloadItem {
            switch mode {
            case .addons:
                guard let url = dowloadedURL else { return }
                showInstallTypePopover(fileTmpURL: url)
            default:
                shareItem(sender)
            }
        } else {
            //Download
            downloadButton.setImage(UIImage(named: ""), for: .normal)
            downloadItem { [weak self] url in
                guard let self, let url else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    switch self.mode {
                    case .skins:
                        self.updateDowloadButton()
                        // save to galery and show info popup
                        do {
                            let data = try Data(contentsOf: url)
                            guard let image = UIImage(data: data) else {
                                print("error - UIImage(data: data) is nil")
                                return
                            }
                            self.requestAuthorizationAndSaveImageToLibrary(image: image)
                        } catch {
                            print(error.localizedDescription)
                        }
                    case .addons:
                        self.updateDowloadButton()
                        // show install type popup
                        self.showInstallTypePopover(fileTmpURL: url)
                    case .maps:
                        self.shareItem(sender)
                    }
                }
            }
        }
    }
    
    private func downloadItem(completionHandler: @escaping (URL?) -> Void) {
        guard let file = fileName else { return }
        downloadButton.isEnabled = false
        downloadBtnActivity.startAnimating()
        localAddonFileUrl(file: file) { [weak self] url in
            self?.downloadButton.isEnabled = true
            self?.downloadBtnActivity.stopAnimating()
            completionHandler(url)
        }
    }
    
    private func shareItem(_ sender: UIButton) {
        switch mode {
        case .skins:
            shareSkin(sender)
        case .addons, .maps:
            shareAddonOrMap(sender)
        }
    }
    
    private func shareSkin(_ sender: UIButton) {
        guard let file = fileName else { return }
        downloadButton.isEnabled = false
        downloadBtnActivity.startAnimating()
        
        localAddonFileUrl(file: file) { [weak self] tempUrl in
            self?.downloadButton.isEnabled = true
            self?.downloadBtnActivity.stopAnimating()
            
            if let tempUrl {
                self?.minecraftSkinManager.start(tempUrl) { [weak self] url in
                    self?.share(url: url, from: sender)
                }
            }
        }
    }
    
    private func shareAddonOrMap(_ sender: UIButton) {
        guard let file = model.file else { return }
        
        downloadButton.isEnabled = false
        downloadBtnActivity.startAnimating()
        
        localAddonFileUrl(file: file) { [weak self] url in
            self?.updateDowloadButton()
            self?.downloadButton.isEnabled = true
            self?.downloadBtnActivity.stopAnimating()
            
            if let url {
                self?.share(url: url, from: sender)
            }
        }
    }
    
    private var isAlreadyDownloadItem: Bool {
        guard let file = fileName else {
            return  false
        }
        let fileManager = FileManager.default
        let destination = fileManager.documentDirectory.appendingPathComponent(file)
        return fileManager.fileExists(atPath: destination.path)
    }
    
    private var dowloadedURL: URL? {
        guard let file = fileName else {
            return nil
        }
        let fileManager = FileManager.default
        let destination = fileManager.documentDirectory.appendingPathComponent(file)
        return fileManager.fileExists(atPath: destination.path) ? destination : nil
    }
    
    private func localAddonFileUrl(file uri: String, completionHandler: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        
        let destination = fileManager.documentDirectory.appendingPathComponent(uri)
        let dir = destination.deletingLastPathComponent()
        dir.createDir()
        
        if !fileManager.fileExists(atPath: destination.path) {
            DropBoxParserFiles.shared.downloadBloodyFileBy(urlPath: uri) { data in
                do {
                    try data?.write(to: destination)
                    
                    completionHandler(destination)
                } catch {
                    AppDelegate.log("!!!")
                    
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(destination)
        }
    }
}

extension ContentViewController {
    var fileName: String? {
        switch mode {
        case .addons:
            guard let fileName = model.file else { return nil }
            return fileName
        case .skins:
            guard let fileName = model.file?.split(separator: "/").last else { return nil }
            return "skins/source/\(fileName)"
        default:
            guard let fileName = model.image.split(separator: "/").last else { return nil }
            return "maps/\(fileName)"
        }
    }
    
    var titleString: String {
        switch mode {
        case .addons:
            return "ADDONS"
        case .skins:
            return "SKINS"
        case .maps:
            return "MAPS"
        }
    }
}

extension ContentViewController {
    func showInstallTypePopover(fileTmpURL: URL) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let downloadContnetVC = DownloadContnetViewController()
        downloadContnetVC.shareAddonAction = { [weak self] in
            guard let self else { return }
            self.shareItem(self.downloadButton)
        }
        downloadContnetVC.manualIntallAction = {  [weak self] in
            guard let self else { return }
            // show manual instruction
            let instructionVC = ManualInstructionViewController()
            instructionVC.onGrantAccessAction = { [weak self] in
                guard let self else { return }
                // show document picker
                self.documentPicker?.displayPicker()
            }
            let popupVC = PopupViewController(contentController: instructionVC, popupWidth: 302, popupHeight: 540)
            popupVC.view.insertSubview(blurView, at: 0)
            self.present(popupVC, animated: true)
        }
        
        let popupVC = PopupViewController(contentController: downloadContnetVC, popupWidth: 268, popupHeight: 324)
        popupVC.view.insertSubview(blurView, at: 0)
        present(popupVC, animated: true)
    }
    
    private func documentPicker(didPickDocumentAt url: URL) {
        // Start accessing a security-scoped resource.
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            return
        }
        
        // Make sure you release the security-scoped resource when you finish.
        defer { url.stopAccessingSecurityScopedResource() }
        
        if isBehaviorPackFolder(url: url) || isResourcePackFolder(url: url) {
            // install in this folder
            installCurrentAddonTo(desinationURL: url)
        } else {
            // show error popup
            showAlert(title: "Error", message: "You have selected the wrong folder. Select the Minecraft folder from the list.", cancelTitle: "Cancel")
        }
    }
    
    private func installCurrentAddonTo(desinationURL: URL) {
        let fileManager = FileManager()
        var destinationURL = desinationURL
        destinationURL.appendPathComponent(model.name)
        
        do {
            guard let downloadedTmpUrl = dowloadedURL else {
                showAlert(title: "Error", message: "Something went wrong")
                return
            }
            let zipURL = downloadedTmpUrl.deletingPathExtension().appendingPathExtension("zip")
            try FileManager.default.moveItem(at: downloadedTmpUrl, to: zipURL)
            
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: zipURL, to: destinationURL)
            showAlert(title: "Success", message: "Addon successfuly installed")
        } catch {
            if (error as NSError).code == 516 {
                showAlert(title: "Error", message: "Addon already installed in this folder.")
            } else {
                showAlert(title: "Error", message: "Something went wrong")
            }
        }
    }
    
    private func isFileTheMinecraftRootFolder(fileList: FileManager.DirectoryEnumerator) -> Bool {
        var minecraftFolders: Set<String> = ["games", "internal"]
        for case let file as URL in fileList {
            minecraftFolders.remove(file.lastPathComponent)
        }
        return minecraftFolders.isEmpty
    }
    
    private func isBehaviorPackFolder(url: URL) -> Bool {
        url.lastPathComponent == "behavior_packs"
    }
    
    private func isResourcePackFolder(url: URL) -> Bool {
        url.lastPathComponent == "resource_packs"
    }
}

// save image
extension ContentViewController {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {}
}

extension ContentViewController {
    private func showAlert(title: String, message: String, cancelTitle: String = "OK") {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let craftyAlertVC = GeneralAlertViewController()
        craftyAlertVC.config(model: .init(title: title, subTitle: message, buttonTitle: cancelTitle))
        let popupVC = PopupViewController(contentController: craftyAlertVC, popupWidth: 268, popupHeight: 170)
        popupVC.view.insertSubview(blurView, at: 0)
        present(popupVC, animated: true)
    }
}

extension ContentViewController: DocumentDelegate{
    func didPickURL(_ url: URL?) {
        guard let url else { return }
        self.documentPicker(didPickDocumentAt: url)
    }
}

extension ContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateContainerBottomConstraint()
    }
}
