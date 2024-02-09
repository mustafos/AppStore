
import Foundation
import UIKit

class DrawCommand: Command {
    let oldColor: UIColor
    let newColor: UIColor
    let pixel: Pixel

    init(oldColor: UIColor, newColor: UIColor, pixel: Pixel) {
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
}


// FIXME: - crash point
extension DrawCommand: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pixel)
    }

    static func == (lhs: DrawCommand, rhs: DrawCommand) -> Bool {
        return lhs.pixel == rhs.pixel
    }
}

//extension DrawCommand: Hashable {
//    static func == (lhs: DrawCommand, rhs: DrawCommand) -> Bool {
//        return lhs.pixel == rhs.pixel
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(pixel)
//    }
//}
