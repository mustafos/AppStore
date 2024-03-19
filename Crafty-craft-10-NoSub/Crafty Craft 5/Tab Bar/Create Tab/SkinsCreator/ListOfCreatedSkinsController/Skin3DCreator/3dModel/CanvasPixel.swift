//
//  ScnPixel.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

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

    init(width: CGFloat, height: CGFloat) {
        super.init()

        self.geometry = SCNPlane(width: width, height: height)

        // Assign the material to the plane's geometry
        geometry?.firstMaterial?.diffuse.contents = fillColor
        geometry?.firstMaterial?.isDoubleSided = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
