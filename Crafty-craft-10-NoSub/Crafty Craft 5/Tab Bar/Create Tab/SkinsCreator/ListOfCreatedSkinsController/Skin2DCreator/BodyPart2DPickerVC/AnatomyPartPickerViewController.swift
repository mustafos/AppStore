//
//  AnatomyPartPickerViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import BetterSegmentedControl

enum AnatomyPickerOption {
    case head
    case arm_or_leg
    case body
    case smallArmOrLeg
}

enum SelectedLayerForEditing {
    case outerLayer
    case innerLayer
    
    mutating func toggle() {
        switch self {
        case .outerLayer:
            self = .innerLayer
        case .innerLayer:
            self = .outerLayer
        }
    }
}

final class AnatomyPartPickerViewController: UIViewController {
    
    //MARK: - Private vars
    
    private var currentEditableSkin: AnatomyCreatedModel?
    private var layerToEdit: SelectedLayerForEditing = .outerLayer
    private var saveAlertView: SaveConfirmationView?
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var navigationBar: UIView!
    
    @IBOutlet weak var currentEditableSwitcher: BetterSegmentedControl!

    @IBOutlet private weak var leftArmComponentView: UIImageView!
    @IBOutlet private weak var rightLegComponentView: UIImageView!
    @IBOutlet private weak var leftLegComponentView: UIImageView!
    @IBOutlet private weak var bodyComponentView: UIImageView!
    @IBOutlet private weak var rightArmComponentView: UIImageView!
    @IBOutlet private weak var headComponentView: UIImageView!
    @IBOutlet private weak var bodyPartsContainer: UIView!
    
    //MARK: - Init
    init(currentEditableSkin: AnatomyCreatedModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.setupHelper(currentEditableSkin: currentEditableSkin)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupHelper(currentEditableSkin: AnatomyCreatedModel?) {
        
        if let localSkin = currentEditableSkin {
            self.currentEditableSkin = localSkin
            
            //Else block should never work, as all this stuff I do in previous controller(SkinEditorViewController), just in case of unpredictable changes in project
        } else {
            let newSkin = CreatedSkinRM()
            newSkin.name = "MY NEW SKIN "
            newSkin.id = RealmService.shared.generateID(object: newSkin)
            RealmService.shared.addNewSkin(skin: newSkin)
            
            let skinCreatedModel = AnatomyCreatedModel(realmedModel: newSkin)
            
            self.currentEditableSkin = skinCreatedModel
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        addTapGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorSides()
    }
    
    private func setupViews() {
        headComponentView.image = UIImage(named: "general_head")
        leftArmComponentView.image = UIImage(named: "general_arm")
        rightArmComponentView.image = UIImage(named: "general_arm")
        leftLegComponentView.image = UIImage(named: "general_arm")
        rightLegComponentView.image = UIImage(named: "general_arm")
        bodyComponentView.image = UIImage(named: "general_body")

        enableImageViewsBorder()
        configureView()
    }
    
    //MARK: Gestures
    private func addTapGestures() {
        addTapGesture(for: headComponentView)
        addTapGesture(for: leftArmComponentView)
        addTapGesture(for: rightLegComponentView)
        addTapGesture(for: leftLegComponentView)
        addTapGesture(for: bodyComponentView)
        addTapGesture(for: rightArmComponentView)
    }
    
    private func addTapGesture(for view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }
    
    func checkForFactor(_ base: Int, _ factor: Int) -> Bool {
        return base % factor == 0
    }
    
    private func configureView() {
        currentEditableSwitcher.segments = LabelSegment.segments(withTitles: ["Outer layer", "Inner layer"],
                                                                 normalFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                                 normalTextColor: UIColor(named: "EerieBlackColor"),
                                                                 selectedFont: UIFont(name: "Montserrat-Bold", size: 18),
                                                                 selectedTextColor: UIColor(named: "BeigeColor"))
    }
    
    @IBAction func segmentControlChangeAction(_ sender: BetterSegmentedControl) {
        switch sender.index {
        case 0:
            self.layerToEdit = .outerLayer
            self.colorSides()
            if layerToEdit != .outerLayer {
                layerToEdit.toggle()
            }
        default:
            self.layerToEdit = .innerLayer
            self.colorSides()
            if layerToEdit != .innerLayer {
                layerToEdit.toggle()
            }
        }
    }
    
    @IBAction private func onHomeButtonTapped(_ sender: UIButton) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        saveAlertView = SaveConfirmationView()
        saveAlertView?.delegate = self
        saveAlertView?.dialogTextLabel.text = "Select a name for your skin."
        saveAlertView?.frame = view.bounds
        
        saveAlertView?.setSkinNameSaveTextField.attributedPlaceholder = NSAttributedString(
            string: currentEditableSkin?.name ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(.gray)]
        )
        saveAlertView?.insertSubview(blurView, at: 0)
        view.addSubview(saveAlertView!)
    }
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        switch view {
            
        case headComponentView:
            AppDelegate.log("Head view was tapped")
            navigationController?.pushViewController(HeadAnatomyViewController(currentEditableSkin: currentEditableSkin, layerToEdit: layerToEdit), animated: true)
            
        case leftArmComponentView:
            var arm: BodyPartSide
            if layerToEdit == .innerLayer {
                arm = CubicHuman.BodyPart.leftArm
            } else {
                arm = CubicHuman.BodyPart.leftArm1
            }
            navigationController?.pushViewController(HandsAnatomyPartViewController(currentEditableSkin: currentEditableSkin, arm: arm),animated: true)
            
        case rightArmComponentView:
            var arm: BodyPartSide
            if layerToEdit == .innerLayer {
                arm = CubicHuman.BodyPart.rightArm
            } else {
                arm = CubicHuman.BodyPart.rightArm1
            }
            navigationController?.pushViewController(HandsAnatomyPartViewController(currentEditableSkin: currentEditableSkin, arm: arm), animated: true)
            
        case rightLegComponentView:
            var leg: BodyPartSide
            if layerToEdit == .innerLayer {
                leg = CubicHuman.BodyPart.rightLeg
            } else {
                leg = CubicHuman.BodyPart.rightLeg1
            }
            navigationController?.pushViewController(LegsAnatomyPartViewController(currentEditableSkin: currentEditableSkin, leg: leg), animated: true)
            
        case leftLegComponentView:
            var leg: BodyPartSide
            if layerToEdit == .innerLayer {
                leg = CubicHuman.BodyPart.leftLeg
            } else {
                leg = CubicHuman.BodyPart.leftLeg1
            }
            navigationController?.pushViewController(LegsAnatomyPartViewController(currentEditableSkin: currentEditableSkin, leg: leg), animated: true)
            
        case bodyComponentView:
            var body: BodyPartSide
            if layerToEdit == .innerLayer {
                body = CubicHuman.BodyPart.body
            } else {
                body = CubicHuman.BodyPart.body1
            }
            navigationController?.pushViewController(TorsoAnatomyPartViewController(currentEditableSkin: currentEditableSkin, body: body), animated: true)
            
        default:
            break
        }
    }
    
    //MARK: Private func
    
    private func choseUserAct(_ base: Int, _ factor: Int) -> Bool {
        var result = base%factor
        if result == 0 {
          return true
        } else {
            return false
        }
    }
    
    private func enableImageViewsBorder() {
        leftArmComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
        rightLegComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
        leftLegComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
        bodyComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
        rightArmComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
        headComponentView.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)
    }

    private func startFlashingBorder(for view: UIView) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = UIColor.black.cgColor
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.speed = 10
        
        view.layer.borderWidth = 2
        view.layer.add(animation, forKey: "FlashingBorder")
    }
    
    private func colorSides() {
        
        let _ = [headComponentView, bodyComponentView, leftArmComponentView, rightArmComponentView, leftLegComponentView, rightLegComponentView].map({ $0?.layer.magnificationFilter = .nearest })
        
        var sidesArr = [Side]()
        if layerToEdit == .innerLayer {
            sidesArr = [
                CubicHuman.BodyPart.head.front,
                CubicHuman.BodyPart.body.front,
                CubicHuman.BodyPart.leftArm.front,
                CubicHuman.BodyPart.rightArm.front,
                CubicHuman.BodyPart.leftLeg.front,
                CubicHuman.BodyPart.rightLeg.front
            ]
        } else {
            sidesArr = [
                CubicHuman.BodyPart.head1.front,
                CubicHuman.BodyPart.body1.front,
                CubicHuman.BodyPart.leftArm1.front,
                CubicHuman.BodyPart.rightArm1.front,
                CubicHuman.BodyPart.leftLeg1.front,
                CubicHuman.BodyPart.rightLeg1.front
            ]
        }
        
        for theSide in sidesArr {
            let sideImg = currentEditableSkin?.skinAssemblyDiagram?.extractSubImage(
                startX: CGFloat(theSide.startX),
                startY: CGFloat(theSide.startY),
                width: CGFloat(theSide.width),
                height: CGFloat(theSide.height))
            
            if theSide.name.contains("head") {
                headComponentView.image = sideImg
            } else if theSide.name.contains("body") {
                bodyComponentView.image = sideImg
            } else if theSide.name.contains("rightArm") {
                rightArmComponentView.image = sideImg
            } else if theSide.name.contains("leftArm") {
                leftArmComponentView.image = sideImg
            } else if theSide.name.contains("rightLeg") {
                rightLegComponentView.image = sideImg
            } else if theSide.name.contains("leftLeg") {
                leftLegComponentView.image = sideImg
            } else {
                AppDelegate.log("theSide is wrong")
            }
        }
    }
}

//MARK: - Save Alert Delegate methods

extension AnatomyPartPickerViewController: SkinSaveDialogDelegate {
    
    func saveSkin(with name: String, withExit: Bool) {
        currentEditableSkin?.name = name
        
        //If skin had been saved previously
        //Edit existing CreatedSkinRM
        if let _ = RealmService.shared.getCreatedSkinByID(skinID: currentEditableSkin?.id) {
            
            RealmService.shared.editCreatedSkinName(createdSkin: currentEditableSkin, newName: name)
            
            if let newPreview = bodyPartsContainer.toImage() {
                RealmService.shared.editCreatedSkinPreview(createdSkin: currentEditableSkin, newPreview: newPreview)
            }
            //Skin is new
            //Save currentEditableSkin into BD
        } else {
            guard let newPreview = bodyPartsContainer.toImage() else {
                return
            }
            
            currentEditableSkin?.preview = newPreview
            
            guard let skinForSaving = currentEditableSkin?.getRealmModelToSave() else {
                return
            }
            RealmService.shared.addNewSkin(skin: skinForSaving)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func cancelSave(withExit: Bool) {
        navigationController?.popViewController(animated: true)
    }
    
    func warningPromptName(presentAlert: UIAlertController) {
        present(presentAlert, animated: true)
    }
}
