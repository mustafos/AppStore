//
//  SeedTableViewCell.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 17.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class SeedTableViewCell: UITableViewCell {
    static let identifier = "SeedTableViewCell"
    
    typealias ImageDataCallback = (Data?) -> Void
    
    @IBOutlet weak var seedIcon: CustomImageLoader!
    @IBOutlet weak var seedNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
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
        activityView.tintColor = .black
        return activityView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seedIcon.backgroundColor = .clear
        seedIcon.roundCorners(.allCorners, radius: 25)
        seedIcon.setBorder(size: 1, color: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
        
        generalContainer.roundCorners(.allCorners, radius: 30)
        generalContainer.layer.borderWidth = 1
        generalContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        titleContainer.roundCorners(.allCorners, radius: 25)
        titleContainer.layer.borderWidth = 1
        titleContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.seedIcon.image = nil
        cancelImageRequest()
        self.removeLoader()
    }

    deinit {
        cancelImageRequest()
    }
    
    private func cancelImageRequest() {
        imageRequest?.cancel()
        imageFetchOperation.cancel()
        imageDownloadOperation.cancel()
        imageApplyOperation.cancel()
        
        imageDataCallback = nil
    }
    
    private func configDefautFileds(seed: Seed) {
        seedNumberLabel.text = "Seed: \(seed.seedNumber)"
        nameLabel.text = seed.name.trimmingCharacters(in: .whitespaces)
        descLabel.text = seed.descrip
    }
    
    func configWithImageData(seed: Seed) {
        configDefautFileds(seed: seed)
        if let imageData = seed.imageData, let image = UIImage(data: imageData) {
            seedIcon.image = image
        }
    }
    
    func configWithOutImageData(seed: Seed, queue: DispatchQueue, completion: @escaping ImageDataCallback) {
        configDefautFileds(seed: seed)
        
        DispatchQueue.main.async {
            self.addLoader()
        }
        
        self.imageDataCallback = completion
        let imagePathName = seed.imageFilePath
        
        imageFetchOperation = DispatchWorkItem(block: { [weak self] in
            guard self?.imageFetchOperation.isCancelled == false else {
                return
            }
            
            self?.fetchDropboxUrl(by: imagePathName)
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
            guard let self else { return }
            guard self.imageApplyOperation.isCancelled == false else {
                return
            }
            
            let img = self.image ?? UIImage(named: "Seed Default Icon")
            
            // Update Thumbnail Image View
            DispatchQueue.main.async { [weak self] in
                self?.removeLoader()
                self?.seedIcon.image = img
            }
            
            if let imageDataCallback = self.imageDataCallback {
                guard self.imageApplyOperation.isCancelled == false, let pngData = self.image?.pngData() else {
                    return
                }
                imageDataCallback(pngData)
            }
        })
        
        queue.async(execute: imageFetchOperation)
        queue.async(execute: imageDownloadOperation)
        queue.async(execute: imageApplyOperation)
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
}
