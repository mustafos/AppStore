//
//  Instrument.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizer

/// A tool represents a drawing tool and its corresponding tap and drawing handling methods.
/// Each tool has a corresponding DrawingViewController in order to interact with the canvas and
/// its many related objects.
protocol Instrument {
    func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: SkinDesignViewController)
    func handleDrawFrom(_ sender: UIPanGestureRecognizer, _ controller: SkinDesignViewController)
}
