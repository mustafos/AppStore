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
            IAPManager.shared.validateSubscriptionWithCompletionHandler(productIdentifier: Configurations.mainSubscriptionID) { isPur in

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    switch isPur {
                    case true: self.l0adApp()
//                    case false: self.l0adApp()
                    case false: self.loadSubscription()
                    }
                }
                //             Validate ContentProductSub
                IAPManager.shared.validateSubscriptionWithCompletionHandler(productIdentifier: Configurations.unlockContentSubscriptionID) { isPur in

                    DispatchQueue.main.async() {
                        IAPManager.shared.contentSubIsVaild = isPur
                    }
                    
                    //             Validate AddonCreatorProductSub
                    IAPManager.shared.validateSubscriptionWithCompletionHandler(productIdentifier: Configurations.unlockFuncSubscriptionID) { isPur in
                        DispatchQueue.main.async() {
                            IAPManager.shared.addonCreatorIsValid = isPur
                        }
                        
                        //             Validate SkinCreatorProductSub
                        IAPManager.shared.validateSubscriptionWithCompletionHandler(productIdentifier: Configurations.unlockerThreeSubscriptionID) { isPur in
                            DropBoxParserFiles.shared.zetupDropBox()
                            DispatchQueue.main.async() {
                                IAPManager.shared.skinCreatorSubIsValid = isPur
                            }
                        }
                    }
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
