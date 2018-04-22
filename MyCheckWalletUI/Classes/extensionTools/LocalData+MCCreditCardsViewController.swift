//
//  LocalData+MCCreditCardsViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 06/11/2017.
//

import Foundation


internal extension LocalData{
  
  internal func getAddCreditCardText(fallback: String? = nil) -> String{
    
    return getString("managePaymentMethodsaddCard" , fallback: fallback)
  }

  
  internal func getAddCreditCardTintColor() -> UIColor{
    return getColor("managePaymentMethodscolorsaddCardTint" , fallback: UIColor.gray)
  }
  
  internal func getAddCreditCardTextColor() -> UIColor{
    return getColor("managePaymentMethodscolorsaddCardText" , fallback: UIColor.black)
  }
  
  internal func getAddCreditCardImageURL() -> URL?{
    
    return URL(string:getString("managePaymentMethodsimagesaddCard"))
  }
}

