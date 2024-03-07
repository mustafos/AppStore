//
//  Directive.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

protocol Directive {
    func execute()
    func undo()
    func redo()
}

extension Directive {
    func redo() {
        execute()
    }
}
