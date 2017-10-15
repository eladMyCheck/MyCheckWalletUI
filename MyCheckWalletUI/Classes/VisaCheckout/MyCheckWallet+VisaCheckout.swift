//
//  MyCheckWallet+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//

import UIKit
import MyCheckCore
extension URIs{
    static let addVisaCheckout = "/wallet/api/v1/wallet/paymentMethod"
}


extension Wallet {

    func addVisaCheckout(payload: [String: Any], singleUse: Bool , success: @escaping ((PaymentMethodInterface) -> Void) , fail: ((NSError) -> Void)? ){

        guard let payloadString = JSONToString(JSON: payload) else {
            if let fail = fail {
                fail(ErrorCodes.visaCheckoutParsingFailed.getError())
            }
            return
        }
        
        
        let params: [String: Any] = [ "source": "visacheckout" , "visa_payload": payloadString  , "is_single_use":  String(describing: NSNumber(value: singleUse))]
        
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.addVisaCheckout
            
            self.request(urlStr, method: .post, parameters: params , success: { JSON in
                
                
                if let methodJSON = JSON["pm"] as? NSDictionary , let pm =  CreditCardPaymentMethod(JSON: methodJSON){
                        success(pm)
                }else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
        
    }
   
    private func JSONToString(JSON: [String: Any]) -> String?{
    
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: JSON,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
           return theJSONText
        }
    return nil
    }
}

