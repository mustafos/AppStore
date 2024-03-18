//
//  Configurations.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import CoreText

enum Configurations {
//    static let fontName = "PollerOne-Regular"
    static let subFontUrl = Bundle.main.url(forResource: "sub", withExtension: "ttf")!
    static let adjustToken = "hfg1t85ufqbk"
    
    static let pushwooshToken = "80260-CE0A6" // EB2F0-2A4EE 80260-CE0A6 69D63-759DF 93B78-2277C 088C5-AAFF2
    static let pushwooshAppName = "test"
    
    static let termsLink: String = "https://www.google.com"
    static let policyLink: String = "https://www.google.com"
    
    static let mainSubscriptionID = "main_sub"
    static let mainSubscriptionPushTag = "MainSubscription"
    
    //Content product
    static let unlockContentSubscriptionID = "unlockOne"
    static let unlockContentSubscriptionPushTag = "SecondSubscription"

    //AddonCreator Product
    static let unlockFuncSubscriptionID = "unlockTwo"
    static let unlockFuncSubscriptionPushTag = "SecondSubscription"

    //SkinCreator Product
    static let unlockerThreeSubscriptionID = "unlockThree"
    static let unlockerThreeSubscriptionPushTag = "FourSubscription"
    
    static let subscriptionSharedSecret = "253336a4821b43d0af174241a9a85f90"
    
    static func getSubFontName() -> String {
        let fontPath = Configurations.subFontUrl.path as CFString
        let fontURL = CFURLCreateWithFileSystemPath(nil, fontPath, CFURLPathStyle.cfurlposixPathStyle, false)
        
        guard let fontDataProvider = CGDataProvider(url: fontURL!) else {
            return ""
        }
        
        if let font = CGFont(fontDataProvider) {
            if let postScriptName = font.postScriptName as String? {
                return postScriptName
            }
        }
        
        return ""
    }
}

enum ConfigurationMediaSub {
    static let nameFileVideoForPhone = "phone"
    static let nameFileVideoForPad = "pad"
    static let videoFileType = "mp4"
}
