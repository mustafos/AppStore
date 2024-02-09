//  Created by Melnykov Valerii on 14.07.2023
//


import Foundation
import UIKit


extension UIView {
    public func fixInView(_ container: UIView!) -> Void{
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    public func onClick(target: Any, _ selector: Selector) {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: selector)
        addGestureRecognizer(tap)
    }
    
    public  func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    public  var renderedImage: UIImage {
        // rect of capure
        let rect = self.bounds
        
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        self.layer.render(in: context)
        // self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
    
    public func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    public  func fadeOut(duration: TimeInterval = 1.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.isHidden = true
            self.alpha = 0.0
        }, completion: completion)
    }
    
    public  func vibto(style : UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    public func drawBorder(edges: [UIRectEdge], borderWidth: CGFloat, color: UIColor, margin: CGFloat) {
        for item in edges {
            let borderLayer: CALayer = CALayer()
            borderLayer.borderColor = color.cgColor
            borderLayer.borderWidth = borderWidth
            switch item {
            case .top:
                borderLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: borderWidth)
            case .left:
                borderLayer.frame =  CGRect(x: 0, y: margin, width: borderWidth, height: frame.height - (margin*2))
            case .bottom:
                borderLayer.frame = CGRect(x: 0, y: frame.height - borderWidth, width: frame.width, height: borderWidth)
            case .right:
                borderLayer.frame = CGRect(x: frame.width - borderWidth, y: margin, width: borderWidth, height: frame.height - (margin*2))
            case .all:
                drawBorder(edges: [.top, .left, .bottom, .right], borderWidth: borderWidth, color: color, margin: margin)
            default:
                break
            }
            self.layer.addSublayer(borderLayer)
        }
    }
}

extension UIView {
    
    func pushTransition(duration:CFTimeInterval, animationSubType: String) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = convertToOptionalCATransitionSubtype(animationSubType)
        animation.duration = duration
        self.layer.add(animation, forKey: convertFromCATransitionType(CATransitionType.push))
    }
    
     func convertFromCATransitionSubtype(_ input: CATransitionSubtype) -> String {
        return input.rawValue
    }
    
     func convertToOptionalCATransitionSubtype(_ input: String?) -> CATransitionSubtype? {
        guard let input = input else { return nil }
        return CATransitionSubtype(rawValue: input)
    }
    
     func convertFromCATransitionType(_ input: CATransitionType) -> String {
        return input.rawValue
    }
}


extension UILabel {
    func setShadow(with opacity: Float = 1.0){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.masksToBounds = false
    }
}

extension String {
    var underLined: NSAttributedString {
        NSMutableAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
}
extension String {
    func openURL(){
        if let url = URL(string: self) {
            UIApplication.shared.impactFeedbackGenerator(type: .medium)
            UIApplication.shared.open(url)
        }
    }
}

extension UIApplication {
   func setRootVC(_ vc : UIViewController){
       self.windows.first?.rootViewController = vc
       self.windows.first?.makeKeyAndVisible()
     }
 }


extension UIApplication {
    func notificationFeedbackGenerator(type : UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impactFeedbackGenerator(type : UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

extension UIApplication {
    func isIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
}
extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally, animated: Bool = true) {
        let lastSection = numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastItem = numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else { return }
        let lastItemIndexPath = IndexPath(item: lastItem, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: scrollPosition, animated: animated)
    }
}
