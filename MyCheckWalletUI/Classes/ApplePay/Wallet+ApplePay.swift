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
    
  func addApplePay(applePayToken: String, cardType: String ,isPending: Bool, success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ){
        
        
        
        let params: [String: Any] = [ "source": "applepay" , "token": applePayToken, "card_type": cardType , "is_caped": !isPending]
        
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
    
    func hasPendingApplePayToken(success: @escaping ((Bool , String?) -> Void) , fail: ((NSError) -> Void)? ){
        
        let showGiftcard : Bool = LocalData.manager.getBool("managePaymentMethodsshowGiftcard")
        
        let params: [String: Any] = [ "with_giftcards" : showGiftcard ]
        
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
                if let source = dic["source"] as? String  , let isCapped = dic["is_capped"] as? NSNumber, let token = dic["token"] as? String, PaymentMethodType(source: source) == .applePay && isCapped == false{
                    success(true , token)
                    return
                }
            }
            success(false , nil)
        }, fail: fail)
    }
}
