import UIKit

class BrashSizeView: UIView {
    
    @IBOutlet private var mainBrashSizeView: UIView!
    
    @IBOutlet private var brashSizeSlider: UISlider!
    
    weak var delegate: BrashSizeCangableDelegate?
    
    var currentBrashTool: ToolBar3DSelectedItem = .pencil {
        didSet {
            updateSliderValue()
            delegate?.changeBrashSize(to: brashSize)
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
        
        brashSizeSlider.addTarget(self, action: #selector(handleSliderChange(_:)), for: .valueChanged)
        
        addSubview(mainBrashSizeView)
    }
    
    private func updateSliderValue() {
        switch brashSize {
        case .one:
            brashSizeSlider.value = 0
        case .two:
            brashSizeSlider.value = 1
        case .four:
            brashSizeSlider.value = 2
        case .six:
            brashSizeSlider.value = 3
        case .eight:
            brashSizeSlider.value = 4
        }
    }
    
    @objc private func handleSliderChange(_ slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.value = roundedValue
        sizes[currentBrashTool] = BrashSize(rawValue: Int(roundedValue)) ?? .one
        delegate?.changeBrashSize(to: brashSize)
    }
    
    private func loadVolumeViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}
