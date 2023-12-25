import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - Private properties -
    private let isIpad = Device.iPad
    
    private let networkingMonitor = NetworkStatusMonitor.shared
    
    private var tabBarTitleHorizontalOffset: CGFloat { isIpad ? 80 : 40 }
    
    private lazy var contentViewController: UIViewController = {
        let viewController = ContentTabViewController()
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "Content TabBar Icon", size: CGSize(width: 24, height: 24))
            unselectedImage = UIImage.resizedImage(named: "Content TabBar Icon", size: CGSize(width: 24, height: 24))
        }
        viewController.tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        
        return viewController
    }()
    
    private lazy var createViewController: UIViewController = {
        let viewController = CreateTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "Create TabBar Icon", size: CGSize(width: 24, height: 24))
            unselectedImage = UIImage.resizedImage(named: "Create TabBar Icon", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        
        return viewController
    }()
    
    private lazy var seedsViewController: UIViewController = {
        let viewController = SeedTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "Seed TabBar Icon", size: CGSize(width: 24, height: 24))
            unselectedImage = UIImage.resizedImage(named: "Seed TabBar Icon", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        
        return viewController
    }()
    
    private lazy var serversViewController: UIViewController = {
        let viewController = ServersTabViewController()
        
        var unselectedImage: UIImage? = viewController.tabBarIcon
        var selectedImage = viewController.tabBarIcon
        var title: String? = viewController.tabBarTitle
        
        if isIpad {
            selectedImage = UIImage.resizedImage(named: "Servers TabBar Icon", size: CGSize(width: 24, height: 24))
            unselectedImage = UIImage.resizedImage(named: "Servers TabBar Icon", size: CGSize(width: 24, height: 24))
        }
        
        viewController.tabBarItem = UITabBarItem(title: title, image: unselectedImage, selectedImage: selectedImage)
        
        return viewController
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setTabBarAppearance()
        
        setupManagers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !networkingMonitor.isNetworkAvailable {
            showMess()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Methods -
    private func setTabBarAppearance() {
        viewControllers = [createViewController, contentViewController, seedsViewController, serversViewController]
        
        let positionOnX: CGFloat = 10
        let positionOnY: CGFloat = 14
        let width = tabBar.bounds.width - positionOnX * 2
        let height = tabBar.bounds.height + positionOnY * 2
        
        let roundLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath(
            roundedRect: CGRect(
                x: positionOnX,
                y: tabBar.bounds.minY - positionOnY,
                width: width,
                height: height
            ),
            cornerRadius: height / 2
        )
        
        roundLayer.path = bezierPath.cgPath
        
        tabBar.layer.insertSublayer(roundLayer, at: 0)
        
        tabBar.itemWidth = width / 5
        tabBar.itemPositioning = .centered
        
        roundLayer.fillColor = UIColor(red: 0.97, green: 0.81, blue: 0.38, alpha: 1).cgColor
        
        // Adding shadow
        roundLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        roundLayer.shadowOpacity = 1
        roundLayer.shadowRadius = 4
        roundLayer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Adding border
        roundLayer.borderWidth = 1
        roundLayer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1).cgColor
        
        tabBar.tintColor = UIColor(named: "BeigeColor")
        tabBar.unselectedItemTintColor = UIColor(named: "EerieBlackColor")
    }
    private func setupManagers() {
        self.networkingMonitor.delegate = self
    }
}

extension TabBarViewController: NetworkStatusMonitorDelegate {
    func goodInnet() {}
    
    func showMess() {
        self.showNoInternetMess()
    }
}
