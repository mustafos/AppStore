import UIKit
import SwiftyDropbox
import FirebaseCore
import Adjust
import Pushwoosh
import AppTrackingTransparency
import AdSupport

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let pushwoosh = Pushwoosh.sharedInstance()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().isHidden = true
        
        UIViewController.enforcePortraitOrientation
        FirebaseApp.configure()
        
        let thirdPartyServicesManager = ThirdPartyServicesManager.shared
        thirdPartyServicesManager.initializeAdjust()
        thirdPartyServicesManager.initializePushwoosh(delegate: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ThirdPartyServicesManager.shared.makeATT()
        }
        
        setupTabBarchik()

        return true
    }
    
    private func setupTabBarchik() {
        let appearance = UITabBarItem.appearance()
        let tabbarFont = UIFont(name: "Montserrat-Medium", size: Device.iPhone ? 12 : 16)

        let attributes = [NSAttributedString.Key.font: tabbarFont, NSAttributedString.Key.foregroundColor: UIColor(red: 0.929, green: 0.823, blue: 0.674, alpha: 1)]
        let attributes2 = [NSAttributedString.Key.font: tabbarFont, NSAttributedString.Key.foregroundColor: UIColor(red: 0.235, green: 0.373, blue: 0.388, alpha: 1)]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .selected)
        appearance.setTitleTextAttributes(attributes2 as [NSAttributedString.Key : Any], for: .normal)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return DropboxClientsManager.handleRedirectURL(url) { authResult in
            guard let authResult = authResult else { return }
            switch authResult {
            case .success(let token):
                AppDelegate.log("Success! User is logged into Dropbox with token: \(token)")
            case .cancel:
                AppDelegate.log("User canceld OAuth flow.")
            case .error(let error, let description):
                AppDelegate.log("Error \(error): \(String(describing: description))")
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

extension AppDelegate : PWMessagingDelegate {
    
    //handle token received from APNS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Adjust.setDeviceToken(deviceToken)
        pushwoosh.handlePushRegistration(deviceToken)
    }
    
    //handle token receiving error
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        pushwoosh.handlePushRegistrationFailure(error);
    }
    
    //this is for iOS < 10 and for silent push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushwoosh.handlePushReceived(userInfo)
        completionHandler(.noData)
    }
    
    //this event is fired when the push gets received
    func pushwoosh(_ pushwoosh: Pushwoosh, onMessageReceived message: PWMessage) {
        AppDelegate.log("onMessageReceived: ", message.payload?.description ?? "error")
    }
    
    //this event is fired when a user taps the notification
    func pushwoosh(_ pushwoosh: Pushwoosh, onMessageOpened message: PWMessage) {
        AppDelegate.log("onMessageOpened: ", message.payload?.description ?? "error")
    }
}

extension AppDelegate {
    static func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
        print(items, separator: separator, terminator: terminator)
#else
        //do nothing
#endif
    }
}
