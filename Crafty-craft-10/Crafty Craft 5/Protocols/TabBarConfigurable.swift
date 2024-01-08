import UIKit

protocol TabBarConfigurable {
    var tabBarIcon: UIImage? { get }
    var tabBarSelectedIcon: UIImage? { get }
    var tabBarTitle: String { get }
}
