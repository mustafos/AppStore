

import UIKit

enum StivesBodyPart: String {
    case head = "head"
    case body = "body"
    case rightArm = "rightArm"
    case leftArm = "leftArm"
    case rightLeg = "rightLeg"
    case leftLeg = "leftLeg"
}

enum BodyPartEditState {
    case hidden
    case clothes
    case skin
}

class SmallModelView: UIView {
    
    let asHiddeStateColor = UIColor.white
    let clothesStateColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let skinStateColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    @IBOutlet var main3DStiveView: UIView!
        
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet var pointIndicatorBashSizeImages: [UIImageView]!
    
        
    weak var delegate: BodyPartsHiddebleDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        volumeViewNibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        volumeViewNibSetup()
    }
    
    
    private func volumeViewNibSetup() {
        main3DStiveView = loadVolumeViewFromNib()
        main3DStiveView.frame = bounds
        main3DStiveView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        main3DStiveView.translatesAutoresizingMaskIntoConstraints = true
        
       
        
        
        addSubview(main3DStiveView)
    }
    
    @IBAction func headButtonPressed(_ sender: UIButton) {
        delegate?.hideBodyPart(of: .head) { state in
            
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
        delegate?.hideBodyPart(of: .body ) { state in

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
        delegate?.hideBodyPart(of: .rightArm ) { state in

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
        delegate?.hideBodyPart(of: .leftArm) { state in

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
        delegate?.hideBodyPart(of: .rightLeg ) { state in

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
        delegate?.hideBodyPart(of: .leftLeg ) { state in

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
    
    
    
    
    private func loadVolumeViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}
