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
    static let getBraintreeToken = "/wallet/api/v1/external-payment/vzero/token"
    static let addPayPal =  "/wallet/api/v1/wallet/paymentMethod"
}


extension Wallet {

    func getBraintreeToken(_ success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ){
       
        if let token = braintreeToken {
            success(token)
            return
        }
        
        
        let params: [String: Any] = [ : ]
        
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.getBraintreeToken
            
            self.request(urlStr, method: .get, parameters: params , success: { JSON in
                if let newToken = JSON["token"] as? String{
                    self.braintreeToken = newToken
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
    
    func addPayPal(_ nonce : String,_ deviceData: [String:String], singleUse: Bool,  success: @escaping ((PaymentMethodInterface?) -> Void) , fail: ((NSError) -> Void)? ){
        
        let params : [String : Any] = ["nonce":nonce,"device-data":deviceData, "source":"paypal" , "is_single_use":  String(describing: NSNumber(value: singleUse))]
       
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.addPayPal
            
            Networking.shared.request(urlStr, method: .post, parameters: params , success: { JSON in
                let pm =  JSON["pm"] as! NSDictionary
                let method = PayPalPaymentMethod(JSON: pm)
                success(method)
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }

    }
}
