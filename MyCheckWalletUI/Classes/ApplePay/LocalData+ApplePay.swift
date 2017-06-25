//
//  LocalData+ApplePay.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation
private let applePayDefaultKey = "MCApplePayDefaultKey"

//ApplePay related functions
extension LocalData{
    static func wasApplePayDefault() -> Bool{
        return UserDefaults.standard.bool(forKey: applePayDefaultKey)

    }
    
   static func changeApplePayDefault(to newDefault: Bool) {
        UserDefaults.standard.set(newDefault, forKey: applePayDefaultKey)
        UserDefaults.standard.synchronize()
    }

}
