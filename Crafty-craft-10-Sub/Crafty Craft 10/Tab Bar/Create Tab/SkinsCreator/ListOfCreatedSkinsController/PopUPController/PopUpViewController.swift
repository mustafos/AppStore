import UIKit


protocol CustomAlertViewControllerDelegate: AnyObject {
    func dismissCustomAlert()
    func open2DEditor()
    func open3DEditor()
    func open3DEditor128x128()
    func importSkinFromGallery()
}

class PopUpViewController: UIViewController {
    
    private var showForSavedSkin: Bool
    private var is128sizeSkin: Bool?
    
    // MARK: - Outlets
    
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var createNew2DButton: UIButton!
    @IBOutlet private weak var createNew3DButton: UIButton!
    @IBOutlet private weak var createNew3DWithOptionsButton: UIButton!
    @IBOutlet private weak var importButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
    @IBOutlet private weak var controllerTitle: UILabel!
    
    // MARK: - Properties
    
    private weak var delegate: CustomAlertViewControllerDelegate?
    
    //MARK: - Init
    
    init(showFor savededSkin: Bool, is128sizeSkin: Bool? = nil, delegate: CustomAlertViewControllerDelegate) {
        self.showForSavedSkin = savededSkin
        self.is128sizeSkin = is128sizeSkin
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        var views = [UIButton]()
        if showForSavedSkin {
            if is128sizeSkin == true {
                views = [createNew3DWithOptionsButton, cancelButton]
                createNew2DButton.isHidden = true
                createNew3DButton.isHidden = true
            } else {
                views = [createNew2DButton, createNew3DButton, cancelButton]
                createNew3DWithOptionsButton.isHidden = true
            }
            importButton.isHidden = true
        } else {
            views = [createNew2DButton, createNew3DButton, importButton,  createNew3DWithOptionsButton, cancelButton]
        }
        
        let cornerRadius: CGFloat = Device.iPad ? 25 : 7
        for view in views {
            view.roundCorners(cornerRadius)
            view.clipsToBounds = true
        }
        
        backgroundView.roundCorners(cornerRadius)
        backgroundView.clipsToBounds = true
        
        setupTitles()
    }
    
    private func setupTitles() {
        if showForSavedSkin == true {
            controllerTitle.text = "Edit Skin"
            createNew2DButton.setTitle("Edit in 2D", for: .normal)
            createNew3DButton.setTitle("Edit in 3D", for: .normal)
            createNew3DWithOptionsButton.setTitle("Edit in 3D (128*128)", for: .normal)
        } else {
            controllerTitle.text = "NEW"
            createNew2DButton.setTitle("Create New 2D", for: .normal)
            createNew3DButton.setTitle("Create New 3D", for: .normal)
            createNew3DWithOptionsButton.setTitle("Create New 3D (128*128)", for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onCreateNew2DButtonTapped(_ sender: UIButton) {
        delegate?.open2DEditor()
    }
    
    @IBAction func onCreateNew3DButtonTapped(_ sender: UIButton) {
        delegate?.open3DEditor()
    }
    
    @IBAction func onCreateNew3DWithOptionsButtonTapped(_ sender: UIButton) {
        delegate?.open3DEditor128x128()
    }
    
    @IBAction func onImportButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Import Texture", message: "Are you sure you want to import texture from the Photo library?", preferredStyle: .alert)
        
        // Add "confirm" action
        let deleteAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.delegate?.importSkinFromGallery()
        }
        alert.addAction(deleteAction)
        
        // Add "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonTapped(_ sender: UIButton) {
        delegate?.dismissCustomAlert()
    }
}
