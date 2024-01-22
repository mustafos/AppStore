//
//  CheckParameters.swift
//  Auto Clicker
//
//  Created by Igor Kononov on 30.06.2023.
//

import UIKit

enum Device {
    static var iPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    static var iPad: Bool {
        return UIDevice().userInterfaceIdiom == .pad
    }
}

enum ScreenSize {
    static var width = UIScreen.main.bounds.size.width
    static var height = UIScreen.main.bounds.size.height
}
