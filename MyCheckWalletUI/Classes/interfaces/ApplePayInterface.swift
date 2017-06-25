//
//  ApplePayInterface.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation

///will answer and update applepay specific logic
internal protocol ApplePayInterface {
    func isApplePayDefault() -> Bool
    func changeApplePayDefault(to newDefault: Bool)
}
