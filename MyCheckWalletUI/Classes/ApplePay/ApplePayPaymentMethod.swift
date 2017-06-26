  //
//  ApplePayPaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 04/12/2016.
//
//

import UIKit
class ApplePayPaymentMethod: PaymentMethod {
  
  override var checkoutName: String? {get{
               return "Apple Pay"
        }
    }
  internal convenience init?( isDefault:Bool){
    self.init(for: .applePay, name: "Apple Pay", Id: "ApplePay", token: "ApplePay", checkoutName: "Apple Pay")
    self.isDefault = isDefault
    
  }
  

  
  
  
  
  
}
