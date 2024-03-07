//  Created by Melnykov Valerii on 14.07.2023
//

import UIKit
import SystemConfiguration

protocol NetworkStatusMonitorDelegate : AnyObject {
    func showMess()
}

class NetworkStatusMonitor {
    static let shared = NetworkStatusMonitor()
    
    weak var delegate : NetworkStatusMonitorDelegate?
    
    private var didShowAlert = false

    public private(set) var isNetworkAvailable: Bool = true {
        didSet {
            if !isNetworkAvailable {
                DispatchQueue.main.async {
                    if !self.didShowAlert {
                        self.didShowAlert = true
                        self.delegate?.showMess()
                    }
                }
            } else {
                self.didShowAlert = false
            }
        }
    }

    private init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.isNetworkAvailable = self.checkInternetConnectivity()
        })
    }

    @discardableResult
    func checkInternetConnectivity() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        if isReachable && !needsConnection {
            // Connected to the internet
            // Do your network-related tasks here
            return true
        } else {
            // Not connected to the internet
            return false
        }
    }
}
