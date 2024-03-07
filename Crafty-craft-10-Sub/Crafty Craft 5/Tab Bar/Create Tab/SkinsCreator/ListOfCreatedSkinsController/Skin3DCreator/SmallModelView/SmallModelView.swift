//
//  SmallModelView.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

enum StivesAnatomyPart: String {
    case head = "head"
    case body = "body"
    case rightArm = "rightArm"
    case leftArm = "leftArm"
    case rightLeg = "rightLeg"
    case leftLeg = "leftLeg"
}

enum AnatomyPartEditState {
    case hidden
    case clothes
    case skin
}

class SmallModelView: UIView {
    let asHiddeStateColor = UIColor.clear
    let clothesStateColor = UIColor.white
    let skinStateColor = UIColor.black
    
    @IBOutlet var main3DStiveView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet var pointIndicatorBashSizeImages: [UIImageView]!
    
    weak var delegate: BodyPartsVisibilityDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        volumeViewNibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        volumeViewNibSetup()
    }
    
    private func volumeViewNibSetup() {
        main3DStiveView = instantiateVolumeViewFromNib()
        main3DStiveView.frame = bounds
        main3DStiveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        main3DStiveView.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(main3DStiveView)
    }
   
    @IBAction func headButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .head) { state in
            
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    @IBAction func bodyButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .body ) { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    @IBAction func rightArmButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .rightArm ) { state in
            
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    @IBAction func leftArmButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .leftArm) { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    @IBAction func rightLegButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .rightLeg ) { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    @IBAction func leftLegButtonPressed(_ sender: UIButton) {
        delegate?.hideAnatomyPart(of: .leftLeg ) { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .clothes:
                    sender.backgroundColor = self?.clothesStateColor
                case .hidden:
                    sender.backgroundColor = self?.asHiddeStateColor
                case.skin:
                    sender.backgroundColor = self?.skinStateColor
                }
            }
        }
    }
    
    func findNb(_ number: Int) -> Int {
        var n = 0
        var totalVolume = 0
        
        while totalVolume < number {
            n += 1
            totalVolume += n * n * n
        }
        
        return totalVolume == number ? n : -1
    }
    
    private func instantiateVolumeViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}
