

import Foundation
import UIKit

public class Drawing {
    
     public var width: Int64
     public var height: Int64
     public var colorArray: [UIColor]
   // @NSManaged public var thumbnail: Thumbnail
     public var id: UUID


     init(colorArray: [UIColor], width: Int, height: Int) {

        self.height = Int64(height)
        self.width = Int64(width)
        self.colorArray = colorArray
        self.id = .init()
    }

//    convenience init(colorArray: [UIColor], width: Int, height: Int) {
//        self.init(colorArray: colorArray, width: width, height: height)
//      //  self.thumbnail = thumbnail
//    }

    convenience init(drawing: Drawing) {
        self.init(colorArray: drawing.colorArray, width: Int(drawing.width), height: Int(drawing.height))
    }
}
