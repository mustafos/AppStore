import UIKit

protocol Command {
    func execute()
    func undo()
    func redo()
}

extension Command {
    func redo() {
        execute()
    }
}
