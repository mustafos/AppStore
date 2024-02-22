import UIKit

extension UIViewController {

    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
    
    func presentFullScreenViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: false)
    }
    
}
