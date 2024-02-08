

import UIKit



class BrashSizeView: UIView {
    
    @IBOutlet private var mainBrashSizeView: UIView!
    
    @IBOutlet private var pointIndicatorBashSizeImages: [UIImageView]!
    

    @IBOutlet var sizeLabels: [UILabel]!
    
    weak var delegate: BrashSizeCangableDelegate?
    
    var currentBrashTool: ToolBar3DSelectedItem = .pencil {
        didSet {
            updateCurrentIndex()
            resetImages()
        }
    }
    
    private var sizes: [ToolBar3DSelectedItem: BrashSize] = [
        .pencil: .one,
        .eraser: .one,
        .brash: .one,
        .fill: .one,
        .noise: .one,
        .undo: .one,
    ]
    
    private var brashSize: BrashSize {
        sizes[currentBrashTool]!
    }
    
    private var currentIndex = 0 {
        didSet {
            resetImages()
            delegate?.changeBrashSize(to: brashSize)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        volumeViewNibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        volumeViewNibSetup()
    }
    
    
    private func volumeViewNibSetup() {
        mainBrashSizeView = loadVolumeViewFromNib()
        mainBrashSizeView.frame = bounds
        mainBrashSizeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainBrashSizeView.translatesAutoresizingMaskIntoConstraints = true
        
        updateCurrentIndex()
        
        for (index, pointIndicator) in pointIndicatorBashSizeImages.enumerated() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            pointIndicator.isUserInteractionEnabled = true
            pointIndicator.addGestureRecognizer(tapGesture)
            pointIndicator.tag = index
        }
        
        for (index, pointIndicator) in sizeLabels.enumerated() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            pointIndicator.isUserInteractionEnabled = true
            pointIndicator.addGestureRecognizer(tapGesture)
            pointIndicator.tag = index
        }
        
        addSubview(mainBrashSizeView)
    }
    
    private func updateCurrentIndex() {
        switch brashSize {
        case .one:
            currentIndex = 0
        case .two:
            currentIndex = 1
        case .four:
            currentIndex = 2
        case .six:
            currentIndex = 3
        case .eight:
            currentIndex = 4
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        currentIndex = gesture.view?.tag ?? 0
        
        resetImages()
    }
    
    private func resetImages() {
        pointIndicatorBashSizeImages.forEach { imag in
            if imag.tag == currentIndex {
                imag.image = UIImage(named: "brashSelectIcon")
                switch imag.tag {
                case 0:
                    sizes[currentBrashTool] = .one
                case 1:
                    sizes[currentBrashTool] = .two
                case 2:
                    sizes[currentBrashTool] = .four
                case 3:
                    sizes[currentBrashTool] = .six
                default:
                    sizes[currentBrashTool] = .eight
                }
            } else {
                imag.image = UIImage(named: "brushDot")
            }
        }
    }
    
    private func loadVolumeViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}
