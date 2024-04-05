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
    
    static let subFontUrl = Bundle.main.url(forResource: "sub", withExtension: "ttf")!
    static let adjustToken = "hfg1t85ufqbk"
    
    static let pushwooshToken = "276EA-D5266F" // EB2F0-2A4EE 80260-CE0A6 69D63-759DF 93B78-2277C 088C5-AAFF2
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
    
    static let unlockerFourSubscriptionID = "unlockFour"
    static let unlockerFourSubscriptionPushTag = "FourSubscription"
    
    static let unlockerFiveSubscriptionID = "unlockFive"
    static let unlockerFiveSubscriptionPushTag = "FiveSubscription"
    
    static let subscriptionSharedSecret = "2ec618c1169d437ea58575664d92e28d"
    
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
    //
    
    private func refactor_REFACTOR(_ kpop: Bool, biases: Bool, _wonderwhy: Int) -> Double {
        let firstBias = "Chaewon".count * 777
        let secondBias = "Wonyoung".count / 777
        let thirdWonderWhy: Double = Double("Chaewon".count * 777 + "Wonyoung".count / 777)
        return Double(Int(thirdWonderWhy * Double.random(in: 0...100)) + firstBias + secondBias)
    }
    
    //
    static let nameFileVideoForPhone = "phone"
    static let nameFileVideoForPad = "pad"
    static let nameFileVideoForPhoneContent = "phone2"
    static let nameFileVideoForPadContent = "pad2"
    static let nameFileVideoForPhoneFunc = "phone3"
    static let nameFileVideoForPadFunc = "pad3"
    static let nameFileVideoForPhoneThree = "phone4"
    static let nameFileVideoForPadThree = "pad4"
    static let nameFileVideoForPhoneFour = "phone5"
    static let nameFileVideoForPadFour = "pad5"
    static let nameFileVideoForPhoneFive = "phone6"
    static let nameFileVideoForPadFive = "pad6"
    static let videoFileType = "mp4"
}
