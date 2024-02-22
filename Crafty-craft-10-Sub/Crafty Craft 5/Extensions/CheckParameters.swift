import UIKit

enum Device {
    static var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    static var iPad: Bool {
        return UIDevice().userInterfaceIdiom == .pad
    }

    static var smallDevice: Bool {
        return ScreenSize.height <= 834.0
    }
}

enum ScreenSize {
    static var height = UIScreen.main.bounds.size.height
}
