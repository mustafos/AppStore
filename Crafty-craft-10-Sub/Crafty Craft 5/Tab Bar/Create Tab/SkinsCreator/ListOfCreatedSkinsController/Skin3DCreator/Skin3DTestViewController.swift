import UIKit
import Combine
import SceneKit

enum SkinAssemblyDiagramSize {
    case size64x64
    case size128x128
}

protocol BrashSizeCangableDelegate: AnyObject {
    func changeBrashSize(to size: BrashSize)
}

protocol BodyPartsHiddebleDelegate: AnyObject {
    func hideBodyPart(of type: StivesBodyPart, completion: @escaping (_ layerEditing: BodyPartEditState) -> Void)
}

protocol SkinSavebleDialogDelegate: AnyObject {
    func saveSkin(with name: String, withExit: Bool)
    func cancelSave(withExit: Bool)
    func warningNameAlert(presentAlert: UIAlertController)
}
//
//protocol PickerViewControllerProtocol : AnyObject {
//    func dismissView()
//    func setColor(color: UIColor)
//}

class Skin3DTestViewController: UIViewController {
    //MARK: Properties
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    //MARK: Properties
    
    var scnModel: SceneLogicModel!
    
    var editorSkinModel: EditorSkinModel!
    
    var colorManager3D = ColorManager3D()
    
    var cancellable: AnyCancellable?
    
    var toolBarSelectedItem: ToolBar3DSelectedItem = .pencil {
        didSet {
            brashSizeView.currentBrashTool = toolBarSelectedItem
            colorsBrashContainerView.isHidden = false
        }
    }
    
    var magnifyingGlassView: MagnifyingGlassView?
    var saveAlertView: SaveAlertView?
    
    var tapGestureOnSCNScene = UITapGestureRecognizer()
    var doubleTapGestureOnScene = UITapGestureRecognizer()
    var panGestureOnSCNScene = UIPanGestureRecognizer()
    var panForColorPickerRecognizer = UIPanGestureRecognizer()
    
    var alertWindow: UIWindow?
    
    //MARK: IBOotlet
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var shareButton: UIButton = UIButton()
    
    @IBOutlet weak var skinNameLabel: UILabel!
    
    @IBOutlet weak var sceneView: SCNView!
    
    @IBOutlet weak var brashSizeView: BrashSizeView!
    
    @IBOutlet weak var smallStiveView: SmallModelView!
    
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
    
    var startingPointOfView: SCNNode?
    
    
    //MARK: - IBActions
    
    @IBAction func rotationCameraControllButtonAction(_ sender: UIButton) {
        if smallStiveView.isHidden {
            smallStiveView.isHidden = false
            tapGestureOnSCNScene.isEnabled = true
            panGestureOnSCNScene.isEnabled = true
            panForColorPickerRecognizer.isEnabled = false
            sceneView.allowsCameraControl = false
        } else {
            sceneView.allowsCameraControl = true
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
    
    @IBAction func onToolBarBrashButtonTapped(_ sender: UIButton) {
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
        editorSkinModel.makeUndoDrawCommand()
        updateBrashSizeHiddenStatus(.undo)
        toolBarSelectedItem = .undo
    }
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        if skinNameLabel.isHidden {
            navigationController?.popViewController(animated: true)
        } else {
            saveAlertView = SaveAlertView()
            saveAlertView?.delegate = self
            saveAlertView?.dialogTextLabel.text = "Save skin before exit".uppercased()
            saveAlertView?.frame = view.bounds
            saveAlertView?.setSkinNameSaveTextField.isHidden = true
            saveAlertView?.withExit = true
            saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
                string: skinNameLabel.text ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
            )
            view.addSubview(saveAlertView!)
        }
    }
    
    @IBAction func onNavBarSafeButtonTapped(_ sender: UIButton) {
        
        saveAlertView = SaveAlertView()
        saveAlertView?.delegate = self
        saveAlertView?.frame = view.bounds
        saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
            string: skinNameLabel.text ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
        )
        view.addSubview(saveAlertView!)
    }
    
    @IBAction func colorPaletButtonTapped(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = self.editorSkinModel.currentDrawingColor
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.editorSkinModel.currentDrawingColor = color
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
        } else {
            hideMagnifyingGlass()
        }
    }
    
    //MARK: - Init
    
    init(currentEditableSkin: SkinCreatedModel, skinAssemblyDiagramSize: SkinAssemblyDiagramSize) {
        super.init(nibName: nil, bundle: nil)
        scnModel = SceneLogicModel(assemblyDiagramSize: skinAssemblyDiagramSize, currentEditableModel: currentEditableSkin)
        editorSkinModel = EditorSkinModel(viewController: self, skinCreatedModel: currentEditableSkin, assemblyDiagramSize: skinAssemblyDiagramSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColorColletion()

        colorManager3D.delegate = self
        brashSizeView.delegate = self
        smallStiveView.delegate = self

        manageSelectedToolUI(tappedTool: pencilBtn)
        toolBarSelectedItem = .pencil
        
        setupMyScene()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sceneView.defaultCameraController.rotateBy(x: 1.1, y: 1.1) // just init inner property (fixed bug with flickers)
    }
    
    deinit {
        AppDelegate.log("Skin3DTestViewController - deinited!!!")
    }

    //MARK: Private functions
    
    
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
    
    func setupColorColletion() {
        color3DCollection.delegate = self
        color3DCollection.dataSource = self
        color3DCollection.register(UINib(nibName: "Color3DCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Color3DCollectionCell")
    }
    
    @objc func undoTap() {
        undoBtn.sendActions(for: .touchUpInside)
    }
    @objc func pencilTap() {
        pencilBtn.sendActions(for: .touchUpInside)
    }
    @objc func eraserTap() {
        eraserBtn.sendActions(for: .touchUpInside)
    }
    @objc func pickerTap() {
        dropperBtn.sendActions(for: .touchUpInside)
    }
    @objc func fillTap() {
        fillBtn.sendActions(for: .touchUpInside)
    }
    
    private func setupMyScene() {
        
        sceneView.scene = scnModel.scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true // <--- when user go to edit mode
        sceneView.showsStatistics = false
        startingPointOfView = sceneView.pointOfView
        
        if let gestureRecognizers = sceneView.gestureRecognizers {
            for (index, gesture) in gestureRecognizers.enumerated() {

                if index == 0 || index == 2 {
                    gesture.isEnabled = false
                    sceneView.removeGestureRecognizer(gesture)
                }
            }
        }
        
        panGestureOnSCNScene = UIPanGestureRecognizer(target: self, action: #selector(panOnSceneAction(_:)))
        panGestureOnSCNScene.maximumNumberOfTouches = 1

        panForColorPickerRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGEtureforPicker(_:)))
        panForColorPickerRecognizer.maximumNumberOfTouches = 1

        // Single Tap
        tapGestureOnSCNScene = UITapGestureRecognizer(target: self, action: #selector(tapOnSceneAction(_:)))
        tapGestureOnSCNScene.numberOfTapsRequired = 1

        // Double Tap
        doubleTapGestureOnScene = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGestureOnScene.numberOfTapsRequired = 2

        doubleTapGestureOnScene.require(toFail: panForColorPickerRecognizer)
        doubleTapGestureOnScene.require(toFail: panGestureOnSCNScene)

        tapGestureOnSCNScene.delaysTouchesBegan = true

        doubleTapGestureOnScene.delaysTouchesBegan = true

        sceneView.addGestureRecognizer(tapGestureOnSCNScene)
        sceneView.addGestureRecognizer(doubleTapGestureOnScene)

        sceneView.addGestureRecognizer(panForColorPickerRecognizer)
        sceneView.addGestureRecognizer(tapGestureOnSCNScene)
        sceneView.addGestureRecognizer(panGestureOnSCNScene)
    }

    private func setupUI() {
        setupBrushSizeView()
        skinNameLabel.text = editorSkinModel.skinCreatedModel?.name
        toolsStackView.roundCorners(.allCorners, radius: 27)
        toolsStackView.layer.borderColor = UIColor.black.cgColor
        toolsStackView.layer.borderWidth = 1
    }

    //MARK: Setup brushSize
    
    private func setupBrushSizeView() {
        view.bringSubviewToFront(brashSizeView)
    }

    private func manageSelectedToolUI(tappedTool: UIButton) {
        
        let nonSelectedColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let selectedColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
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
    
    private func showSavedSkin() {
        skinNameLabel.isHidden = true
        saveButton.isHidden = true
        rotationSkinModelButton.isHidden = true
        brashSizeView.isHidden = true
        colorsBrashContainerView.isHidden = true
        
        panForColorPickerRecognizer.isEnabled = false
        tapGestureOnSCNScene.isEnabled = false
        panGestureOnSCNScene.isEnabled = false
        
        sceneView.allowsCameraControl = true
        
        setupDownloadAndShareButtons()
    }
    
    private func setupDownloadAndShareButtons() {
        
        let stackHeight: CGFloat = 54
        
        let button1 = UIButton()
        button1.setTitle("Download", for: .normal)
        button1.backgroundColor = UIColor(named: "YellowSelectiveColor")
        
        button1.addTarget(self, action: #selector(downloadExportAction), for: .touchUpInside)
        button1.roundCorners(.allCorners, radius: stackHeight / 2)
        button1.borderColor = .black
        button1.borderWidth = 1
        
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = UIColor(named: "YellowSelectiveColor")
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        shareButton.roundCorners(.allCorners, radius: stackHeight / 2)
        shareButton.borderColor = .black
        shareButton.borderWidth = 1
        
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
        toolsStackView.roundCorners(.allCorners, radius: 27)
        toolsStackView.layer.borderColor = UIColor.black.cgColor
        toolsStackView.layer.borderWidth = 1
        NSLayoutConstraint.activate([
            //containerConstraints
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            containerView.heightAnchor.constraint(equalTo: toolsStackView.heightAnchor),

            //stackConstraints
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: stackHeight),
        ])
    }
    
    @objc private func downloadExportAction() {
        
        self.editorSkinModel.saveAssemblyDiagram()
    }
    
    @objc private func shareAction() {
        guard NetworkStatusMonitor.shared.isNetworkAvailable else {
            self.showNoInternetMess()
            return
        }
        
        var assemblyDiagram = editorSkinModel.skinCreatedModel?.skinAssemblyDiagram
        if editorSkinModel.assemblyDiagramSize == .size128x128 {
            assemblyDiagram = editorSkinModel.skinCreatedModel?.skinAssemblyDiagram128
        }
        
        guard let image = assemblyDiagram else { return }
        
        guard let data = image.pngData() else {
            AppDelegate.log("Failed to convert image to PNG data.")
            return
        }
        let fileURL = FileManager.default.cachesDirectory.appendingPathComponent("skin.png")
        
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

extension Skin3DTestViewController: BrashSizeCangableDelegate {
    func changeBrashSize(to size: BrashSize) {
        editorSkinModel.brashSize = size
    }
}

extension Skin3DTestViewController: BodyPartsHiddebleDelegate {
    func hideBodyPart(of type: StivesBodyPart, completion: @escaping (BodyPartEditState) -> Void) {
        editorSkinModel.hideShowBodyPart(by: type)
        
        let state = editorSkinModel.getBodyPartEditState(by: type)
        
        completion(state)
    }
}

extension Skin3DTestViewController: SkinSavebleDialogDelegate {
    func hideSaveAlertView() {
        saveAlertView?.removeFromSuperview()
        saveAlertView = nil
    }
    
    func saveSkin(with name: String, withExit: Bool) {
        scnModel.unHightLightOtsideNodes()
        editorSkinModel.saveSkinsAssemblyDiagram(with: name)
        hideSaveAlertView()
        smallStiveView.isHidden = true
        if withExit {
            navigationController?.popViewController(animated: true)
        } else {
            showSavedSkin()
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
