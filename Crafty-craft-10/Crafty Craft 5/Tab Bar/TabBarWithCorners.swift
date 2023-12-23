//import UIKit
//
//@IBDesignable
//class TabBarWithCorners: UITabBar {
//    
//    // MARK: - Inspectable properties
//    @IBInspectable var color: UIColor?
//    @IBInspectable var radii: CGFloat = 0
//    
//    @IBInspectable var height: CGFloat = 0
//
//    // MARK: - Private properties
//    private var shapeLayer: CALayer?
//
//    // MARK: - Lifecycle methods
//    override func draw(_ rect: CGRect) {
//        addShape()
//    }
//    
//    
//
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var sizeThatFits = super.sizeThatFits(size)
//        if height > 0.0 {
//            sizeThatFits.height = height
//        }
//        return sizeThatFits
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Adjust translucency
//        self.isTranslucent = true
//        
//        // Adjust frame
//        var tabFrame = self.frame
//        let keyWindow = UIApplication.shared.keyWindow
//        
//        var offset: CGFloat = Device.iPad ? 0 : 60
//        
//        tabFrame.size.height = (keyWindow?.safeAreaInsets.bottom ?? .zero) + offset
//        tabFrame.origin.y = self.frame.origin.y + (self.frame.height - offset - (keyWindow?.safeAreaInsets.bottom ?? .zero))
//        
//        frame = tabFrame
//        
//        // Adjust tab title positions
//        items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) })
//    }
//
//    // MARK: - Private methods
//    private func addShape() {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = createPath()
//        shapeLayer.strokeColor = UIColor.white.cgColor
//        shapeLayer.fillColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 1)
//        shapeLayer.lineWidth = 2
//        shapeLayer.shadowColor = nil
//        shapeLayer.shadowOffset = CGSize(width: 0, height: -3)
//        shapeLayer.shadowOpacity = 0.2
//        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
//        
//        if let oldShapeLayer = self.shapeLayer {
//            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//        } else {
//            layer.insertSublayer(shapeLayer, at: 0)
//        }
//
//        self.shapeLayer = shapeLayer
//    }
//
//    private func createPath() -> CGPath {
//        let path = UIBezierPath(
//            roundedRect: bounds,
//            byRoundingCorners: [.topLeft, .topRight],
//            cornerRadii: CGSize(width: radii, height: 0.0)
//        )
//        return path.cgPath
//    }
//}
