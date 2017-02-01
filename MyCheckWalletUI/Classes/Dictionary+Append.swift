//
//  Dictionary+Append.swift
//  Pods
//
//  Created by elad schiller on 12/26/16.
//
//

import UIKit

extension Dictionary {
    mutating func append(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
