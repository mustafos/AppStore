//
//  CancellableProtocol.swift
//  Crafty Craft 5
//
//  Created by dev on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

protocol Cancellable {

    // MARK: - Methods
    func cancel()
}

extension URLSessionTask: Cancellable {

}
