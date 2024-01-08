import UIKit

class CustomToolPickerView : UIView {
    // MARK: - Inspectable Properties

//    @IBInspectable var color: UIColor?
//    @IBInspectable var radii: CGFloat = 15.0
//
//    // MARK: - Private Properties
//
//    private var shapeLayer: CALayer?
//
//    // MARK: - Lifecycle
//
//    override func draw(_ rect: CGRect) {
//        addShape()
//    }
//
//    // MARK: - Private Methods
//
//    private func addShape() {
//        let shapeLayer = createShapeLayer()
//        replaceOrInsertShapeLayer(shapeLayer)
//        self.shapeLayer = shapeLayer
//    }
//
//    private func createShapeLayer() -> CAShapeLayer {
//        let shapeLayer = CAShapeLayer()
//
//        shapeLayer.path = createPath()
//        shapeLayer.strokeColor = UIColor.gray.withAlphaComponent(0.1).cgColor
//        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
//        shapeLayer.lineWidth = 2
//        shapeLayer.shadowColor = UIColor.black.cgColor
//        shapeLayer.shadowOffset = CGSize(width: 0, height: -3)
//        shapeLayer.shadowOpacity = 0.2
//        shapeLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
//
//        return shapeLayer
//    }
//
//    private func replaceOrInsertShapeLayer(_ shapeLayer: CAShapeLayer) {
//        if let oldShapeLayer = self.shapeLayer {
//            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
//        } else {
//            layer.insertSublayer(shapeLayer, at: 0)
//        }
//    }
//
//    private func createPath() -> CGPath {
//        let path = UIBezierPath(
//            roundedRect: bounds,
//            byRoundingCorners: [.topLeft, .topRight],
//            cornerRadii: CGSize(width: radii, height: 0.0))
//
//        return path.cgPath
//    }
}
