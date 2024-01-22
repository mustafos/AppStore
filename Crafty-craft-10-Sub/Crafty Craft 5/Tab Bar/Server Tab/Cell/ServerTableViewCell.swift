//
//  ServerTableViewCell.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 17.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {
    static let identifier = "ServerTableViewCell"
    
    typealias ImageDataCallback = (Data?) -> Void
    
    @IBOutlet weak var serverIcon: UIImageView!
    
    @IBOutlet weak var subContainer: UIView!
    @IBOutlet weak var namingInfoView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var onlineStatusView: UIView!
    
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
        super.layoutSubviews()
        
        subContainer.roundCorners(.allCorners, radius: 30)
        subContainer.layer.borderWidth = 1
        subContainer.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        serverIcon.backgroundColor = .clear
        serverIcon.roundCorners(.allCorners, radius: 25)
        serverIcon.layer.borderWidth = 1
        serverIcon.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        namingInfoView.roundCorners(.allCorners, radius: 20)
        namingInfoView.layer.borderWidth = 1
        namingInfoView.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        onlineStatusView.layer.cornerRadius = onlineStatusView.bounds.width / 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.serverIcon.image = nil
        
        imageRequest?.cancel()
        imageFetchOperation.cancel()
        imageDownloadOperation.cancel()
        imageApplyOperation.cancel()
        
        imageDataCallback = nil
        
        removeLoader()
    }
    
    private func configDefautFileds(server: ServerRealmSession) {
        name.text = server.name.uppercased()
        subName.text = server.address
        onlineStatusView.backgroundColor = server.statusEnum == .Online ? UIColor(named: "YellowSelectiveColor") : .red
    }
    
    func configWithImageData(server: ServerRealmSession) {
        configDefautFileds(server: server)
        if let imageData = server.imageData, let image = UIImage(data: imageData) {
            serverIcon.image = image
        }
    }
    
    func configWithOutImageData(server: ServerRealmSession, queue: DispatchQueue, completion: @escaping ImageDataCallback) {
        configDefautFileds(server: server)
        
        DispatchQueue.main.async {
            self.addLoader()
        }
        
        self.imageDataCallback = completion
        let imagePathName = server.imageFilePath
        
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
    
    private func addLoader() {
        loader.color = .black
        addSubview(loader)
        bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
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
}
