import UIKit

extension UIView {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        if let _ = UIGraphicsGetCurrentContext() {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}

extension UIView {
    func toImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}
