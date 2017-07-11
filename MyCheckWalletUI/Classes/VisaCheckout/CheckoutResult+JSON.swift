//
//  CheckoutResult+JSON.swift
//  Pods
//
//  Created by elad schiller on 7/9/17.
//
//

import Foundation
import VisaCheckoutSDK


extension CheckoutResult{
    public var payload: [String: Any]?  {
        get{
            if let callId = callId , let encryptedKey = encryptedKey, let encryptedPaymentData = encryptedPaymentData,
                statusCode == .success{
            return ["encKey": encryptedKey,
                    "encPaymentData": encryptedPaymentData,
                "callid": callId]
            }
            return nil
        }
    
    }
}
