//
//  Networking+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//
import MyCheckCore

import UIKit

struct MasterPassInitPayload{
    let token: String
    let merchantCheckoutID: String
}
extension URIs{
    static let getMasterPassCredentials = "/wallet/api/v1/external-payment/masterpass/token"
    static let addMasterPass = "/wallet/api/v1/wallet/paymentMethod"
}
extension Wallet {
    
    
    func getMasterPassCredentials( masterPassURL: String , success: @escaping ((_ payload: MasterPassInitPayload) -> Void) , fail: ((NSError) -> Void)? ){
     
        
        let params = [  "originURL": masterPassURL]
        
        
        guard  let domain = Networking.shared.domain else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        return
        }
            let urlStr = domain + URIs.getMasterPassCredentials
            
            self.request(urlStr, method: .get, parameters: params , success: { JSON in
                if let newToken = JSON["token"] as? String , let merchantId = JSON["merchantCheckoutID"] as? String{
                    success(MasterPassInitPayload(token: newToken, merchantCheckoutID: merchantId))
                }else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                }
                
                }, fail: fail)
       
        
        
    }
    
    func addMasterPass(payload: String, singleUse: Bool ,success: @escaping ((PaymentMethodInterface?) -> Void) , fail: ((NSError) -> Void)? ){
        let params = [  "source":"masterpass" , "masterpass_payload":payload , "is_single_use":  String(describing: NSNumber(value: singleUse))]
        
        
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.addMasterPass
            
            self.request(urlStr, method: .post, parameters: params , success: { JSON in
                let pm =  JSON["pm"] as! NSDictionary
                let method = CreditCardPaymentMethod(JSON: pm)
                success(method)
                }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }

    }
}
