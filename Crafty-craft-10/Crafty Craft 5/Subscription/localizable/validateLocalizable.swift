//  Created by Melnykov Valerii on 14.07.2023
//

import Foundation


func localizedString(forKey key: String) -> String {
    var result = Bundle.main.localizedString(forKey: key, value: nil, table: nil)

    if result == key {
        result = Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    return result
}
