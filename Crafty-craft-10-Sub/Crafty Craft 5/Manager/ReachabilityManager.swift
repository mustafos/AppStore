//
//  ReachabilityManager.swift
//  Crafty Craft 5
//
//  Created by dev on 19.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import Network

enum NetworkConnectionState {
    case unknown, connected, disconnected
}

protocol ReachabilityManagerProtocol {
    
    var state: NetworkConnectionState { get }
    
    func checkInternetConnection(_ completion: @escaping ReachabilityCompletion)
}

typealias ReachabilityCompletion = ((NetworkConnectionState) -> Void)

class ReachabilityManager: ReachabilityManagerProtocol {
    
    private(set) var state: NetworkConnectionState = .unknown
    
    private let monitor = NWPathMonitor()
    
    deinit {
        monitor.cancel()
    }
    
    func checkInternetConnection(_ completion: @escaping ReachabilityCompletion) {
        
        monitor.pathUpdateHandler = { [unowned self] path in
            var state: NetworkConnectionState = .unknown
            
            if path.status != .satisfied {
                state = .disconnected
            } else if path.usesInterfaceType(.cellular) || path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet) {
                state = .connected
            }
            
            self.state = state
            
            completion(state)
        }
        
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
