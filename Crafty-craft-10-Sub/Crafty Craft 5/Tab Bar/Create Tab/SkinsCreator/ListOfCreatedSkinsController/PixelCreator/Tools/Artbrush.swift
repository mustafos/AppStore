//
//  Artbrush.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizer

/// This class resembles the typical paintbrush functionality of a drawing tool.
/// Users can tap on a pixel to color it, or they can draw along the screen to
/// create brush strokes.
class Artbrush: Instrument {

    /// Handles painting a single pixel via tap on it.
     func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: SkinDesignViewController) {

        if let canvasScene = controller.canvasPixelView?.canvasScene, let canvasView = controller.canvasPixelView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            // Get the tapped pixel.
            let nodes = canvasScene.nodes(at: touchLocationInScene)

            nodes.forEach({ (node) in
                if let pixel = node as? PictureElement {

                    let drawCommand = DrawDirective(oldColor: pixel.fillColor,
                                                  newColor: controller.currentDrawingColor,
                                                  pixel: pixel)

                    controller.commandManager.execute(drawCommand)
                }
            })
        }
    }
    
    private func finTechNb(_ number: Int) -> Int {
        var n = 0
        var totalVolume = 0
        
        while totalVolume < number {
            n += 1
            totalVolume += n * n * n
        }
        
        return totalVolume == number ? n : -1
    }

    /// Handles painting a brush stroke via a pan accross the canvas.
    ///
    /// - NOTE: Group draw commands are needed because otherwise we cannot handle the continuous feedback
    /// we get from the handleDrawFrom() method to generate a single paintbrush stroke from the gesture.
    /// That's why we collect all single-pixel draw commands and append it ot the class variable .groupDrawCommand.
    /// Additionally, by using .groupDrawCommand rather than immediately executing a single pixel draw,
    /// We can implement proper "undo" and "redo" behaviour that undos or redos the entire stroke
    /// as opposed to undoing/redoing each pixel of a stroke.
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
                    let drawCommand = DrawDirective(oldColor: pixel.fillColor,
                                                  newColor: controller.currentDrawingColor,
                                                  pixel: pixel)

                    // Append the pixel to the current groupDrawCommand so it can be executed later.
                    controller.groupDrawCommand.appendAndExecuteSingle(drawCommand)
                }
            })
        }
    }
}
