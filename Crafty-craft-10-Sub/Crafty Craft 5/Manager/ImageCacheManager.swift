//
//  ImageCacheManager.swift
//  Crafty Craft 5
//
//  Created by dev on 28.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import Cache

class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    private let storage: Storage<String, Image>?
    
    private init() {
        let diskConfig = DiskConfig(
          // The name of disk storage, this will be used as folder name within directory
          name: "CraftyCraftCache",
          // Expiry date that will be applied by default for every added object
          // if it's not overridden in the `setObject(forKey:expiry:)` method
          expiry: .never,
          // Maximum size of the disk cache storage (in bytes)
          maxSize: 40000,
          // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
          directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("Preferences"),
          // Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
          protectionType: .complete
        )
        
        let memoryConfig = MemoryConfig(
          // Expiry date that will be applied by default for every added object
          // if it's not overridden in the `setObject(forKey:expiry:)` method
          expiry: .date(Date().addingTimeInterval(2*60)),
          /// The maximum number of objects in memory the cache should hold
          countLimit: 50,
          /// The maximum total cost that the cache can hold before it starts evicting objects
          totalCostLimit: 0
        )

        self.storage = try? Storage<String, Image>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forImage())
    }
    
    public func set(_ image: Image, forKey key: String) {
        try? storage?.setObject(image, forKey: key)
    }
    
    public func image(forKey key: String) -> Image? {
        try? storage?.entry(forKey: key).object ?? .none
    }
}
