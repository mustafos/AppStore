import UIKit


class HeadBodyPartViewController: UIViewController {

    var currentEditableSkin: SkinCreatedModel?
    var bodyPartSide = CubicHuman.BodyPart.head

    // MARK: - Outlets

    @IBOutlet private weak var backHeadImageView: UIImageView!
    @IBOutlet private weak var rightHeadImageView: UIImageView!
    @IBOutlet private weak var leftHeadImageView: UIImageView!
    @IBOutlet private weak var frontHeadImageView: UIImageView!
    @IBOutlet private weak var bottomHeadImageView: UIImageView!
    @IBOutlet private weak var topHeadImageView: UIImageView!
    @IBOutlet private weak var navigationBarView: UIView!


    // MARK: - Actions

    @IBAction private func onNavBarBackButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Init
    
    init(currentEditableSkin: SkinCreatedModel? = nil, layerToEdit: CurrentEditableLayer) {
        super.init(nibName: nil, bundle: nil)
        
        self.currentEditableSkin = currentEditableSkin
        if layerToEdit == .innerLayer {
            bodyPartSide = CubicHuman.BodyPart.head
        } else {
            bodyPartSide = CubicHuman.BodyPart.head1
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        AppDelegate.log("HeadBodyPartViewController is Successfully deinited")
    }


    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupHeadImages()
        setupNavigation()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colorSides()
    }
    
    // MARK: - Setup

    private func setupBackground() {
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "Green Background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupHeadImages() {
        let headImageViews: [UIImageView] = [backHeadImageView, rightHeadImageView, leftHeadImageView, frontHeadImageView, bottomHeadImageView, topHeadImageView]
        headImageViews.forEach { $0.image = UIImage(named: "general_head") }
        headImageViews.forEach{ $0.layer.magnificationFilter = .nearest }
        headImageViews.forEach{ $0.setBorder(size: 2, color: UIColor(named: "greenCCRedesign")!) }
    }
    
    private func setupNavigation() {
        navigationBarView.backgroundColor = .clear
    }
    
    private func setupGestureRecognizers() {
        let viewsToHandle = [backHeadImageView, rightHeadImageView, leftHeadImageView, frontHeadImageView, bottomHeadImageView, topHeadImageView]
        viewsToHandle.forEach(addTapGesture(for:))
    }
    
    private func colorSides() {
        let sidesArr = [
            bodyPartSide.top,
            bodyPartSide.bottom,
            bodyPartSide.back,
            bodyPartSide.front,
            bodyPartSide.left,
            bodyPartSide.right
        ]

        var img: UIImage?

        for theSide in sidesArr {

        img = currentEditableSkin?.skinAssemblyDiagram
            
            let sideImg = img?.extractSubImage(
                startX: CGFloat(theSide.startX),
                startY: CGFloat(theSide.startY),
                width: CGFloat(theSide.width),
                height: CGFloat(theSide.height))
            
            
            switch true {
            case theSide.name.contains("Top"):
                topHeadImageView.image = sideImg
            case theSide.name.contains("Bottom"):
                bottomHeadImageView.image = sideImg
            case theSide.name.contains("Front"):
                frontHeadImageView.image = sideImg
            case theSide.name.contains("Back"):
                backHeadImageView.image = sideImg
            case theSide.name.contains("Left"):
                leftHeadImageView.image = sideImg
            case theSide.name.contains("Right"):
                rightHeadImageView.image = sideImg
                
            default:
                AppDelegate.log("theSide is wrong")
                return
            }
        }
    }


    // MARK: - Gesture Handling

    private func addTapGesture(for view: UIImageView?) {
        guard let view = view else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }

        AppDelegate.log("\(view.accessibilityIdentifier ?? "Head view") was tapped")

        var bodyPartSide: Side?
        
        switch view {

        case topHeadImageView:
            bodyPartSide = self.bodyPartSide.top
        case bottomHeadImageView:
            bodyPartSide = self.bodyPartSide.bottom
        case rightHeadImageView:
            bodyPartSide = self.bodyPartSide.right
        case leftHeadImageView:
            bodyPartSide = self.bodyPartSide.left
        case frontHeadImageView:
            bodyPartSide = self.bodyPartSide.front
        case backHeadImageView:
            bodyPartSide = self.bodyPartSide.back
        
        default:
            AppDelegate.log("User tapped unknown Side HeadBodyPartViewController")
        }

        guard let bodyPartSide = bodyPartSide else {
            return
        }

        navigationController?.pushViewController(SkinCreatorViewController(bodyPartSide: bodyPartSide, currentEditableSkin: currentEditableSkin, imageDataCallback: { [weak self] (skin) in
            
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
}
