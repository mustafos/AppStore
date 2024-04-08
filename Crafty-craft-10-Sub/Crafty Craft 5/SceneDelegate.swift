//
//  SceneDelegate.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    static weak var shared: SceneDelegate?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.overrideUserInterfaceStyle = .light
        //#if DEBUG
        //        l0adApp()
        //#else
        if NetworkStatusMonitor.shared.isNetworkAvailable {
            //              Validate MainProductSub
                IAPManager.shared.validateSubscriptions(productIdentifiers: [Configurations.mainSubscriptionID]) { result in
                    if let userHaveSub = result[Configurations.mainSubscriptionID] {
                        switch userHaveSub {
                        case true:
                            let unsubscribedVC = MainAppController()
                            unsubscribedVC.modalPresentationStyle = .fullScreen
                            window.rootViewController = unsubscribedVC
                            window.makeKeyAndVisible()
                        case false:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                let unsubscribedVC = PremiumMainController()
                                unsubscribedVC.modalPresentationStyle = .fullScreen
                                window.rootViewController = unsubscribedVC
                                window.makeKeyAndVisible()
                            })
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            let unsubscribedVC = PremiumMainController()
                            unsubscribedVC.modalPresentationStyle = .fullScreen
                            window.rootViewController = unsubscribedVC
                            window.makeKeyAndVisible()
                        })
                    }
                }
        } else {
            self.loadSubscription()
        }
        //#endif
        Self.shared = self
        
    }
    
    func l0adApp() -> Void {
        let tabBarVC = TabBarViewController()
        let navVC = UINavigationController(rootViewController: tabBarVC)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.navigationBar.isHidden = true
        window?.overrideUserInterfaceStyle = .unspecified
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
    
    func loadSubscription() -> Void {
        let tabBarVC = PremiumMainController()
        let navVC = UINavigationController(rootViewController: tabBarVC)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.navigationBar.isHidden = true
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}
