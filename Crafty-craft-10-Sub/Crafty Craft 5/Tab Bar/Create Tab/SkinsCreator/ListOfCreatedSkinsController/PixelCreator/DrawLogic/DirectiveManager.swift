//
//  DirectiveManager.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

// Manages all commands for the canvas.
class DirectiveManager {
    var commandStack = [Directive]()
    var undoStack = [Directive]()

    func execute(_ command: Directive) {
        commandStack.append(command)
        command.execute()
        undoStack = []
    }

    func undo() {
        guard let command = commandStack.popLast() else {
            return
        }
        undoStack.append(command)
        command.undo()
    }

    func redo() {
        guard let command = undoStack.popLast() else {
            return
        }
        commandStack.append(command)
        command.redo()
    }
}
