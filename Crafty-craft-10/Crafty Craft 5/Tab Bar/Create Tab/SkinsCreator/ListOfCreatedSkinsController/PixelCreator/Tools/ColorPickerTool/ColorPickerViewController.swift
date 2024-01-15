//import UIKit
//
//class ColorPickerViewController: UIViewController {
//    
//    // MARK: - Private properties
//    @IBOutlet private weak var okButton: UIButton!
//    @IBOutlet private weak var colorButton: UIButton!
//    @IBOutlet private weak var colorSlider: RSColourSlider!
//    @IBOutlet private weak var pikkoView: Pikko!
//    @IBOutlet private weak var backgroundView: UIView!
//    
//    @IBOutlet weak var backgroundWidthConstraint: NSLayoutConstraint!
//    
//    
//    weak var delegate: PickerViewControllerProtocol?
//    
//    // MARK: - Lifecycle methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//    }
//    
//    // MARK: - Private methods
//    private func setupView() {
//        configurePikkoView()
//        configureBackgroundView()
//        configureColorButton()
//        configureColorSlider()
//        configureDelegates()
//        
//        if Device.iPad {
//            backgroundWidthConstraint.isActive = false
//            backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
//        }
//    }
//    
//    private func configureDelegates() {
//        colorSlider.delegate = self
//        pikkoView.delegate = self
//    }
//    
//    private func configurePikkoView() {
//        pikkoView.roundCorners(12)
//        pikkoView.clipsToBounds = true
//        pikkoView.currentColor = TransitionColor
//        pikkoView.setColor(TransitionColor)
//    }
//    
//    private func configureBackgroundView() {
//        backgroundView.roundCorners(27)
//        backgroundView.layer.borderWidth = 1
//        backgroundView.layer.borderColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
//    }
//    
//    private func configureColorButton() {
//        colorButton.layer.borderWidth = 1
//        colorButton.layer.borderColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
//        colorButton.roundCorners(27)
//        
//        okButton.roundCorners(27)
//    }
//    
//    private func configureColorSlider() {
//        colorSlider.backgroundColor = .clear
//        colorSlider.setCornerRadius(by: colorSlider.bounds.height / 3)
//        let thumbViewSizeOffset: CGFloat = Device.iPhone ? 6 : 0
//        colorSlider.thumbView.layer.borderWidth = 2
//        colorSlider.thumbView.frame = CGRect(x: 0,
//                                             y: 0,
//                                             width: colorSlider.frame.height - thumbViewSizeOffset,
//                                             height: colorSlider.frame.height - thumbViewSizeOffset)
//        colorSlider.thumbView.roundCorners(colorSlider.thumbView.frame.height / 2)
//        colorSlider.colourChosen = TransitionColor
//        colorSlider.thumbView.backgroundColor = TransitionColor
//    }
//    
//    // MARK: - Actions
//    @IBAction private func onCancelButtonTapped(_ sender: UIButton) {
//        delegate?.dismissView()
//    }
//    
//    @IBAction private func onOkButtonTapped(_ sender: UIButton) {
//        // close child vc
//        delegate?.dismissView()
//        delegate?.setColor(color: self.pikkoView.getColor())
//    }
//}
//
//// MARK: - RSColourSliderDelegate
//extension ColorPickerViewController : RSColourSliderDelegate {
//    func colourGotten(colour: UIColor) {
//        TransitionColor = colour
//        pikkoView.setColor(colour)
//        
//    }
//}
//
//// MARK: - PikkoDelegate
//extension ColorPickerViewController : PikkoDelegate {
//    func writeBackColor(color: UIColor) {
//        
//    }
//}
