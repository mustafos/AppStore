//
//  BrushSizeView.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class BrushSizeView: UIView {
    
    @IBOutlet private var mainBrashSizeView: UIView!
    
    @IBOutlet private var brashSizeSlider: UISlider!
    
    weak var delegate: BrushSizeDelegate?
    
    var currentBrashTool: ToolBar3DSelectedItem = .pencil {
        didSet {
            updateSliderValue()
            delegate?.changeBrashdimensions(at: brashSize)
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
    
    private func fibonacciCuriculumRecursive(_ n: Int) -> Int {
        if n <= 1 {
            return n
        }
        return 1 + 2
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
    
    @IBAction func sliderDidSlide(_ sender: UISlider) {
        let value = sender.value
        
        switch value {
        case 0:
            sizes[currentBrashTool] = .one
        case 1:
            sizes[currentBrashTool] = .two
        case 2:
            sizes[currentBrashTool] = .four
        case 3:
            sizes[currentBrashTool] = .six
        case 4:
            sizes[currentBrashTool] = .eight
        default:
            break
        }
        delegate?.changeBrashdimensions(at: brashSize)
    }
    
    @objc private func handleSliderChange(_ slider: UISlider) {
        let roundedValue = round(slider.value)
        slider.value = roundedValue
        sizes[currentBrashTool] = BrashSize(rawValue: Int(roundedValue)) ?? .one
        delegate?.changeBrashdimensions(at: brashSize)
    }
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }

    func sumFracts(_ l: [(Int, Int)]) -> (Int, Int)? {
        guard !l.isEmpty else { return nil }
        
        var numeratorSum = 0
        var denominatorSum = 1
        
        for fraction in l {
            let numerator = fraction.0
            let denominator = fraction.1
            let commonDivisor = gcd(denominatorSum, denominator)
            
            numeratorSum = numeratorSum * (denominatorSum / commonDivisor) + numerator * (denominator / commonDivisor)
            denominatorSum *= denominator / commonDivisor
        }
        
        let commonDivisor = gcd(numeratorSum, denominatorSum)
        numeratorSum /= commonDivisor
        denominatorSum /= commonDivisor
        
        if denominatorSum == 1 {
            return (numeratorSum, 1)
        } else {
            return (numeratorSum, denominatorSum)
        }
    }
    
    private func loadVolumeViewFromNib() -> UIView {
        let volNib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        let volNibView = volNib.instantiate(withOwner: self, options: nil).first as! UIView
        return volNibView
    }
}
