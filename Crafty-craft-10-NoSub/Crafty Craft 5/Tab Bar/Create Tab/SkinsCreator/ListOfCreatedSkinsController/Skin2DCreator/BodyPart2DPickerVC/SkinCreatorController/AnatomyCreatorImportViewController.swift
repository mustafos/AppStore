//
//  AnatomyCreatorImportViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import PencilKit
import CoreGraphics

protocol AnatomyCreatorImportProtocol: AnyObject {
    func didImport(colors: [UIColor])
}

final class AnatomyCreatorImportViewController: UIViewController {
    
    private var currentEditableSkin: AnatomyCreatedModel?
    private var saveAlertView: SaveConfirmationView?
    
    private var hasChanges: Bool = false
    
    // MARK: - Properties
    
    private var currentBodyPartSide: Side?
    private var canvasPixelView: CanvasView?
    
    private var blurView: UIVisualEffectView?
    private var alertWindow: UIWindow?
    
    private weak var delegate: AnatomyCreatorImportProtocol!
    
    @IBOutlet private weak var saveButton: UIButton!
    
    //MARK: - Constraint Ooutlets
    
    @IBOutlet private weak var aspectCanvasContainerConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var widthCanvasContainerConstraint: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    //Pencil kit
    @IBOutlet private weak var canvasContainer: UIView!
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    @IBOutlet private weak var navigationBar: UIView!
    
    private lazy var photoGalleryManager: PhotoGalleryManagerProtocol = PhotoGalleryManager()
    
    //MARK: - INIT
    
    init(bodyPartSide: Side, currentEditableSkin: AnatomyCreatedModel?, delegate: AnatomyCreatorImportProtocol) {
        self.currentBodyPartSide = bodyPartSide
        self.currentEditableSkin = currentEditableSkin
        self.delegate = delegate
        
        CANVAS_WIDTH = bodyPartSide.width
        CANVAS_HEIGHT = bodyPartSide.height
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(canvasWidth: Int, canvasHeight: Int, currentEditableSkin: AnatomyCreatedModel?, delegate: AnatomyCreatorImportProtocol) {
        self.currentEditableSkin = currentEditableSkin
        self.delegate = delegate
        
        CANVAS_WIDTH = canvasWidth
        CANVAS_HEIGHT = canvasHeight
        
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
        
        configureView()
        setUpCanvasContainerConstraints()
        setUpCanvasView()
    }
    
    // MARK: - Private Methods
    
    private func setUpCanvasContainerConstraints() {
        
        guard let currentBodyPartSide = currentBodyPartSide else { return }
        
        var widthMultiplier: CGFloat = 0
        
        if UIDevice.current.userInterfaceIdiom == .phone {
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
        
        let colorsArr = currentEditableSkin?.skinAssemblyDiagram?.extractPixelColors(width: currentBodyPartSide?.width,
                                                                                     height: currentBodyPartSide?.height,
                                                                                     startX: currentBodyPartSide?.startX,
                                                                                     startY: currentBodyPartSide?.startY )
        
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
    
    func importantAwait(_ name: String) -> String {
        let startSring = "Hello, "
        let lastString = " how are you doing today?"
      return "\(startSring)\(name)\(lastString)"
    }
    
    private func configureView() {
        navigationBar.backgroundColor = .clear
        
        saveButton.isEnabled = false
        canvasContainer.roundCorners()
        buttonsStackView.roundCorners()
    }
    
    private func processImported(image: UIImage) {
        if let width = currentBodyPartSide?.width, let height = currentBodyPartSide?.height {
            CANVAS_WIDTH = width
            CANVAS_HEIGHT = height
        }
        currentBodyPartSide = nil
                    
        guard let resizedImage = image.resizeImageTo(size: .init(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)) else { return }
        guard let rotatedImage = resizedImage.rotate(radians: CGFloat.pi/2) else { return }
        guard let pixelizedImg = rotatedImage.pixelateAndResize(to: .init(width: CANVAS_WIDTH, height: CANVAS_WIDTH)) else { return }
        
        guard let colorsArr = pixelizedImg.extractPixelColors(width:CANVAS_WIDTH, height: CANVAS_WIDTH, startX: 0, startY:0) else {
            return
        }
        
        canvasPixelView?.canvas.updatePixels(by: colorsArr)
        
        hasChanges = true
        
        saveButton.isEnabled = true
    }
    
    private func saveHelper() {
        guard let canvasColorArray = canvasPixelView?.canvas.getPixelColorArray() else {
            return
        }
        
        delegate.didImport(colors: canvasColorArray)
    }
    
    private func displaySaveDialog() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        saveAlertView = SaveConfirmationView()
        saveAlertView?.delegate = self
        saveAlertView?.frame = view.bounds
        saveAlertView?.withoutTextField = true
        saveAlertView?.setSkinNameSaveTextField.isHidden = true
        saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
            string: currentEditableSkin?.name ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
        )
        saveAlertView?.insertSubview(blurView, at: 0)
        view.addSubview(saveAlertView!)
    }
    
    //MARK: - IBActions
    @IBAction private func onNavBarBackButtonTapped(_ sender: UIButton) {
        guard hasChanges else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        displaySaveDialog()
    }
    
    @IBAction private func onNavBarSaveButtonTapped(_ sender: UIButton) {
        displaySaveDialog()
    }
    
    @IBAction private func importFromCameraButtonTapped(_ sender: Any) {
        photoGalleryManager.getImageFromCamera(from: self) { [unowned self] image in
            
            processImported(image: image)
        }
    }
    
    @IBAction private func importFromLibraryButtonTapped(_ sender: Any) {
        photoGalleryManager.getImageFromPhotoLibrary(from: self) { [unowned self] image in
            
            processImported(image: image)
        }
    }
}

extension AnatomyCreatorImportViewController: SkinSaveDialogDelegate {
    func saveSkin(with name: String, withExit: Bool) {
        
        saveHelper()
        
        navigationController?.popViewController(animated: true)
    }
    
    func cancelSave(withExit: Bool) {
        navigationController?.popViewController(animated: true)
    }
    
    func warningPromptName(presentAlert: UIAlertController) {
        present(presentAlert, animated: true)
    }
}
