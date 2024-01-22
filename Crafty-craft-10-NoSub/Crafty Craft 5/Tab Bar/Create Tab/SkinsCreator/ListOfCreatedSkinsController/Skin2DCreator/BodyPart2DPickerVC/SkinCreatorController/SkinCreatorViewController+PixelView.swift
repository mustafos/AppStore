
import UIKit
import SpriteKit
import CoreGraphics


extension SkinCreatorViewController : UIGestureRecognizerDelegate {


    // MARK: - General Attributes.

     func registerGestureRecognizer() {

//         navigatorGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        navigatorGestureRecognizer.minimumNumberOfTouches = 2
        navigatorGestureRecognizer.delegate = self

        drawGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDrawFrom(_:)))
        drawGestureRecognizer.maximumNumberOfTouches = 1
         
         panForColorPickerRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGEtureforPicker(_:)))
         panForColorPickerRecognizer.maximumNumberOfTouches = 1

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(_:)))


        // Add to view
         canvasPixelView!.addGestureRecognizer(navigatorGestureRecognizer)
         canvasPixelView!.addGestureRecognizer(drawGestureRecognizer)
         canvasPixelView!.addGestureRecognizer(tapGestureRecognizer!)
         canvasPixelView?.addGestureRecognizer(panForColorPickerRecognizer)
         
         panForColorPickerRecognizer.isEnabled = false
    }
    
    

    @objc func handleDrawFrom(_ sender: UIPanGestureRecognizer) {
        if canDraw {
            currentTool?.handleDrawFrom(sender, self)
        }
    }

    @objc func handleTapFrom(_ sender: UITapGestureRecognizer) {
        currentTool?.handleTapFrom(sender, self)
    }
    
    @objc func didPanGEtureforPicker(_ recognizer: UIPanGestureRecognizer) {

        let location = recognizer.location(in: recognizer.view)

         switch recognizer.state {
         case .changed:
             guard let _ = canvasPixelView?.scene else {
                 AppDelegate.log("nil SKScene")
                 return
             }

             if let canvasScene = self.canvasPixelView?.canvasScene, let canvasView = self.canvasPixelView {

                 // Calculate correct location in terms of canvas and corresponding pixels.
                 let touchLocation = recognizer.location(in: recognizer.view)
                 let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

                 let nodes = canvasScene.nodes(at: touchLocationInScene)

                 // Get the touched pixel.
                 nodes.forEach({ (node) in
                     if let pixel = node as? Pixel {
                         let pixelColor = pixel.fillColor
                         magnifyingGlassView?.update(with: pixelColor, point: location)
                     }
                 })
             }
             
             
         case .ended, .cancelled:
             if let pickedColor = magnifyingGlassView?.backgroundColor {
                 colorsManager.addNewColor(pickedColor)
                 _currentDrawingColor = pickedColor
             }
//             getPixel
             hideMagnifyingGlass()

         default:
             break
         }
     }
    
    
}

extension SkinCreatorViewController {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

