//
//  LocalData+MCCheckoutViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 10/26/17.
//

import Foundation


internal extension LocalData{
   
   internal func getSelectCreditCardToWalletsSeporatorText(fallback: String? = nil) -> String{
        
        return getString("checkoutPageorAddCardWith" , fallback: fallback)
    }
    
}
