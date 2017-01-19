//
//  Constants.swift
//  SMNumberWheel
//
//  Created by Sina Moetakef on 2017-01-18.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

struct StoryboardsSegues {
    static let fromContainerViewToPropertiesVC = "FromContainerViewToPropertiesVC"
}


// MARK: String extensions
extension String {
    var doubleValue: Double? {
        if let number = NumberFormatter().number(from: self) {
            return number.doubleValue
        }
        return nil
    }
}
