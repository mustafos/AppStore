import UIKit

extension UIView {
    /**
     Rounds the corners of a UIView.

     This function allows you to round the corners of a UIView either partially or fully. By default, it will round all corners. If you want to round only the bottom corners, pass `true` to the `onlyBottomCorners` parameter.

     - Parameters:
       - cornerRadius: The radius of the rounded corners. Must be a non-negative CGFloat value.
       - onlyBottomCorners: A Boolean value that indicates whether to round only the bottom corners. Default value is `false`.
*/
    
    func roundCorners(_ radius: CGFloat = 8, onlyBottomCorners: Bool = false) {
        layer.cornerRadius = radius
        clipsToBounds = true
        
        if onlyBottomCorners {
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 7
    }
}
