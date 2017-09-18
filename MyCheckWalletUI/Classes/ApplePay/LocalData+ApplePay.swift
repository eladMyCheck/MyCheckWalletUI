//
//  LocalData+ApplePay.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation

private let applePayDefaultKey = "MCApplePayDefaultKey"
private let initialRunKey = "MCInitialRunKey"

//ApplePay related functions
extension LocalData{
    
    static func wasApplePayDefault() -> Bool{
      //checking if this is the first time. if so setting to yes
      let notFirst = UserDefaults.standard.bool(forKey: initialRunKey)
      if !notFirst{
        UserDefaults.standard.set(true, forKey: initialRunKey)
        UserDefaults.standard.synchronize()

        LocalData.changeApplePayDefault(to: true)
      }
        return UserDefaults.standard.bool(forKey: applePayDefaultKey)
      

    }
    
   static func changeApplePayDefault(to newDefault: Bool) {
        UserDefaults.standard.set(newDefault, forKey: applePayDefaultKey)
        UserDefaults.standard.synchronize()
    }

  /// Returns wether or not this is the first time the app is running. used for initial setup.

}
