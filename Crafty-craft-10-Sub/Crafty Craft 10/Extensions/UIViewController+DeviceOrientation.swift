import UIKit

extension UIViewController {
    
    @objc var portraitSupportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /// This static property enforces the portrait orientation for all UIViewController instances
    /// by swizzling the supportedInterfaceOrientations method. The original method is replaced
    /// with a custom implementation (portraitSupportedInterfaceOrientations) that only allows
    /// portrait orientation.
    ///
    /// Usage:
    /// Call `UIViewController.enforcePortraitOrientation` once, typically in AppDelegate's
    /// didFinishLaunchingWithOptions method, to enforce portrait orientation throughout the app.
    ///
    /// Note: This approach should be used with caution, as it affects all view controllers
    /// in the application and may have unintended side effects.
    ///
    
    static let enforcePortraitOrientation: Void = {
        let originalSelector = #selector(getter: supportedInterfaceOrientations)
        let swizzledSelector = #selector(getter: portraitSupportedInterfaceOrientations)
        
        let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
        
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }()
}
