import UIKit
import Combine
import SceneKit

class AddonEditor3DViewController: UIViewController {
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    //MARK: Properties
    var vcModel: AddonEditor3DVCModel?
    var cancellable: AnyCancellable?
    lazy var toolBarSelectedItem: ToolBar3DSelectedItem = .pencil {
        didSet {
            brashSizeView.currentBrashTool = toolBarSelectedItem
            colorsBrashContainerView.isHidden = false
            vcModel?.editorAddonModel.activeTool = toolBarSelectedItem
        }
    }
    
    var magnifyingGlassView: MagnifyingGlassView?
    var saveAlertView: SaveAlertView?
    
    var tapGestureOnSCNScene = UITapGestureRecognizer()
    var doubleTapGestureOnScene = UITapGestureRecognizer()
    var panGestureOnSCNScene = UIPanGestureRecognizer()
    var panForColorPickerRecognizer = UIPanGestureRecognizer()
    
    var alertWindow: UIWindow?
    var startingPointOfView: SCNNode?
    
    //MARK: IBOotlet
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var shareButton: UIButton = UIButton()
    
    @IBOutlet weak var skinNameLabel: UILabel!
    
    @IBOutlet weak var sceneView: SCNView!
    
    @IBOutlet weak var brashSizeView: BrashSizeView!
    
    @IBOutlet weak var smallStiveView: SCNView!
    
    @IBOutlet weak var colorsBrashContainerView: UIView!
    
    @IBOutlet weak var rotationSkinModelButton: UIButton!
    
    @IBOutlet weak var toolsStackView: UIStackView!
    
    @IBOutlet weak var color3DCollection: UICollectionView!

    @IBOutlet weak var pencilBtn: UIButton!
    @IBOutlet weak var eraserBtn: UIButton!
    @IBOutlet weak var dropperBtn: UIButton!
    @IBOutlet weak var fillBtn: UIButton!
    @IBOutlet weak var noiseBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!

    @IBOutlet weak var dropperButton: UIButton!
    
    //MARK: - IBActions
    
    @IBAction func rotationCameraControllButtonAction(_ sender: UIButton) {
        if smallStiveView.isHidden {
            smallStiveView.isHidden = false
            tapGestureOnSCNScene.isEnabled = true
            panGestureOnSCNScene.isEnabled = true
            panForColorPickerRecognizer.isEnabled = false
        } else {
            tapGestureOnSCNScene.isEnabled = false
            panGestureOnSCNScene.isEnabled = false
            panForColorPickerRecognizer.isEnabled = false
            smallStiveView.isHidden = true
            
        }
        hideMagnifyingGlass()
    }
    
    @IBAction func onToolBarPencilButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrashSizeHiddenStatus(.pencil)
        toolBarSelectedItem = .pencil
    }
    
    @IBAction func onToolBarEraserButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrashSizeHiddenStatus(.eraser)
        toolBarSelectedItem = .eraser
    }
    
    @IBAction func onToolBarPickerButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrashSizeHiddenStatus(.brash)
        toolBarSelectedItem = .brash
    }
    
    @IBAction func onToolBarFillButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrashSizeHiddenStatus(.fill)
        toolBarSelectedItem = .fill
    }
    
    @IBAction func onToolBarNoiseButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrashSizeHiddenStatus(.noise)
        toolBarSelectedItem = .noise
    }
    
    @IBAction func onToolBarUndoButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        vcModel?.editorAddonModel.undoManager.undo()
        updateBrashSizeHiddenStatus(.undo)
        toolBarSelectedItem = .undo
    }
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        if skinNameLabel.isHidden {
            navigationController?.popViewController(animated: true)
        } else {
            saveAlertView = SaveAlertView()
            saveAlertView?.dialogTextLabel.text = "Save skin before exit"
            saveAlertView?.delegate = self
            saveAlertView?.frame = view.bounds
            saveAlertView?.setSkinNameSaveTextField.isHidden = true
            saveAlertView?.withExit = true
            
            saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
                string: placeholderSaveAlert,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
            )
            view.addSubview(saveAlertView!)
        }
    }
    
    var placeholderSaveAlert: String {
        if let placeholder = skinNameLabel.text, !placeholder.isEmpty {
            return placeholder
        }
        return "Addon" + String(UUID().uuidString.prefix(5))
    }
    
    @IBAction func onNavBarSafeButtonTapped(_ sender: UIButton) {
        saveAlertView = SaveAlertView()
        saveAlertView?.delegate = self
        saveAlertView?.frame = view.bounds
        saveAlertView?.withExit = true
        saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderSaveAlert,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
        )
        view.addSubview(saveAlertView!)
    }
    
    @IBAction func colorPaletButtonTapped(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = (vcModel?.editorAddonModel.currentDrawingColor)!
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.vcModel?.editorAddonModel.currentDrawingColor = color
                }
            }
        self.present(picker, animated: true, completion: nil)
    }

    
    @IBAction func colorPickerButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        if magnifyingGlassView == nil {
            panForColorPickerRecognizer.isEnabled = true
            tapGestureOnSCNScene.isEnabled = false
            panGestureOnSCNScene.isEnabled = false
            
            magnifyingGlassView = MagnifyingGlassView(size: 60)
            magnifyingGlassView?.center = sceneView.center
            magnifyingGlassView?.backgroundColor = .white
            
            sceneView.addSubview(magnifyingGlassView!)
        }
    }
    
    //MARK: - Init
    
    init(resourcePack: ResourcePack, savingDelegate: AddonSaveable?) {
        super.init(nibName: nil, bundle: nil)
        self.vcModel = AddonEditor3DVCModel(viewController: self, resourcePack: resourcePack, savingDelegate: savingDelegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        AppDelegate.log("AddonEditor3DViewController - deinited!!!")
    }

    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        brashSizeView.delegate = self
        vcModel?.editorAddonModel.colorManager3D.delegate = self

        setupBrushSizeView()
        
        setupColorColletion()

        setupNormalSceneView()
        setupNormalSceneGestures()
        setupThumbSceneView()
        setupThumbNailSceneGestures()

        manageSelectedToolUI(tappedTool: pencilBtn)
        toolBarSelectedItem = .pencil
        
        toolsStackView.roundCorners(.allCorners, radius: 27)
        toolsStackView.layer.borderColor = UIColor.black.cgColor
        toolsStackView.layer.borderWidth = 1
    }
    
    
    //MARK: Setup brushSize
    
    private func setupBrushSizeView() {
        view.bringSubviewToFront(brashSizeView)
    }


    //MARK: Setup functions
    
    private func setupColorColletion() {
        color3DCollection.delegate = self
        color3DCollection.dataSource = self
        color3DCollection.register(UINib(nibName: "Color3DCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Color3DCollectionCell")
    }
    
    //MARK: Tools Actions
    
    @objc private func undoTap() {
        undoBtn.sendActions(for: .touchUpInside)
    }
    @objc private func pencilTap() {
        pencilBtn.sendActions(for: .touchUpInside)
    }
    @objc private func eraserTap() {
        eraserBtn.sendActions(for: .touchUpInside)
    }
    @objc private func pickerTap() {
        dropperBtn.sendActions(for: .touchUpInside)
    }
    @objc private func fillTap() {
        fillBtn.sendActions(for: .touchUpInside)
    }

    
//MARK: SetUP Normal Scene
    
    private func setupNormalSceneView() {
        sceneView.scene = vcModel?.scnModel?.scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true // <--- when user go to edit mode
        sceneView.showsStatistics = false
//        sceneView.defaultCameraController.delegate = self
        sceneView.delegate = self
        sceneView.defaultCameraController.inertiaEnabled = false
        startingPointOfView = sceneView.pointOfView
        
        if let gestureRecognizers = sceneView.gestureRecognizers {
            for (index, gesture) in gestureRecognizers.enumerated() {

                if index == 0 || index == 2 {
                    gesture.isEnabled = false
                    sceneView.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    private func setupNormalSceneGestures() {
        //TAP
        //DoubleTap
        doubleTapGestureOnScene = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureOnScene.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGestureOnScene)

        //SingleTap
        tapGestureOnSCNScene = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapGestureOnSCNScene.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureOnSCNScene)

        //PAN
        panGestureOnSCNScene = UIPanGestureRecognizer(target: self, action: #selector(panOnSceneAction(_:)))
        panGestureOnSCNScene.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGestureOnSCNScene)

        panForColorPickerRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureforPicker(_:)))
        panForColorPickerRecognizer.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panForColorPickerRecognizer)
        
        doubleTapGestureOnScene.isEnabled = true
        tapGestureOnSCNScene.isEnabled = true
        panGestureOnSCNScene.isEnabled = true
        panForColorPickerRecognizer.isEnabled = false
    }


    //MARK: SetUp ThumbSceneView
    
    private func setupThumbSceneView() {
        smallStiveView.scene = vcModel?.smallScnModel?.scene
        smallStiveView.autoenablesDefaultLighting = true
        smallStiveView.allowsCameraControl = false
        smallStiveView.showsStatistics = false
//        smallStiveView.delegate = self
//        smallStiveView.defaultCameraController.delegate = self
    }
    
    private func setupThumbNailSceneGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(thumbnailDidTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        smallStiveView.addGestureRecognizer(tapGesture)
    }


    //MARK: ManageUI

    private func manageSelectedToolUI(tappedTool: UIButton) {
        
        let nonSelectedColor = #colorLiteral(red: 0.1529411765, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
        let selectedColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        let toolBtns = [
            pencilBtn,  eraserBtn,
            dropperBtn, fillBtn,
            noiseBtn, undoBtn
        ]
        
        toolBtns.forEach({ $0?.isSelected = false })
        tappedTool.isSelected = true
    }
    
    func hideMagnifyingGlass() {
        if magnifyingGlassView != nil {
            dropperButton.isSelected = false
            
            magnifyingGlassView?.removeFromSuperview()
            magnifyingGlassView = nil
            
            panForColorPickerRecognizer.isEnabled = false
            tapGestureOnSCNScene.isEnabled = true
            panGestureOnSCNScene.isEnabled = true
        }
    }
    
    private func updateBrashSizeHiddenStatus(_ item: ToolBar3DSelectedItem) {
        if item == .fill || item == .undo {
            brashSizeView.isHidden = true
            return
        }
        
        if !brashSizeView.isHidden {
            brashSizeView.isHidden.toggle()
        } else {
            brashSizeView.isHidden = toolBarSelectedItem != item
        }
    }
    
    
    private func showSavedSkin() {
        skinNameLabel.isHidden = true
        saveButton.isHidden = true
        rotationSkinModelButton.isHidden = true
        
//        customToolPicker.alpha = 0
        brashSizeView.alpha = 0
        colorsBrashContainerView.alpha = 0
//        customToolPicker.isUserInteractionEnabled = false
        brashSizeView.isUserInteractionEnabled = false
        colorsBrashContainerView.isUserInteractionEnabled = false
        
        panForColorPickerRecognizer.isEnabled = false
        tapGestureOnSCNScene.isEnabled = false
        panGestureOnSCNScene.isEnabled = false
        
        sceneView.allowsCameraControl = true
        smallStiveView.isHidden = true
        
        setupDownloadAndShareButtons()
    }
    
    private func setupDownloadAndShareButtons() {
        
        let stackHeight: CGFloat = 54
        let button1 = UIButton()
        button1.setTitle("Download", for: .normal)
        button1.borderColor = .black
        button1.borderWidth = 1
        button1.backgroundColor = UIColor(named: "YellowSelectiveColor")
        
        button1.addTarget(self, action: #selector(downloadExportAction), for: .touchUpInside)
        button1.roundCorners(.allCorners, radius: stackHeight / 2)
        
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = UIColor(named: "YellowSelectiveColor")
        shareButton.borderColor = .black
        shareButton.borderWidth = 1
        shareButton.addTarget(self, action: #selector(shareCCAction), for: .touchUpInside)
        shareButton.roundCorners(.allCorners, radius: stackHeight / 2)
                
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(shareButton)
        
        containerView.addSubview(stackView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        button1.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            containerView.heightAnchor.constraint(equalToConstant: 104),

            //stackConstraints
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.heightAnchor.constraint(equalToConstant: stackHeight),
        ])
    }
    
    @objc private func downloadExportAction() {
        self.vcModel?.saveTextureToLibrary()
    }
    
    @objc private func shareCCAction() {
        guard NetworkStatusMonitor.shared.isNetworkAvailable else {
            self.showNoInternetMess()
            return
        }
        
        guard let image = self.vcModel?.scnModel?.constructImage() else {
            return
        }
        
        guard let data = image.pngData() else {
            AppDelegate.log("Failed to convert image to PNG data.")
            return
        }
        let fileURL = FileManager.default.cachesDirectory.appendingPathComponent("addon.png")
        
        do {
            try data.write(to: fileURL)
            AppDelegate.log("Image saved successfully at: \(fileURL.path)")
        } catch {
            AppDelegate.log("Failed to save image: \(error)")
            return
        }
        
        minecraftSkinManager.start(fileURL) { [weak self] url in
            self?.share(url: url, from: self?.shareButton)
        }
    }

}

//MARK: BrashSize Delegate
 
extension AddonEditor3DViewController: BrashSizeCangableDelegate {
    func changeBrashSize(to size: BrashSize) {
        vcModel?.editorAddonModel.brushSize = size.rawValue
    }
}

//MARK: SaveAllert Delegate method

extension AddonEditor3DViewController: SkinSavebleDialogDelegate {
    func hideSaveAlertView() {
        saveAlertView?.removeFromSuperview()
        saveAlertView = nil
    }
    
    func saveSkin(with name: String, withExit: Bool) {
        hideSaveAlertView()
        vcModel?.scnModel?.unHightLightCubes()
        
        if withExit {
            showSavedSkin()
            let addonPreview = sceneView.snapshot()
            
            vcModel?.saveAssemblyDiagram(addonPreview, name: name)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func cancelSave(withExit: Bool) {
        hideSaveAlertView()
        if withExit {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func warningNameAlert(presentAlert: UIAlertController) {
        present(presentAlert, animated: true)
    }
}

//MARK: Synchronize Scenes

extension AddonEditor3DViewController: SCNCameraControllerDelegate, SCNSceneRendererDelegate {
    func cameraInertiaWillStart(for cameraController: SCNCameraController) {
        updateSmallSceneCameraPoint()
    }

    func cameraInertiaDidEnd(for cameraController: SCNCameraController) {
        updateSmallSceneCameraPoint()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateSmallSceneCameraPoint()
    }
    
    private func updateSmallSceneCameraPoint() {
        if let pointOfView = sceneView.pointOfView {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.smallStiveView.pointOfView != pointOfView {
                    self.smallStiveView.pointOfView = pointOfView
                }
                
                self.smallStiveView.setNeedsDisplay()
            }
        }
    }
}
