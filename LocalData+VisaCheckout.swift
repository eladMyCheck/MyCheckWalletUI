//
//  LocalData+VisaCheckout.swift
//  Pods
//
//  Created by elad schiller on 9/13/17.
//
//

import Foundation

extension LocalData{
   

    
    func getAddedVisaCheckoutMessage() -> String{
        let msg = getString("thirdPartyPaymentMethodsvisaCheckoutaddPaymentMethodSuccess")
        return msg
    }
}
