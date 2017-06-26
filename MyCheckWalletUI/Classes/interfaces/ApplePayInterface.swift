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
  
    /// Is apple pay the default payment method
    ///
    /// - Returns: true if it is
  static  func isApplePayDefault() -> Bool
  
    /// Change the default state of apple pay
    ///
    /// - Parameter newDefault: The new value to be set
   static func changeApplePayDefault(to newDefault: Bool)
  
  /// Get a payment method that reprisents Apple Pay
  ///
  /// - Returns: The Apple Pay payment method object
static  func getApplePayPaymentMethod() -> PaymentMethod?
  
  /// Returns true iff the user can make a payment using Apple Pay. This means the device supports Apple Pay,  that their is a card in the Apple wallet and that the card belongs to one of the supported payment methods.
  ///
  /// - Returns: true if the user can make a payment with Apple Pay
 static func canPayWithApplePay() -> Bool
  
  /// Returns true iff the device supports Apple Pay. This doesnt mean he can make payments. he might not be able to because their is no card in the Apple wallet for example.
  ///
  /// - Returns: true if the device supports Apple Pay.
 static func deviceSupportsApplePay() -> Bool
}
