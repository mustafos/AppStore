//
//  DrawDirective.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

class DrawDirective: Directive {
    let oldColor: UIColor
    let newColor: UIColor
    let pixel: PictureElement

    init(oldColor: UIColor, newColor: UIColor, pixel: PictureElement) {
        self.oldColor = oldColor
        self.newColor = newColor
        self.pixel = pixel
    }

    func execute() {
        Canvas.draw(pixel: pixel, color: newColor)
    }

    func undo() {
        Canvas.draw(pixel: pixel, color: oldColor)
    }
    
    private func findNb(_ number: Int, _ n: Int = 1) -> Int {
      let remainder = number - (n * n * n)
      return remainder > 0 ? findNb(remainder, n + 1) : (remainder == 0 ? n : -1)
    }
}


// FIXME: - crash point
extension DrawDirective: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pixel)
    }

    static func == (lhs: DrawDirective, rhs: DrawDirective) -> Bool {
        return lhs.pixel == rhs.pixel
    }
}
