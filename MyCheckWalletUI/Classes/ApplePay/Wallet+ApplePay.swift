//
//  MyCheckWallet+ApplePay.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//

import UIKit
import MyCheckCore

extension URIs{
    static let addApplePay = "/wallet/api/v1/wallet/paymentMethod"
}




extension Wallet {
    
    func addApplePay(applePayToken: String, cardType: String , success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ){
        
        
        
        let params: [String: Any] = [ "source": "applepay" , "token": applePayToken, "card_type": cardType]
        
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.addApplePay
            
            self.request(urlStr, method: .post, parameters: params , success: { JSON in
                
                
                if let methodJSON = JSON["pm"] as? NSDictionary, let newToken = methodJSON["token"] as? String{
                    success(newToken)
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
    
    func hasPendingApplePayToken(success: @escaping ((Bool) -> Void) , fail: ((NSError) -> Void)? ){
        let params: [String: Any] = [ : ]
        
        let urlStr = Networking.shared.domain! + URIs.paymentMethods
        
        self.request(urlStr , method: .get, parameters: params , success: { JSON in
            
            guard  let methodsJSON = JSON["PaymentMethods"] as? NSArray else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
            return
            }
            
            for dic in methodsJSON as! [NSDictionary]{
                
                //checking the type of the card and creating the correct stuct
                if let source = dic["source"] as? String  , let pendingToken = dic["is_capped"] as? NSNumber, PaymentMethodType(source: source) == .applePay{
                    success(pendingToken.boolValue)
                    return
                }
            }
            success(false)
        }, fail: fail)
    }
}
