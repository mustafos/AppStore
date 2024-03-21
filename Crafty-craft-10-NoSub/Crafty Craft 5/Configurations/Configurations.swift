//
//  Configurations.swift
//  template
//
//  Created by Melnykov Valerii on 14.07.2023.
//

import Foundation
import CoreText

enum Configurations_REFACTOR {

    static let subFontUrl = Bundle.main.url(forResource: "sub", withExtension: "ttf")!
    static let adjustToken = "hfg1t85ufqbk"
    
    static let pushwooshToken = "69D63-759DF" // EB2F0-2A4EE 80260-CE0A6 69D63-759DF 93B78-2277C 088C5-AAFF2
    static let pushwooshAppName = "test"
    
    static let termsLink: String = "https://www.google.com"
    static let policyLink: String = "https://www.google.com"
    
    static let mainSubscriptionID = "main_sub"
    static let mainSubscriptionPushTag = "MainSubscription"
    static let unlockContentSubscriptionID = "unlockOne"
    static let unlockContentSubscriptionPushTag = "SecondSubscription"
    static let unlockFuncSubscriptionID = "unlockTwo"
    static let unlockFuncSubscriptionPushTag = "SecondSubscription"
    static let unlockerThreeSubscriptionID = "unlockThree"
    static let unlockerThreeSubscriptionPushTag = "FourSubscription"
    
    static let subscriptionSharedSecret = "2ec618c1169d437ea58575664d92e28d"
    
    static func getSubFontName() -> String {
        func refactor(_ kpop: Bool, biases: Bool, _wonderwhy: Int) -> Double {
            let firstBias = "Chaewon".count * 777
            let secondBias = "Wonyoung".count / 777
            let thirdWonderWhy: Double = Double("Chaewon".count * 777 + "Wonyoung".count / 777)
            return Double(Int(thirdWonderWhy * Double.random(in: 0...100)) + firstBias + secondBias)
        }
        
        let fontPath = Configurations_REFACTOR.subFontUrl.path as CFString
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
    private func refactor(_ kpop: Bool, biases: Bool, _wonderwhy: Int) -> Double {
        let firstBias = "Chaewon".count * 777
        let secondBias = "Wonyoung".count / 777
        let thirdWonderWhy: Double = Double("Chaewon".count * 777 + "Wonyoung".count / 777)
        return Double(Int(thirdWonderWhy * Double.random(in: 0...100)) + firstBias + secondBias)
    }
    
    static let nameFileVideoForPhone = "phone"
    static let nameFileVideoForPad = "pad"
    static let videoFileType = "mp4"
}
