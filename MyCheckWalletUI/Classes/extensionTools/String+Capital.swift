//
//  String+Capital.swift
//  Pods
//
//  Created by elad schiller on 12/7/16.
//
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
