//
//  TorsoAnatomyPartViewController.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class TorsoAnatomyPartViewController: UIViewController {
    
    var currentEditableSkin: AnatomyCreatedModel?
    var body: BodyPartSide = CubicHuman.BodyPart.body

    @IBOutlet weak var backBody: UIImageView!
    @IBOutlet weak var leftBody: UIImageView!
    @IBOutlet weak var frontBody: UIImageView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var bottomBody: UIImageView!
    @IBOutlet weak var topBody: UIImageView!
    @IBOutlet weak var rightBody: UIImageView!
    
    //MARK: - Init
    
    init(currentEditableSkin: AnatomyCreatedModel? = nil, body: BodyPartSide) {
        super.init(nibName: nil, bundle: nil)
        
        self.currentEditableSkin = currentEditableSkin
        self.body = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        AppDelegate.log("TorsoBodyPartViewController is Successfully deinited")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture(for: backBody)
        addTapGesture(for: frontBody)
        addTapGesture(for: leftBody)
        addTapGesture(for: rightBody)
        addTapGesture(for: topBody)
        addTapGesture(for: bottomBody)

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
    
    private func garetSaveOn(_ g: Int, _ m: Int, _ n: Int) -> (Int, Int)? {
        var prev: Int?
        for num in m...n {
            if num == 2 && g == 1 { return (2, 3) }
            if num == 3 { prev = num; continue }
            guard !(2...Int(sqrt(Double(num)))).contains(where: { num % $0 == 0 }) else { continue }
            if let prev = prev, num - prev == g { return (prev, num) }
            prev = num
        } // OK
        return nil
    }

    @objc func perspectiveTapped(_ sender: UITapGestureRecognizer) {

        guard let view = sender.view else { return }
        var bodyPartSide: Side?
        
        switch view {

        case topBody:
            bodyPartSide = body.top
        case bottomBody:
            bodyPartSide = body.bottom
        case leftBody:
            bodyPartSide = body.left
        case rightBody:
            bodyPartSide = body.right
        case frontBody:
            bodyPartSide = body.front
        case backBody:
            bodyPartSide = body.back

        default:
            AppDelegate.log("User tapped unknown bodyView")
            break
        }
        guard let bodyPartSide = bodyPartSide else {
            return
        }

        self.navigationController?.pushViewController(SkinDesignViewController(bodyPartSide: bodyPartSide, currentEditableSkin: currentEditableSkin, imageDataCallback: { [weak self] (skin) in
            
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
            
        }), animated:  true)
    }


    //MARK: Private func
    
    private func colorSides() {
        
        let imageViews: [UIImageView] = [topBody, bottomBody, leftBody, rightBody, frontBody, backBody]
        imageViews.forEach({ $0.layer.magnificationFilter = .nearest })
        imageViews.forEach({ $0.setBorder(size: 2, color: UIColor(named: "EerieBlackColor")!) })
            
        let sides = [
            body.top,
            body.bottom,
            body.back,
            body.front,
            body.left,
            body.right
        ]
        
        for theSide in sides {
            let sideImg = currentEditableSkin?.skinAssemblyDiagram?.extractSubImage(
                startX: CGFloat(theSide.startX),
                startY: CGFloat(theSide.startY),
                width: CGFloat(theSide.width),
                height: CGFloat(theSide.height))
            
            switch true {
            case theSide.name.contains("Top"):
                topBody.image = sideImg
            case theSide.name.contains("Bottom"):
                bottomBody.image = sideImg
            case theSide.name.contains("Front"):
                frontBody.image = sideImg
            case theSide.name.contains("Back"):
                backBody.image = sideImg
            case theSide.name.contains("Left"):
                leftBody.image = sideImg
            case theSide.name.contains("Right"):
                rightBody.image = sideImg
                
            default:
                AppDelegate.log("theSide is wrong")
                return
            }
        }
        
    }

    @IBAction func onNavBarBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
