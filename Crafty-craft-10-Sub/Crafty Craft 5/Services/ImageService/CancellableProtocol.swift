//
//  CancellableProtocol.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

protocol Cancellable {

    // MARK: - Methods

    func cancel()

}

extension URLSessionTask: Cancellable {

}
