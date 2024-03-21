//
//  ThreeDSkinTestViewController.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import Combine
import SceneKit

typealias AppViewController = UIViewController

enum AssemblyDiagramDimensions {
    case dimensions64x64
    case dimensions128x128
}

protocol BrushSizeDelegate: AnyObject {
    func changeBrashdimensions(at size: BrashSize)
}

protocol BodyPartsVisibilityDelegate: AnyObject {
    func hideAnatomyPart(of type: StivesAnatomyPart, completion: @escaping (_ layerEditing: AnatomyPartEditState) -> Void)
}

protocol SkinSaveDialogDelegate: AnyObject {
    func saveSkin(with name: String, withExit: Bool)
    func cancelSave(withExit: Bool)
    func warningPromptName(presentAlert: UIAlertController)
}

class ThreeDSkinTestViewController: AppViewController {
    //MARK: Properties
    private lazy var minecraftSkinManager: MinecraftSkinManagerProtocol = MinecraftSkinManager()
    
    //MARK: Properties
    
    var scnModel: SceneLogicModel!
    
    var editorSkinModel: EditorSkinModel!
    
    var colorManager3D = ThreeDColorManager()
    
    var cancellable: AnyCancellable?
    
    var toolBarSelectedItem: ToolBar3DSelectedItem = .pencil {
        didSet {
            brashSizeView.currentBrashTool = toolBarSelectedItem
            toolsStackView.isHidden = false
        }
    }
    
    var magnifyingGlassView: MagnifyingGlassView?
    var saveAlertView: SaveConfirmationView?
    
    var tapGestureOnSCNScene = UITapGestureRecognizer()
    var doubleTapGestureOnScene = UITapGestureRecognizer()
    var panGestureOnSCNScene = UIPanGestureRecognizer()
    var panForColorPickerRecognizer = UIPanGestureRecognizer()
    
    var alertWindow: UIWindow?
    
    //MARK: IBOotlet
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var shareButton: UIButton = UIButton()
    private var dowmloadButton: UIButton = UIButton()
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var skinNameLabel: UILabel!
    
    @IBOutlet weak var sceneView: SCNView!
    
    @IBOutlet weak var brashSizeView: BrushSizeView!
    
    @IBOutlet weak var smallStiveView: SmallModelView!
    
    @IBOutlet weak var rotationSkinModelButton: UIButton!

    @IBOutlet weak var toolsStackView: UIView!
    
    @IBOutlet weak var color3DCollection: UICollectionView!
    @IBOutlet weak var pencilBtn: UIButton!
    @IBOutlet weak var eraserBtn: UIButton!
    @IBOutlet weak var dropperBtn: UIButton!
    @IBOutlet weak var fillBtn: UIButton!
    @IBOutlet weak var noiseBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var dropperButton: UIButton!
    
    private let isIpad = Device.iPad
    
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
        updateBrushSizeVisibility(.pencil)
        toolBarSelectedItem = .pencil
    }
    
    @IBAction func onToolBarEraserButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrushSizeVisibility(.eraser)
        toolBarSelectedItem = .eraser
    }
    
    @IBAction func onToolBarBrashButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrushSizeVisibility(.brash)
        toolBarSelectedItem = .brash
        
    }
    
    @IBAction func onToolBarFillButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrushSizeVisibility(.fill)
        toolBarSelectedItem = .fill
    }
    
    @IBAction func onToolBarNoiseButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        updateBrushSizeVisibility(.noise)
        toolBarSelectedItem = .noise
    }
    
    @IBAction func onToolBarUndoButtonTapped(_ sender: UIButton) {
        hideMagnifyingGlass()
        manageSelectedToolUI(tappedTool: sender)
        editorSkinModel.makeUndoDrawCommand()
        updateBrushSizeVisibility(.undo)
        toolBarSelectedItem = .undo
    }
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        if skinNameLabel.isHidden {
            navigationController?.popViewController(animated: true)
        } else {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            saveAlertView = SaveConfirmationView()
            saveAlertView?.delegate = self
            saveAlertView?.dialogTextLabel.text = "Do you want to save the skin before exiting?"
            saveAlertView?.frame = view.bounds
            saveAlertView?.setSkinNameSaveTextField.isHidden = true
            saveAlertView?.withExit = true
            saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
                string: skinNameLabel.text ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
            )
            saveAlertView?.insertSubview(blurView, at: 0)
            view.addSubview(saveAlertView!)
        }
    }
    
    @IBAction func onNavBarSafeButtonTapped(_ sender: UIButton) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        saveAlertView = SaveConfirmationView()
        saveAlertView?.delegate = self
        saveAlertView?.dialogTextLabel.text = "Select a name for your skin."
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
    
    init(currentEditableSkin: AnatomyCreatedModel, skinAssemblyDiagramSize: AssemblyDiagramDimensions) {
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
        
        configureColorCollection()

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
    private func calculatePrimorial(at number: UInt) -> UInt {
        var primeCount: UInt = 0
        var currentNumber: UInt = 2
        var primorial: UInt = 1
        
        while primeCount < number {
            if isPrime(currentNumber) {
                primorial *= currentNumber
                primeCount += 1
            }
            currentNumber += 1
        }
        
        return primorial
    }
    
    private func updateBrushSizeVisibility(_ item: ToolBar3DSelectedItem) {
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
    
    func configureColorCollection() {
        color3DCollection.delegate = self
        color3DCollection.dataSource = self
        color3DCollection.register(UINib(nibName: "Color3DCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Color3DCollectionCell")
    }
    
    private func isPrime(_ number: UInt) -> Bool {
        if number <= 1 {
            return false
        }
        
        for i in 2..<number {
            if number % i == 0 {
                return false
            }
        }
        
        return true
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
        doubleTapGestureOnScene = UITapGestureRecognizer(target: self, action: #selector(processDoubleTap))
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
        setupConstraint()
        skinNameLabel.text = editorSkinModel.skinCreatedModel?.name
        toolsStackView.roundCorners(.allCorners, radius: 36)
        toolsStackView.backgroundColor = UIColor(named: "YellowSelectiveColor")
        toolsStackView.layer.borderColor = UIColor.black.cgColor
        toolsStackView.layer.borderWidth = 1
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
                toolsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -21),
                toolsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            ])
        }
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
        toolsStackView.isHidden = true
        
        panForColorPickerRecognizer.isEnabled = false
        tapGestureOnSCNScene.isEnabled = false
        panGestureOnSCNScene.isEnabled = false
        
        sceneView.allowsCameraControl = true
        
        setupDownloadAndShareButtons()
    }
    
    private func setupDownloadAndShareButtons() {
        dowmloadButton.setImage(UIImage(named: "Save Item"), for: .normal)
        dowmloadButton.addTarget(self, action: #selector(downloadExportAction), for: .touchUpInside)
        
        titleLabel.text = "FINAL SKIN"
        
        shareButton.setImage(UIImage(named: "Dowmload Item"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        
        view.addSubview(shareButton)
        view.addSubview(dowmloadButton)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        dowmloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: dowmloadButton.leadingAnchor, constant: -8),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.widthAnchor.constraint(equalToConstant: 44),

            dowmloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dowmloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dowmloadButton.heightAnchor.constraint(equalToConstant: 44),
            dowmloadButton.widthAnchor.constraint(equalToConstant: 44)
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
        if editorSkinModel.assemblyDiagramSize == .dimensions128x128 {
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

extension ThreeDSkinTestViewController: BrushSizeDelegate {
    func changeBrashdimensions(at size: BrashSize) {
        editorSkinModel.brashSize = size
    }
}

extension ThreeDSkinTestViewController: BodyPartsVisibilityDelegate {
    func hideAnatomyPart(of type: StivesAnatomyPart, completion: @escaping (AnatomyPartEditState) -> Void) {
        editorSkinModel.hideShowBodyPart(by: type)
        
        let state = editorSkinModel.getBodyPartEditState(by: type)
        
        completion(state)
    }
}

extension ThreeDSkinTestViewController: SkinSaveDialogDelegate {
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
    
    func warningPromptName(presentAlert: UIAlertController) {
        present(presentAlert, animated: true)
    }
}
