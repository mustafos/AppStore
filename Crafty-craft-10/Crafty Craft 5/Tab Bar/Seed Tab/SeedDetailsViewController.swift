//
//  SeedDetailsViewController.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 30.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class SeedDetailsViewController: UIViewController {
    typealias ImageDataCallback = (Data?) -> Void
    
    let seed: SeedRealmSession
    @IBOutlet weak var doneView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descSeedLabel: UILabel!
    @IBOutlet weak var seedIcon: UIImageView!
    private lazy var dropboxQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.seed.serialSeed")
        
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
    
    private lazy var loader = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .white
        return activityView
    }()
    
    init(seed: SeedRealmSession) {
        self.seed = seed
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackground()
    }
    
    //MARK: - Action
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func copyLinkAction(_ sender: Any) {
        doneView.isHidden = false
        UIPasteboard.general.string = seed.seed
        
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
    @IBAction func shareAction(_ sender: UIButton) {
        self.share(string: seed.seed, from: sender)
    }
    //MARK: - private method

    private func setupUI() {
        descSeedLabel.text = seed.seedDescrip
        titleLabel.text = seed.name
        
        if let imageData = seed.seedImageData {
            seedIcon.image = UIImage(data: imageData)
        } else {
            loadDropboxImage(imageName: seed.seedImagePath, queue: dropboxQueue)
        }
    }
    
    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "Green Background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
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
                self?.seedIcon.image = img
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
                    self?.seedIcon.image = UIImage(named: "Seed Default Icon")
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
    
    private func addLoader() {
        seedIcon.addSubview(loader)
        seedIcon.bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: seedIcon.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: seedIcon.centerXAnchor).isActive = true
        loader.startAnimating()
    }
    
    private func removeLoader() {
        loader.removeFromSuperview()
    }
}


