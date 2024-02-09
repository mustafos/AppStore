import Foundation


protocol MultiCommand {
    func appendAndExecuteSingle(_ command: Command)
}
