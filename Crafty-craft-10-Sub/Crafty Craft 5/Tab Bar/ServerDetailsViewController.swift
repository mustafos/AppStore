//
//  ServerDetailsViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 17.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class ServerDetailsViewController: UIViewController {
    typealias ImageDataCallback = (Data?) -> Void
    
    let server: ServerRealmSession
    var blurEffectView: UIVisualEffectView?
    
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.acme.serial")
        
        return queue
    }()

    @IBOutlet weak var doneView: UIView!
    @IBOutlet weak var serverIcon: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descServerLabel: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var generalContainer: UIView!
    @IBOutlet weak var titleContainer: UIView!
    
    private let imageSemaphore = DispatchSemaphore(value: 0)
    private var imageUrl: URL?
    private var image: UIImage?
    
    private lazy var imageService = ImageService()
    private var imageRequest: Cancellable?
    private var imageDataCallback: ImageDataCallback?
    
    private var imageFetchOperation: DispatchWorkItem = .init(block: {})
    private var imageDownloadOperation: DispatchWorkItem = .init(block: {})
    private var imageApplyOperation: DispatchWorkItem = .init(block: {})
    
    private lazy var loader = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .black
        return activityView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayers()
    }
    
    init(server: ServerRealmSession) {
        self.server = server
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        descServerLabel.text = server.descrip
        nameLabel.text = server.name
        
        if let imageData = server.imageData {
            serverIcon.image = UIImage(data: imageData)
        } else {
            loadDropboxImage(imageName: server.imageFilePath, queue: dropboxQueue)
        }
        
        /// Check scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        descServerLabel.translatesAutoresizingMaskIntoConstraints = false
        if server.descrip.count < (Device.iPhone ? (Device.smallDevice ? 400 : 650) : 900) {
            scrollView.isScrollEnabled = false
            descServerLabel.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
            descServerLabel.isScrollEnabled = true
        }
    }
    
    private func loadDropboxImage(imageName: String, queue: DispatchQueue) {
        DispatchQueue.main.async {
            self.addLoader()
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
            
            let img = self?.image ?? UIImage(named: "Seed Default Icon")
            
            // Update Thumbnail Image View
            DispatchQueue.main.async {
                self?.removeLoader()
                self?.serverIcon.image = img
            }
            
            if let imageDataCallback = self?.imageDataCallback {
                imageDataCallback(self?.image?.pngData())
            }
        })
        
        queue.async(execute: imageFetchOperation)
        queue.async(execute: imageDownloadOperation)
        queue.async(execute: imageApplyOperation)
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
                    self?.serverIcon.image = UIImage(named: "Seed Default Icon")
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
    
    private func setupLayers() {
        generalContainer.roundCorners(30)
        generalContainer.backgroundColor = UIColor(named: "YellowLightColor")
        generalContainer.layer.borderWidth = 1
        generalContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        titleContainer.roundCorners(20)
        titleContainer.layer.borderWidth = 1
        titleContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor

        serverIcon.roundCorners(25)
        serverIcon.setBorder(size: 1, color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
    }
    
    // MARK: - Action
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func copyLinkButtonTapped(_ sender: Any) {
        addBlurEffectToBackground()
        doneView.roundCorners(20)
        doneView.isHidden = false
        UIPasteboard.general.string = server.address
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
           
            UIView.transition(with: self.doneView, duration: 0.3,
                              options: .curveEaseOut,
                              animations: { [weak self] in
                self?.doneView.alpha = 0
                self?.blurEffectView?.alpha = 0
            }) { [weak self] _ in
                self?.doneView.alpha = 1
                self?.doneView.isHidden = true
                self?.blurEffectView?.removeFromSuperview()
                self?.blurEffectView = nil
            }
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        self.share(string: server.address, from: sender)
    }
    
    // BlurBackground
    private func addBlurEffectToBackground() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.alpha = 0
        view.addSubview(blurEffectView!)
        
        // Make the blur effect view cover the doneView
        view.bringSubviewToFront(doneView)
        
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView?.alpha = 1
        }
    }
    
    private func addLoader() {
        serverIcon.addSubview(loader)
        serverIcon.bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: serverIcon.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: serverIcon.centerXAnchor).isActive = true
        loader.startAnimating()
    }
    
    private func removeLoader() {
        loader.removeFromSuperview()
    }
}
