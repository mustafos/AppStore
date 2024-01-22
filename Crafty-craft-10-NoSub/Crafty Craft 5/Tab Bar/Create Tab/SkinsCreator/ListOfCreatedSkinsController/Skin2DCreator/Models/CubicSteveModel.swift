struct BodyPartSide {
    let top: Side
    let bottom: Side
    let right: Side
    let front: Side
    let left: Side
    let back: Side
}

extension BodyPartSide {
    static func * (left: BodyPartSide, right: Int) -> BodyPartSide {
        BodyPartSide(top: left.top * right,
                     bottom: left.bottom * right,
                     right: left.right * right,
                     front: left.front * right,
                     left: left.left * right,
                     back: left.back * right)
    }
}


struct Side {
    let name: String
    let width: Int
    let height: Int
    let startX: Int
    let startY: Int
    
    
    init(name: String, width: Int, height: Int, startX: Int, startY: Int) {
        self.name = name
        self.width = width
        self.height = height
        self.startX = startX
        self.startY = startY
    }
}

extension Side {
    static func * (left: Side, right: Int) -> Side {
        Side(name: left.name,
             width: left.width * right,
             height: left.height * right,
             startX: left.startX * right,
             startY: left.startY * right)
    }
}


enum CubicHuman {
    enum BodyPart {
        
        static let head = BodyPartSide(
            top: Side(name: "headTop", width: 8, height: 8, startX: 8, startY: 0),
            bottom: Side(name: "headBottom", width: 8, height: 8, startX: 16, startY: 0),
            right: Side(name: "headRight", width: 8, height: 8, startX: 24, startY: 8),
            front: Side(name: "headFront", width: 8, height: 8, startX: 8, startY: 8),
            left: Side(name: "headLeft", width: 8, height: 8, startX: 0, startY: 8),
            back: Side(name: "headBack", width: 8, height: 8, startX: 16, startY: 8)
        )
        
        static let head1 = BodyPartSide(
            top: Side(name: "headTop1", width: 8, height: 8, startX: 40, startY: 0),
            bottom: Side(name: "headBottom1", width: 8, height: 8, startX: 48, startY: 0),
            right: Side(name: "headRight1", width: 8, height: 8, startX: 32, startY: 8),
            front: Side(name: "headFront1", width: 8, height: 8, startX: 40, startY: 8),
            left: Side(name: "headLeft1", width: 8, height: 8, startX: 48, startY: 8),
            back: Side(name: "headBack1", width: 8, height: 8, startX: 56, startY: 8)
        )
        
        static let body = BodyPartSide(
            top: Side(name: "bodyTop", width: 8, height: 4, startX: 20, startY: 16),
            bottom: Side(name: "bodyBottom", width: 8, height: 4, startX: 28, startY: 16),
            right: Side(name: "bodyRight", width: 4, height: 12, startX: 16, startY: 20),
            front: Side(name: "bodyFront", width: 8, height: 12, startX: 20, startY: 20),
            left: Side(name: "bodyLeft", width: 4, height: 12, startX: 28, startY: 20),
            back: Side(name: "bodyBack", width: 8, height: 12, startX: 32, startY: 20)
        )
        
        static let body1 = BodyPartSide(
            top: Side(name: "bodyTop1", width: 8, height: 4, startX: 20, startY: 32),
            bottom: Side(name: "bodyBottom1", width: 8, height: 4, startX: 28, startY: 32),
            right: Side(name: "bodyRight1", width: 4, height: 12, startX: 16, startY: 36),
            front: Side(name: "bodyFront1", width: 8, height: 12, startX: 20, startY: 36),
            left: Side(name: "bodyLeft1", width: 4, height: 12, startX: 28, startY: 36),
            back: Side(name: "bodyBack1", width: 8, height: 12, startX: 32, startY: 36)
        )
        
        static let leftArm = BodyPartSide(
            top: Side(name: "leftArmTop", width: 4, height: 4, startX: 36, startY: 48),
            bottom: Side(name: "leftArmBottom", width: 4, height: 4, startX: 40, startY: 48),
            right: Side(name: "leftArmRight", width: 4, height: 12, startX: 32, startY: 52),
            front: Side(name: "leftArmFront", width: 4, height: 12, startX: 36, startY: 52),
            left: Side(name: "leftArmLeft", width: 4, height: 12, startX: 40, startY: 52),
            back: Side(name: "leftArmBack", width: 4, height: 12, startX: 44, startY: 52)
        )
        
        static let leftArm1 = BodyPartSide(
            top: Side(name: "leftArmTop1", width: 4, height: 4, startX: 44, startY: 48),
            bottom: Side(name: "leftArmBottom1", width: 4, height: 4, startX: 48, startY: 48),
            right: Side(name: "leftArmRight1", width: 4, height: 12, startX: 40, startY: 52),
            front: Side(name: "leftArmFront1", width: 4, height: 12, startX: 44, startY: 52),
            left: Side(name: "leftArmLeft1", width: 4, height: 12, startX: 48, startY: 52),
            back: Side(name: "leftArmBack1", width: 4, height: 12, startX: 52, startY: 52)
        )
        
        static let rightArm = BodyPartSide(
            top: Side(name: "rightArmTop", width: 4, height: 4, startX: 44, startY: 16),
            bottom: Side(name: "rightArmBottom", width: 4, height: 4, startX: 48, startY: 16),
            right: Side(name: "rightArmRight", width: 4, height: 12, startX: 40, startY: 20),
            front: Side(name: "rightArmFront", width: 4, height: 12, startX: 44, startY: 20),
            left: Side(name: "rightArmLeft", width: 4, height: 12, startX: 48, startY: 20),
            back: Side(name: "rightArmBack", width: 4, height: 12, startX: 52, startY: 20)
        )
        
        static let rightArm1 = BodyPartSide(
            top: Side(name: "rightArmTop1", width: 4, height: 4, startX: 44, startY: 32),
            bottom: Side(name: "rightArmBottom1", width: 4, height: 4, startX: 48, startY: 32),
            right: Side(name: "rightArmRight1", width: 4, height: 12, startX: 40, startY: 36),
            front: Side(name: "rightArmFront1", width: 4, height: 12, startX: 44, startY: 36),
            left: Side(name: "rightArmLeft1", width: 4, height: 12, startX: 48, startY: 36),
            back: Side(name: "rightArmBack1", width: 4, height: 12, startX: 52, startY: 36)
        )
        
        static let leftLeg = BodyPartSide(
            top: Side(name: "leftLegTop", width: 4, height: 4, startX: 20, startY: 48),
            bottom: Side(name: "leftLegBottom", width: 4, height: 4, startX: 24, startY: 48),
            right: Side(name: "leftLegRight", width: 4, height: 12, startX: 16, startY: 52),
            front: Side(name: "leftLegFront", width: 4, height: 12, startX: 20, startY: 52),
            left: Side(name: "leftLegLeft", width: 4, height: 12, startX: 24, startY: 52),
            back: Side(name: "leftLegBack", width: 4, height: 12, startX: 28, startY: 52)
        )
        
        static let leftLeg1 = BodyPartSide(
            top: Side(name: "leftLegTop1", width: 4, height: 4, startX: 4, startY: 48),
            bottom: Side(name: "leftLegBottom1", width: 4, height: 4, startX: 8, startY: 48),
            right: Side(name: "leftLegRight1", width: 4, height: 12, startX: 0, startY: 52),
            front: Side(name: "leftLegFront1", width: 4, height: 12, startX: 4, startY: 52),
            left: Side(name: "leftLegLeft1", width: 4, height: 12, startX: 8, startY: 52),
            back: Side(name: "leftLegBack1", width: 4, height: 12, startX: 12, startY: 52)
        )
    
        static let rightLeg = BodyPartSide(
            top: Side(name: "rightLegTop", width: 4, height: 4, startX: 4, startY: 16),
            bottom: Side(name: "rightLegBottom", width: 4, height: 4, startX: 8, startY: 16),
            right: Side(name: "rightLegRight", width: 4, height: 12, startX: 0, startY: 20),
            front: Side(name: "rightLegFront", width: 4, height: 12, startX: 4, startY: 20),
            left: Side(name: "rightLegLeft", width: 4, height: 12, startX: 8, startY: 20),
            back: Side(name: "rightLegBack", width: 4, height: 12, startX: 12, startY: 20)
        )
        
        static let rightLeg1 = BodyPartSide(
            top: Side(name: "rightLegTop1", width: 4, height: 4, startX: 4, startY: 32),
            bottom: Side(name: "rightLegBottom1", width: 4, height: 4, startX: 8, startY: 32),
            right: Side(name: "rightLegRight1", width: 4, height: 12, startX: 0, startY: 36),
            front: Side(name: "rightLegFront1", width: 4, height: 12, startX: 4, startY: 36),
            left: Side(name: "rightLegLeft1", width: 4, height: 12, startX: 8, startY: 36),
            back: Side(name: "rightLegBack1", width: 4, height: 12, startX: 12, startY: 36)
        )
        
        //Doesnt include any of hatSides as is available only on 2D & could be deleted
        static func allSides() -> [Side] {
            let sides: [Side] = [
                head.top, head.bottom, head.right, head.left, head.front, head.back,
                body.top, body.bottom, body.right, body.left, body.front, body.back,
                leftArm.top, leftArm.bottom, leftArm.right, leftArm.left, leftArm.front, leftArm.back,
                rightArm.top, rightArm.bottom, rightArm.right, rightArm.left, rightArm.front, rightArm.back,
                leftLeg.top, leftLeg.bottom, leftLeg.right, leftLeg.left, leftLeg.front, leftLeg.back,
                rightLeg.top, rightLeg.bottom, rightLeg.right, rightLeg.left, rightLeg.front, rightLeg.back,
                //overlay
                head1.top, head1.bottom, head1.right, head1.left, head1.front, head1.back,
                body1.top, body1.bottom, body1.right, body1.left, body1.front, body1.back,
                leftArm1.top, leftArm1.bottom, leftArm1.right, leftArm1.left, leftArm1.front, leftArm1.back,
                rightArm1.top, rightArm1.bottom, rightArm1.right, rightArm1.left, rightArm1.front, rightArm1.back,
                leftLeg1.top, leftLeg1.bottom, leftLeg1.right, leftLeg1.left, leftLeg1.front, leftLeg1.back,
                rightLeg1.top, rightLeg1.bottom, rightLeg1.right, rightLeg1.left, rightLeg1.front, rightLeg1.back
            ]
            return sides
        }
        
        //MARK: 128x128 size
        
        static let head_128 = head * 2
        
        static let head1_128 = head1 * 2
        
        static let body_128 = body * 2
        
        static let body1_128 = body1 * 2
        
        static let leftArm_128 = leftArm * 2
        
        static let leftArm1_128 = leftArm1 * 2
        
        static let rightArm_128 = rightArm * 2
        
        static let rightArm1_128 = rightArm1 * 2
        
        static let leftLeg_128 = leftLeg * 2
        
        static let leftLeg1_128 = leftLeg1 * 2
        
        static let rightLeg_128 = rightLeg * 2
        
        static let rightLeg1_128 = rightLeg1 * 2
        
        //Doesnt include any of hatSides as is available only on 2D & could be deleted
        static func allSides128() -> [Side] {
            let sides: [Side] = [
                head_128.top, head_128.bottom, head_128.right, head_128.left, head_128.front, head_128.back,
                body_128.top, body_128.bottom, body_128.right, body_128.left, body_128.front, body_128.back,
                leftArm_128.top, leftArm_128.bottom, leftArm_128.right, leftArm_128.left, leftArm_128.front, leftArm_128.back,
                rightArm_128.top, rightArm_128.bottom, rightArm_128.right, rightArm_128.left, rightArm_128.front, rightArm_128.back,
                leftLeg_128.top, leftLeg_128.bottom, leftLeg_128.right, leftLeg_128.left, leftLeg_128.front, leftLeg_128.back,
                rightLeg_128.top, rightLeg_128.bottom, rightLeg_128.right, rightLeg_128.left, rightLeg_128.front, rightLeg_128.back,
                //overlay
                head1_128.top, head1_128.bottom, head1_128.right, head1_128.left, head1_128.front, head1_128.back,
                body1_128.top, body1_128.bottom, body1_128.right, body1_128.left, body1_128.front, body1_128.back,
                leftArm1_128.top, leftArm1_128.bottom, leftArm1_128.right, leftArm1_128.left, leftArm1_128.front, leftArm1_128.back,
                rightArm1_128.top, rightArm1_128.bottom, rightArm1_128.right, rightArm1_128.left, rightArm1_128.front, rightArm1_128.back,
                leftLeg1_128.top, leftLeg1_128.bottom, leftLeg1_128.right, leftLeg1_128.left, leftLeg1_128.front, leftLeg1_128.back,
                rightLeg1_128.top, rightLeg1_128.bottom, rightLeg1_128.right, rightLeg1_128.left, rightLeg1_128.front, rightLeg1_128.back
            ]
            return sides
        }

    }

}

