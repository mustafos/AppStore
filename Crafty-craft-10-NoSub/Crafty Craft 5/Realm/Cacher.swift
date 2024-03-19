//
//  CustomImageLoader.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

open class CustomImageLoader: UIImageView {
    
    private let cache = ImageCacheManager.shared
    
    private var task: URLSessionTask?
    private lazy var loader = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.tintColor = .white
        return activityView
    }()
    
    func loadImage(from url: String, id: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else { return }
        self.image = nil
        
        task?.cancel()
        
        if let imageFromCache = cache.image(forKey: id) {
            self.image = imageFromCache
            completion(imageFromCache)
            return
        }
        
        addLoader()
        
        task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, let newImage = UIImage(data: data) else {
                return
            }

            self?.cache.set(newImage, forKey: id)
            
            DispatchQueue.main.async {
                self?.isHidden = false
                self?.image = newImage
                self?.loader.stopAnimating()
                completion(newImage)
            }
        }
        
        task?.resume()
    }
    
    func addLoader() {
        loader.color = .white
        addSubview(loader)
        bringSubviewToFront(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loader.startAnimating()
    }
    
    func removeLoader() {
        loader.removeFromSuperview()
    }
}
