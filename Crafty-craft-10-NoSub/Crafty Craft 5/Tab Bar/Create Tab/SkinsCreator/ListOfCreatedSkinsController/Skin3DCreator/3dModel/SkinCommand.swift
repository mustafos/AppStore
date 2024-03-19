//
//  SkinDrawCommand.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

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
