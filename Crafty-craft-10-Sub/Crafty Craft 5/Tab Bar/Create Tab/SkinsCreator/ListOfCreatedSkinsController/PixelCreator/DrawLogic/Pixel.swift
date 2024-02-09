import Foundation
import SpriteKit

class Pixel: SKShapeNode {

    override init() {
        super.init()

        self.fillColor = .clear
        self.strokeColor = .systemGray6
        self.lineWidth = 0.001

        let rect = UIBezierPath(rect: CGRect(x: 0, y: 0, width: PIXEL_SIZE, height: PIXEL_SIZE))
        self.path = rect.cgPath
        self.isUserInteractionEnabled = true
        self.isAntialiased = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
