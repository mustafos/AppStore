

import Foundation
import UIKit


struct SkinDrawCommand {
    var undoCommands = [SkinCommand]()
    var redoCommands = [SkinCommand]()
}

struct SkinCommand {
    var indexes = [Int]()
    var colors = [UIColor]()
    var nodeName = [String]()
    
    mutating func clearCommand() {
        indexes.removeAll()
        colors.removeAll()
        nodeName.removeAll()
    }
}
