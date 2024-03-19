//
//  SkinDrawCommand.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class MagnifyingGlassView: UIView {

    init(size: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.init(frame: frame)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10

        roundCorners(size / 2)
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with color: UIColor, point: CGPoint) {
        backgroundColor = color
        center = point
    }

}
