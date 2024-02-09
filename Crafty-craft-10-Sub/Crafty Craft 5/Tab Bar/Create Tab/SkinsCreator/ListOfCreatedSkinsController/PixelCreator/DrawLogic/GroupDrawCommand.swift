import Foundation

class GroupDrawCommand: Command {
    var drawCommands: Set<DrawCommand>

    init(drawCommands: Set<DrawCommand>) {
        self.drawCommands = drawCommands
        AppDelegate.log("groupDrawCommand Deinit")
    }

    init() {
        self.drawCommands = []
    }

    func execute() {
        drawCommands.forEach { $0.execute() }
    }

    func undo() {
        drawCommands.forEach { $0.undo() }
    }
    
    deinit {
        AppDelegate.log("groupDrawCommand Deinit")
    }
}

extension GroupDrawCommand: MultiCommand {
    func appendAndExecuteSingle(_ command: Command) {
        guard let drawCommand = command as? DrawCommand else {
            return
        }
        drawCommands.insert(drawCommand)
        drawCommand.execute()
    }
}
