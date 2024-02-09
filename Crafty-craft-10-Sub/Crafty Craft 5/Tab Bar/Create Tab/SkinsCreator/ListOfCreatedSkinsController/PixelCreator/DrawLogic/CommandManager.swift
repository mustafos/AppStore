import Foundation

// Manages all commands for the canvas.
class CommandManager {
    var commandStack = [Command]()
    var undoStack = [Command]()

    func execute(_ command: Command) {
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
