import UIKit
import Combine
import PencilKit
import CoreGraphics

class SkinCreatorViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver, UIActionSheetDelegate {
    
    typealias ImageDataCallback = (SkinCreatedModel) -> Void
    
    enum ToolBarSelectedItem {
        case pencil
        case eraser
        case picker
        case fill
        case noise
        case undo
    }
    
    var magnifyingGlassView: MagnifyingGlassView?
    var currentEditableSkin: SkinCreatedModel?
    var saveAlertView: SaveAlertView?
    var cancellable: AnyCancellable?
    // MARK: - Properties
    
    private let imageDataCallback: ImageDataCallback
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    
    var currentBodyPartSide: Side? {
        didSet {
            print("asd")
        }
    }
    var canvasPixelView: CanvasView?
    var commandManager = CommandManager()
    var colorsManager = ColorsManger()
    var observer: AnyObject?
    
    lazy var _currentDrawingColor: UIColor = colorsManager.getColor(by: 0) {
        didSet {
            colorsManager.updateColorsArr(with: _currentDrawingColor)
        }
    }
    
    var currentDrawingColor: UIColor {
        get {
            if self.toolBarSelectedItem == .eraser {
                return UIColor.clear
            } else {
                return _currentDrawingColor
            }
        }
        set {
            _currentDrawingColor = newValue
            
        }
    }
    
    var currentTool: Tool? = Paintbrush()
    var groupDrawCommand: GroupDrawCommand = GroupDrawCommand()
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var panForColorPickerRecognizer = UIPanGestureRecognizer()
    var navigatorGestureRecognizer = UIPanGestureRecognizer()
    var drawGestureRecognizer = UIPanGestureRecognizer()
    
    var drawing = PKDrawing()
    var drawingHistory: [PKDrawing] = []
    var toolBarSelectedItem: ToolBarSelectedItem = .pencil {
        didSet {
            toolsStackView.isHidden = false
            
            switch toolBarSelectedItem {
            case .pencil, .fill, .noise, .undo:
                break
            case .eraser:
                break
            case .picker:
                break
            }
            manageGestures()
        }
    }
    
    var blurView: UIVisualEffectView?
    var alertWindow: UIWindow?
    private let isIpad = Device.iPad
    /// Attribute making sure that you cannot draw while you're pinching or panning
    /// around the screen.
    var canDraw = true
    
    
    //MARK: - Constraint Ooutlets
    
    @IBOutlet weak var aspectCanvasContainerConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var widthCanvasContainerConstraint: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    //Pencil kit
    @IBOutlet weak var canvasContainer: UIView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var navigationBar: UIView!
    
    //MARK: - Tools Outlets
    
    @IBOutlet weak var toolsStackView: UIView!
    
    @IBOutlet var toolButtons: [UIButton]!
    
    @IBOutlet weak var pencilBtn: UIButton!

    @IBOutlet weak var eraserBtn: UIButton!

    @IBOutlet weak var dropperBtn: UIButton!

    @IBOutlet weak var fillBtn: UIButton!

    @IBOutlet weak var noiseBtn: UIButton!

    @IBOutlet weak var undoBtn: UIButton!
    
    @IBOutlet weak var importBtn: UIButton!
    
    //MARK: Colors Outles
    
    @IBOutlet weak var dropperButton: UIButton!
    @IBOutlet weak var paletteButton: UIButton!
    
    @IBOutlet weak var colorsCollection: UICollectionView!
    
    //MARK: - IBActions
    
    @IBAction func onToolBarPencilButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
                TransitionColor = currentDrawingColor
        toolBarSelectedItem = .pencil
        currentTool = Paintbrush()
    }
    
    @IBAction func onToolBarEraserButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        toolBarSelectedItem = .eraser
        currentTool = Paintbrush()
    }
    
    @IBAction func onToolBarPickerButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        toolBarSelectedItem = .picker
        currentTool = Paintbrush()
        
    }
    
    @IBAction func onToolBarFillButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        toolBarSelectedItem = .fill
        currentTool = Bucket()
    }
    
    @IBAction func onToolBarNoiseButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        toolBarSelectedItem = .noise
        currentTool = NoiseTool()
    }
    
    @IBAction func onToolBarUndoButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        toolBarSelectedItem = .undo
        commandManager.undo()
    }
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        saveAlertView = SaveAlertView()
        saveAlertView?.delegate = self
        saveAlertView?.dialogTextLabel.text = "Save skin before exit".uppercased()
        saveAlertView?.frame = view.bounds
        saveAlertView?.withoutTextField = true
        saveAlertView?.setSkinNameSaveTextField.isHidden = true
        saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
            string: currentEditableSkin?.name ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
        )
        view.addSubview(saveAlertView!)
    }
    
    
    //MARK: - ColorPickierView Actions
    
    @IBAction func paletteBtnTapped(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = self.currentDrawingColor
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.currentDrawingColor = color
                    TransitionColor = self.currentDrawingColor
                }
            }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func importBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Import Texture", message: "Are you sure you want to import texture from the Photo library?", preferredStyle: .alert)
        
        // Add "confirm" action
        let deleteAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.displayImportDialog()
        }
        alert.addAction(deleteAction)
        
        // Add "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    private func displayImportDialog() {
    
        
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self]  _ in
            guard let self else { return }
            self.photoGalleryManager.getImageFromCamera(from: self) { [weak self] image in
                guard let self else { return }
                self.processImported(image: image)
            }
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] _ in
            guard let self else { return }
            self.photoGalleryManager.getImageFromPhotoLibrary(from: self) { [weak self] image in
                guard let self else { return }
                self.processImported(image: image)
            }
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         
        self.present(alert, animated: true)
    }
    
    private func processImported(image: UIImage) {
        if let width = currentBodyPartSide?.width, let height = currentBodyPartSide?.height {
            CANVAS_WIDTH = width
            CANVAS_HEIGHT = height
        }
//        currentBodyPartSide = nil
        guard let rotatedImage = image.rotate(radians: CGFloat.pi/2) else { return }
        guard let pixelizedImg = rotatedImage.pixelateAndResize(to: .init(width: CANVAS_HEIGHT, height: CANVAS_WIDTH)) else { return }
        
        guard let colorsArr = pixelizedImg.extractPixelColors(width:CANVAS_HEIGHT, height: CANVAS_WIDTH, startX: 0, startY:0) else {
            return
        }
        
        canvasPixelView?.canvas.updatePixels(by: colorsArr)
    }
    
    @IBAction func dropperBtnTapped(_ sender: UIButton) {
//        sender.isSelected = true
        if magnifyingGlassView == nil {
            panForColorPickerRecognizer.isEnabled = true
            tapGestureRecognizer?.isEnabled = false
            drawGestureRecognizer.isEnabled = false
            
            magnifyingGlassView = MagnifyingGlassView(size: 60)
            magnifyingGlassView?.center = canvasPixelView?.center ?? CGPoint(x: 0, y: 0)
            magnifyingGlassView?.backgroundColor = .white
            
            canvasPixelView?.addSubview(magnifyingGlassView!)
        } else {
            hideMagnifyingGlass()
//            sender.isSelected = false
        }
    }
    
    
    private func saveHelper() {
        guard let canvasColorArray = canvasPixelView?.canvas.getPixelColorArray(),
              let canvasWidth = canvasPixelView?.canvas.getAmountOfPixelsForWidth(),
              let canvasHeight = canvasPixelView?.canvas.getAmountOfPixelsForHeight() else {
            return
        }
        
        let previousDrawing = Drawing(colorArray: canvasColorArray, width: canvasWidth, height: canvasHeight)
        let pictureExporter = PictureExporter(drawing: previousDrawing)
        
        let width = currentBodyPartSide?.width ?? CANVAS_WIDTH
        let height = currentBodyPartSide?.height ?? CANVAS_HEIGHT
        
        if currentEditableSkin?.name == "edit" {
            guard let skinDiagram = pictureExporter.generateUIImagefromDrawing(width: width, height: height) else {
                AppDelegate.log("unable to create SkinDiagram ")
                return
            }
            guard let currentEditableSkin = currentEditableSkin else { return }
            
            currentEditableSkin.skinAssemblyDiagram = skinDiagram
        } else {
            guard let skinDiagram = pictureExporter.createImageWithRawPixels(bodyPartSide: currentBodyPartSide ?? .init(name: "Side", width: width, height: height, startX: 0, startY: 0), image: currentEditableSkin?.skinAssemblyDiagram) else {
                AppDelegate.log("unable to create SkinDiagram ")
                return
            }
            guard let currentEditableSkin = currentEditableSkin else { return }
            
            currentEditableSkin.skinAssemblyDiagram = skinDiagram
        }
        
    }
    
    //MARK: - INIT
    
    init(bodyPartSide: Side, currentEditableSkin: SkinCreatedModel?, imageDataCallback: @escaping ImageDataCallback) {
        self.currentBodyPartSide = bodyPartSide
        self.currentEditableSkin = currentEditableSkin
        self.imageDataCallback = imageDataCallback
        
        CANVAS_WIDTH = bodyPartSide.width
        CANVAS_HEIGHT = bodyPartSide.height
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(convasWidth: Int, convasHeight: Int, currentEditableSkin: SkinCreatedModel?, imageDataCallback: @escaping ImageDataCallback) {
        self.currentEditableSkin = currentEditableSkin
        self.imageDataCallback = imageDataCallback
        
        CANVAS_WIDTH = convasWidth
        CANVAS_HEIGHT = convasHeight
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppDelegate.log("SkinCreatorViewController is DEINITED")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorsManager.delegate = self
        
        setupColorColletion()
        configureView()
        setupConstraint()
        setUpCanvasContainerConstraints()
        setUpCanvasView()
        registerGestureRecognizer()
    }
    
    // MARK: - Private Methods
    
    private func setupColorColletion() {
        colorsCollection.delegate = self
        colorsCollection.dataSource = self
        colorsCollection.register(UINib(nibName: "ColorCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionCell")
    }
    
    private func setUpCanvasContainerConstraints() {
        
        guard let currentBodyPartSide = currentBodyPartSide else { return }
        
        var widthMultiplier: CGFloat = 0
        
        if Device.iPhone {
            widthMultiplier = CGFloat(currentBodyPartSide.width) * 0.09
        } else {
            widthMultiplier = CGFloat(currentBodyPartSide.width) * 0.075
        }
        
        let aspectmultiplier: CGFloat = CGFloat(currentBodyPartSide.width) / CGFloat(currentBodyPartSide.height)
        
        widthCanvasContainerConstraint.setMultiplier(multiplier: widthMultiplier)
        aspectCanvasContainerConstraint.setMultiplier(multiplier: aspectmultiplier)
        
        view.layoutIfNeeded()
        
        AppDelegate.log("widthMultiplier = \(widthMultiplier)")
        AppDelegate.log("currentBodyPartSide.width = \(currentBodyPartSide.width)")
        AppDelegate.log("currentBodyPartSide.height = \(currentBodyPartSide.height)")
        AppDelegate.log("aspectmultiplier = \(aspectmultiplier)")
    }
    
    private func setUpCanvasView() {
        
        var colorsArr: [UIColor]?
        
        var image = currentEditableSkin?.skinAssemblyDiagram
//            .rotate(radians: CGFloat.pi)
        if currentBodyPartSide == nil {
            image = image?.resizeImageTo(size: .init(width: CANVAS_WIDTH,
                                                     height: CANVAS_HEIGHT))
        }
        
        colorsArr = image?

            .extractPixelColors(width: currentBodyPartSide?.width,
                                height: currentBodyPartSide?.height,
                                startX: currentBodyPartSide?.startX,
                                startY: currentBodyPartSide?.startY)
        
        let sceneSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        let canvasSize = CGSize(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)
        
        let canvasPixelView = CanvasView(colorArray: colorsArr, sceneSize: sceneSize, canvasSize: canvasSize)
        canvasPixelView.translatesAutoresizingMaskIntoConstraints = false
        canvasContainer.addSubview(canvasPixelView)
        
        NSLayoutConstraint.activate([
            canvasPixelView.centerXAnchor.constraint(equalTo: canvasContainer.centerXAnchor),
            canvasPixelView.centerYAnchor.constraint(equalTo: canvasContainer.centerYAnchor),
            canvasPixelView.widthAnchor.constraint(equalTo: canvasContainer.widthAnchor),
            canvasPixelView.heightAnchor.constraint(equalTo: canvasContainer.heightAnchor)
        ])
        
        canvasPixelView.layoutSubviews()
        canvasPixelView.layoutIfNeeded()
        
        self.canvasPixelView = canvasPixelView
    }
    
    private func configureView() {
        toolButtons.forEach { $0.backgroundColor = .clear }
        
        backgroundImageView.backgroundColor = .clear
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.roundCorners(12)
        backgroundImageView.layer.borderColor = UIColor(.black).cgColor
        backgroundImageView.layer.borderWidth = 1
        
        canvasContainer.roundCorners(12)
        canvasContainer.layer.borderColor = UIColor(.black).cgColor
        canvasContainer.layer.borderWidth = 1
        
        toolsStackView.roundCorners(.allCorners, radius: 36)
        toolsStackView.backgroundColor = UIColor(named: "YellowSelectiveColor")
        toolsStackView.layer.borderColor = UIColor.black.cgColor
        toolsStackView.layer.borderWidth = 1
        
        manageSelectedToolUI(tappedTool: pencilBtn)
    }
    
    private func setupConstraint() {
        view.addSubview(toolsStackView)
        toolsStackView.translatesAutoresizingMaskIntoConstraints = false
        if isIpad {
            NSLayoutConstraint.activate([
                toolsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
                toolsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                toolsStackView.widthAnchor.constraint(equalToConstant: 370)
            ])
        } else {
            NSLayoutConstraint.activate([
                toolsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                toolsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 10),
                toolsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            ])
        }
    }
    
    private func manageSelectedToolUI(tappedTool: UIButton) {
        let toolBtns = [
            pencilBtn,  eraserBtn, dropperBtn, fillBtn, noiseBtn, undoBtn]
        
        if tappedTool == dropperBtn && tappedTool.isSelected == true {
            hideMagnifyingGlass()
        }
        
        toolBtns.forEach({ $0?.isSelected = false })
        tappedTool.isSelected = true

    }
    
    private func manageGestures() {

        switch toolBarSelectedItem {
        case .undo:
            longPressGestureRecognizer?.isEnabled = false
            panForColorPickerRecognizer.isEnabled = false
            navigatorGestureRecognizer.isEnabled = false
            drawGestureRecognizer.isEnabled = false
            
        case .pencil, .fill, .noise, .eraser, .picker:
            longPressGestureRecognizer?.isEnabled = true
            panForColorPickerRecognizer.isEnabled = false
            navigatorGestureRecognizer.isEnabled = true
            drawGestureRecognizer.isEnabled = true
        }
    }
}

// MARK: - Test functionality
extension SkinCreatorViewController {
    
    func saveImageAsPNG(image: UIImage) {
        let fileURL = FileManager.default.documentDirectory.appendingPathComponent("image.png")
        let _ = image.save(to: fileURL)
    }
}

extension SkinCreatorViewController: SkinSavebleDialogDelegate {
    func saveSkin(with name: String, withExit: Bool) {
        
        saveHelper()
        
        guard let currentEditableSkin = currentEditableSkin else { return }
        
        imageDataCallback(currentEditableSkin)
    }
    
    func cancelSave(withExit: Bool) {
        navigationController?.popViewController(animated: true)
    }
    
    func warningNameAlert(presentAlert: UIAlertController) {
        present(presentAlert, animated: true)
    }
    
    
    func hideMagnifyingGlass() {
        if magnifyingGlassView != nil {
//            dropperButton.isSelected = false
            
            magnifyingGlassView?.removeFromSuperview()
            magnifyingGlassView = nil
            
            panForColorPickerRecognizer.isEnabled = false
            tapGestureRecognizer?.isEnabled = true
            navigatorGestureRecognizer.isEnabled = true
            drawGestureRecognizer.isEnabled = true
        }
    }
}

extension SkinCreatorViewController: SkinCreatorImportProtocol {
    func didImport(colors: [UIColor]) {
        canvasPixelView?.canvas.updatePixels(by: colors)
    }
}
