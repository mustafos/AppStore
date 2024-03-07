//
//  GroupDrawDirective.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

class GroupDrawDirective: Directive {
    var drawCommands: Set<DrawDirective>

    init(drawCommands: Set<DrawDirective>) {
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

extension GroupDrawDirective: MultiDirective {
    func appendAndExecuteSingle(_ command: Directive) {
        guard let drawCommand = command as? DrawDirective else {
            return
        }
        drawCommands.insert(drawCommand)
        drawCommand.execute()
    }
}
