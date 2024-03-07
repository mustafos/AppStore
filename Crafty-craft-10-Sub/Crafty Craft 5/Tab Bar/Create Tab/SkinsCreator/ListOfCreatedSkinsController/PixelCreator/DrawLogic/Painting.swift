//
//  Painting.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

public class Painting {
    
     public var width: Int64
     public var height: Int64
     public var colorArray: [UIColor]
     public var id: UUID


     init(colorArray: [UIColor], width: Int, height: Int) {

        self.height = Int64(height)
        self.width = Int64(width)
        self.colorArray = colorArray
        self.id = .init()
    }

    convenience init(drawing: Painting) {
        self.init(colorArray: drawing.colorArray, width: Int(drawing.width), height: Int(drawing.height))
    }
}
