import SceneKit
import Foundation


class ScnPixel: SCNNode {
    
    var fillColor: UIColor = .systemGray4 {
        didSet {
            self.geometry?.materials[0].diffuse.contents = fillColor
        }
    }
    
    var strokeColor: UIColor = .systemGray5 {
        didSet {
            self.geometry?.materials[1].diffuse.contents = strokeColor
        }
    }
    
//    var borderWidth: CGFloat = 0.01 {
//        didSet {
//            self.geometry?.materials[1].setValue(borderWidth, forKey: "metalness")
//        }
//    }
    

    init(width: CGFloat, height: CGFloat) {
        super.init()

        self.geometry = SCNPlane(width: width, height: height)

        // Create a material for the plane node
//        let fillColorMaterial = SCNMaterial()
//        let borderMaterial = SCNMaterial()
//        fillColorMaterial.diffuse.contents = self.fillColor
//        borderMaterial.diffuse.contents = UIColor.black
//        borderMaterial.metalness.contents = NSNumber(value: 0.01)
        
        // Assign the material to the plane's geometry
//        self.geometry?.materials = [fillColorMaterial]
        geometry?.firstMaterial?.diffuse.contents = fillColor
        geometry?.firstMaterial?.isDoubleSided = true
//        self.geometry?.materials.forEach({ $0.isDoubleSided = true })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

