//
//  UnprocessedPixel.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

let RAWPIXEL_CONVERSION_ERR_CODE = 2619

// Helper class for making colors exportable to CGImage.
struct UnprocessedPixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8

    init(inputColor: UIColor) throws {
        guard let (r, g, b, a) = inputColor.rgb() else {
            throw NSError(domain: "RawPixel Conversion", code: RAWPIXEL_CONVERSION_ERR_CODE, userInfo: nil)
        }
        self.r = UInt8(r)
        self.g = UInt8(g)
        self.b = UInt8(b)
        self.a = UInt8(a)
    }
}
