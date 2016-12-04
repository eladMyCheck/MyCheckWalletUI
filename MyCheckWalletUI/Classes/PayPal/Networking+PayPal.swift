//
//  Networking+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//
import Braintree
import Alamofire

import UIKit

extension Networking {
    
    
    func getBraintreeToken(_ accessToken: String , success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? )-> Alamofire.Request?{
        
        
     
        
        let params = [ "accessToken": accessToken]
        
        
        if let domain = domain {
            let urlStr = domain + "/wallet/api/v1/external-payment/vzero/token"
            
            return  request(urlStr, method: .GET, parameters: params , success: { JSON in
                if let newToken = JSON["token"] as? String{
                    success(newToken)
                }else{
                    if let fail = fail{
                        fail(self.badJSONError())
                    }
                }
                
                }, fail: fail)
        }else{
            if let fail = fail{
                fail(self.notConfiguredError())
            }
        }
        return nil
        
    }
    
    func addPayPal(_ accessToken: String ,nonce: String, success: @escaping ((PaymentMethod?) -> Void) , fail: ((NSError) -> Void)? )-> Alamofire.Request?{
        let params = [ "accessToken": accessToken , "source":"paypal" , "nonce":nonce]
        
        
        if let domain = domain {
            let urlStr = domain + "/wallet/api/v1/wallet/paymentMethod"
            
            return  request(urlStr, method: .POST, parameters: params , success: { JSON in
                let pm =  JSON["pm"] as! NSDictionary
                let method = PaymentMethod(JSON: pm)
                success(method)
                }, fail: fail)
        }else{
            if let fail = fail{
                fail(self.notConfiguredError())
            }
        }
        return nil

    }
}
