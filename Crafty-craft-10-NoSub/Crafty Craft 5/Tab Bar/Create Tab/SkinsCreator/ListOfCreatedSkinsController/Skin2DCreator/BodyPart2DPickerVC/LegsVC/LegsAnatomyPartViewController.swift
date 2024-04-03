//
//  LegsAnatomyPartViewControllerViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

// MARK: - LegsBodyPartViewController

class LegsAnatomyPartViewController: UIViewController {
    
    var currentEditableSkin: AnatomyCreatedModel?
    var leg: BodyPartSide = CubicHuman.BodyPart.rightLeg

    // MARK: - Outlets
    
    @IBOutlet private weak var backLegImageView: UIImageView!
    @IBOutlet private weak var leftLegImageView: UIImageView!
    @IBOutlet private weak var frontLegImageView: UIImageView!
    @IBOutlet private weak var rightLegImageView: UIImageView!
    @IBOutlet private weak var bottomLegImageView: UIImageView!
    @IBOutlet private weak var topLegImageView: UIImageView!
    @IBOutlet private weak var navigationBarView: UIView!

    //MARK: - Init
    init(currentEditableSkin: AnatomyCreatedModel? = nil, leg: BodyPartSide) {
        super.init(nibName: nil, bundle: nil)
        
        self.currentEditableSkin = currentEditableSkin
        self.leg = leg
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        AppDelegate.log("LegsBodyPartViewControllerViewController is Successfully deinited")
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLegImages()
        setupNavigation()
        setupGestureRecognizers()
        
        topLegImageView.layer.borderWidth = 2
        topLegImageView.layer.borderColor = UIColor(named: "EerieBlackColor")?.cgColor
        
        updateImageFor(imageView: topLegImageView, image: nil)
        updateImageFor(imageView: bottomLegImageView, image: nil)
        updateImageFor(imageView: frontLegImageView, image: nil)
        updateImageFor(imageView: backLegImageView, image: nil)
        updateImageFor(imageView: leftLegImageView, image: nil)
        updateImageFor(imageView: rightLegImageView, image: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        colorSides()
    }
    
    private func selectionSort<T: Comparable>(_ array: inout [T]) {
        guard array.count > 1 else { return }
        
        for i in 0..<array.count - 1 {
            var minIndex = i
            for j in i+1..<array.count {
                if array[j] < array[minIndex] {
                    minIndex = j
                }
            }
            if i != minIndex {
                array.swapAt(i, minIndex)
            }
        }
    }
    
    // MARK: - Setup
    private func setupLegImages() {
        let _ = [backLegImageView, leftLegImageView, frontLegImageView, rightLegImageView].map({ $0?.image = UIImage(named: "general_arm")})
    }
    
    private func gapYear(_ g: Int, _ m: Int, _ n: Int) -> (Int, Int)? {
        var temporaryNumber = m
        var lastPrimeNumber: Int?
        
        while temporaryNumber < n {
            
            if isPrimaryUs(temporaryNumber) {
                if let last = lastPrimeNumber, temporaryNumber - last == g {
                    print(temporaryNumber, last)
                    return (last, temporaryNumber)
                } else {
                    lastPrimeNumber = temporaryNumber
                }
            }
            
            temporaryNumber += 1
        }
        
        return nil
    }
    
    private func isPrimaryUs(_ number: Int) -> Bool {
        if [2, 3].contains(number) { return true }
        let maxDivider = Int(sqrt(Double(number)))
        if maxDivider < 2 { return false }
        return number > 1 && !(2...maxDivider).contains { number % $0 == 0 }
    }
    
    private func setupNavigation() {
        navigationBarView.backgroundColor = .clear
    }
    
    private func setupGestureRecognizers() {
        let viewsToHandle = [backLegImageView, leftLegImageView, frontLegImageView, rightLegImageView, bottomLegImageView, topLegImageView]
        viewsToHandle.forEach(addTapGesture(for:))
    }
    
    // MARK: - Gesture Handling
    
    private func addTapGesture(for view: UIImageView?) {
        guard let view = view else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(perspectiveTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    @objc func perspectiveTapped(_ sender: UITapGestureRecognizer) {
        
        guard let view = sender.view else { return }

        var bodyPartSide: Side?
        
        switch view {

        case topLegImageView:
            bodyPartSide = leg.top
        case bottomLegImageView:
            bodyPartSide = leg.bottom
        case leftLegImageView:
            bodyPartSide = leg.left
        case rightLegImageView:
            bodyPartSide = leg.right
        case frontLegImageView:
            bodyPartSide = leg.front
        case backLegImageView:
            bodyPartSide = leg.back

        default:
            AppDelegate.log("User tapped unknown bodyView")
            break
        }
        guard let bodyPartSide = bodyPartSide else {
            return
        }
        
        self.navigationController?.pushViewController(SkinDesignViewController(bodyPartSide: bodyPartSide, currentEditableSkin: self.currentEditableSkin, imageDataCallback: { [weak self] (skin) in
            
            let realm = RealmService.shared
            //if skin already exists in Realm
            if let _ = realm.getCreatedSkinByID(skinID: skin.id) {
                realm.editCreatedSkinAssemblyDiagram(createdSkin: skin, newDiagram: skin.skinAssemblyDiagram)
                
                //if skin is NEW
            } else {
                let skinForRealming = skin.getRealmModelToSave()
                realm.addNewSkin(skin: skinForRealming)
            }
            
            realm.editCreatedSkinName(createdSkin: skin, newName: skin.name)
            
            self?.currentEditableSkin?.name = skin.name
            
            self?.navigationController?.popViewController(animated: true)
            
        }),animated:  true)
    }
    
    private func colorSides() {
        
        let imageViews: [UIImageView] = [topLegImageView, bottomLegImageView, leftLegImageView, rightLegImageView, frontLegImageView, backLegImageView]
        imageViews.forEach({ $0.layer.magnificationFilter = .nearest })
        imageViews.forEach({ $0.setBorder(size: 2, color: .black) })
        
        let sides = [
            leg.top,
            leg.bottom,
            leg.back,
            leg.front,
            leg.left,
            leg.right
        ]
        
        for theSide in sides {
            let sideImg = currentEditableSkin?.skinAssemblyDiagram?.extractSubImage(
                startX: CGFloat(theSide.startX),
                startY: CGFloat(theSide.startY),
                width: CGFloat(theSide.width),
                height: CGFloat(theSide.height))
            
            switch true {
            case theSide.name.contains("Top"):
                updateImageFor(imageView: topLegImageView, image: sideImg)
            case theSide.name.contains("Bottom"):
                updateImageFor(imageView: bottomLegImageView, image: sideImg)
            case theSide.name.contains("Front"):
                updateImageFor(imageView: frontLegImageView, image: sideImg)
            case theSide.name.contains("Back"):
                updateImageFor(imageView: backLegImageView, image: sideImg)
            case theSide.name.contains("Left"):
                updateImageFor(imageView: leftLegImageView, image: sideImg)
            case theSide.name.contains("Right"):
                updateImageFor(imageView: rightLegImageView, image: sideImg)
                
            default:
                AppDelegate.log("theSide is wrong")
                return
            }
        }
        
    }
    
    private func updateImageFor(imageView: UIImageView, image: UIImage?) {
        imageView.image = image
    }

    // MARK: - Actions

    @IBAction private func onNavBarBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
