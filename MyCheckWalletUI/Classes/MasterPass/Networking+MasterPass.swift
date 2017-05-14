//
//  Networking+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//
import Alamofire

import UIKit

extension Networking {
    
    
    func getMasterPassCredentials(_ accessToken: String , masterPassURL: String , success: @escaping ((_ token: String ,_ merchantId: String) -> Void) , fail: ((NSError) -> Void)? )-> Alamofire.Request?{
        
        
     
        
        let params = [ "accessToken": accessToken , "originURL": masterPassURL]
        
        
        if let domain = domain {
            let urlStr = domain + "/wallet/api/v1/external-payment/masterpass/token"
            
            return  request(urlStr, method: .get, parameters: params , success: { JSON in
                if let newToken = JSON["token"] as? String , let merchantId = JSON["merchantCheckoutID"] as? String{
                    success(newToken , merchantId)
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
    
    func addMasterPass(_ accessToken: String ,payload: String, singleUse: Bool ,success: @escaping ((PaymentMethod?) -> Void) , fail: ((NSError) -> Void)? )-> Alamofire.Request?{
        let params = [ "accessToken": accessToken , "source":"masterpass" , "masterpass_payload":payload , "is_single_use":  String(describing: NSNumber(value: singleUse))]
        
        
        if let domain = domain {
            let urlStr = domain + "/wallet/api/v1/wallet/paymentMethod"
            
            return  request(urlStr, method: .post, parameters: params , success: { JSON in
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
