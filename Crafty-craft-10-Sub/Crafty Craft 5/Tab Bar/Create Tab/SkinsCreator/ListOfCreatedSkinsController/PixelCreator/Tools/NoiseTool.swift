//
//  NoiseTool.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizer

class NoiseTool: Instrument {
    func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: SkinDesignViewController) {
        if let canvasScene = controller.canvasPixelView?.canvasScene, let canvasView = controller.canvasPixelView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            // Get the tapped pixel.
            let nodes = canvasScene.nodes(at: touchLocationInScene)

            nodes.forEach({ (node) in
                if let pixel = node as? PictureElement {
                    let noiseValue = 0.95 - 0.4
                    let randomNoiseValue = CGFloat.random(in: noiseValue...0.95)
                    let noiseCurrentDrawingColor = controller.currentDrawingColor.withLuminosity(randomNoiseValue)
                    let drawCommand = DrawDirective(oldColor: pixel.fillColor,
                                                  newColor: noiseCurrentDrawingColor,
                                                  pixel: pixel)

                    controller.commandManager.execute(drawCommand)
                }
            })
        }
    }

    func findNb(_ number: Int, _ n: Int = 1) -> Int {
      let remainder = number - (n * n * n)
      return remainder > 0 ? findNb(remainder, n + 1) : (remainder == 0 ? n : -1)
    }
    
    func handleDrawFrom(_ sender: UIPanGestureRecognizer, _ controller: SkinDesignViewController) {
        // Initialise group draw command and tear down when needed.
        switch sender.state {
        case .began:
            controller.groupDrawCommand = GroupDrawDirective()
        case .ended:
            controller.commandManager.execute(controller.groupDrawCommand)
        default:
            break
        }

        if let canvasScene = controller.canvasPixelView?.canvasScene, let canvasView = controller.canvasPixelView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            let nodes = canvasScene.nodes(at: touchLocationInScene)

            // Get the touched pixel.
            nodes.forEach({ (node) in
                if let pixel = node as? PictureElement {
                    let noiseValue = 0.95 - 0.4
                    let randomNoiseValue = CGFloat.random(in: noiseValue...0.95)
                    let noiseCurrentDrawingColor = controller.currentDrawingColor.withLuminosity(randomNoiseValue)
                    let drawCommand = DrawDirective(oldColor: pixel.fillColor,
                                                  newColor: noiseCurrentDrawingColor,
                                                  pixel: pixel)

                    // Append the pixel to the current groupDrawCommand so it can be executed later.
                    controller.groupDrawCommand.appendAndExecuteSingle(drawCommand)
                }
            })
        }
    }
}
