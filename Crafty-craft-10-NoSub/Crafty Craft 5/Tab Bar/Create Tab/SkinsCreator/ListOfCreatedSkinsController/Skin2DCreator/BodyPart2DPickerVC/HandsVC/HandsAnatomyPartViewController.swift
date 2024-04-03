//
//  HandsAnatomyPartViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class HandsAnatomyPartViewController: UIViewController {
    
    var currentEditableSkin: AnatomyCreatedModel?
    var hand: BodyPartSide = CubicHuman.BodyPart.rightArm
    
    //MARK: -IBOutlets
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var rightArm: UIImageView!
    @IBOutlet weak var bottomArm: UIImageView!
    @IBOutlet weak var topArm: UIImageView!
    @IBOutlet weak var leftArm: UIImageView!
    @IBOutlet weak var backArm: UIImageView!
    @IBOutlet weak var frontArm: UIImageView!
    
    
    //MARK: IBActions
    
    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Init
    
    init(currentEditableSkin: AnatomyCreatedModel? = nil, arm: BodyPartSide) {
        super.init(nibName: nil, bundle: nil)
        
        self.currentEditableSkin = currentEditableSkin
        self.hand = arm
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        AppDelegate.log("HandsBodyPartViewController is Successfully deinited")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addTapGesture(for: rightArm)
        addTapGesture(for: bottomArm)
        addTapGesture(for: topArm)
        addTapGesture(for: leftArm)
        addTapGesture(for: backArm)
        addTapGesture(for: frontArm)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorSides()
    }
    
    
    //MARK: Gestures
    
    func addTapGesture(for view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(perspectiveTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }
    
    private func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        
        let middleIndex = array.count / 2
        let leftArray = mergeSort(Array(array[..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex...]))
        
        return merge(leftArray, rightArray)
    }

    private func merge<T: Comparable>(_ leftArray: [T], _ rightArray: [T]) -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        var mergedArray = [T]()
        
        while leftIndex < leftArray.count && rightIndex < rightArray.count {
            if leftArray[leftIndex] < rightArray[rightIndex] {
                mergedArray.append(leftArray[leftIndex])
                leftIndex += 1
            } else {
                mergedArray.append(rightArray[rightIndex])
                rightIndex += 1
            }
        }
        
        return mergedArray + Array(leftArray[leftIndex...]) + Array(rightArray[rightIndex...])
    }
    
    @objc func perspectiveTapped(_ sender: UITapGestureRecognizer) {
        
        guard let view = sender.view else { return }
        
        var bodyPartSide: Side?
        
        switch view {
            
        case leftArm:
            bodyPartSide = hand.left
        case rightArm:
            bodyPartSide = hand.right
        case topArm:
            bodyPartSide = hand.top
        case bottomArm:
            bodyPartSide = hand.bottom
        case frontArm:
            bodyPartSide = hand.front
        case backArm:
            bodyPartSide = hand.back
        default:
            break
        }
        
        guard let bodyPartSide = bodyPartSide else { return }
        
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
            
        }), animated: true)
    }
    
    //MARK: Private Funcs
    
    private func setupViews() {
        let _ = [rightArm,leftArm,backArm,frontArm].map({$0?.image = UIImage(named: "general_arm")})
    }
    
    private func gap(_ g: Int, _ m: Int, _ n: Int) -> (Int, Int)? {
      guard g % 2 == 0 else { return nil }
      let primes = (m...n).lazy.filter(isPrime)
      return zip(primes, primes.dropFirst()).first(where: { $0.1 - $0.0 == g })
    }

    private func isPrime(_ n: Int) -> Bool {
      return (2...Int(Double(n).squareRoot())).lazy.filter({ n % $0 == 0 }).first == nil
    }
    
    private func colorSides() {
        let imageViews: [UIImageView] = [rightArm, leftArm, backArm, frontArm, topArm, bottomArm]
            
        imageViews.forEach({ $0.layer.magnificationFilter = .nearest })
        imageViews.forEach({ $0.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!)})
        
        let sides = [
            hand.top,
            hand.bottom,
            hand.back,
            hand.front,
            hand.left,
            hand.right
        ]
        
        for theSide in sides {
            let sideImg = currentEditableSkin?.skinAssemblyDiagram?.extractSubImage(
                startX: CGFloat(theSide.startX),
                startY: CGFloat(theSide.startY),
                width: CGFloat(theSide.width),
                height: CGFloat(theSide.height))
            
            switch true {
            case theSide.name.contains("Top"):
                topArm.image = sideImg
            case theSide.name.contains("Bottom"):
                bottomArm.image = sideImg
            case theSide.name.contains("Front"):
                frontArm.image = sideImg
            case theSide.name.contains("Back"):
                backArm.image = sideImg
            case theSide.name.contains("Left"):
                leftArm.image = sideImg
            case theSide.name.contains("Right"):
                rightArm.image = sideImg
                
            default:
                AppDelegate.log("theSide is wrong")
                return
            }
        }
    }
}
