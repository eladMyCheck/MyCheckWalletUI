//
//  MyCheckWallet+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//

import UIKit

extension MyCheckWallet {

    func getBraintreeToken(_ success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ){
        if let token = braintreeToken {
            success(token)
            return
        }
        
        
        if let token = token{
            Networking.manager.getBraintreeToken(token, success: { token in
                self.braintreeToken = token

                success(token)
                }, fail: fail)
        }else{
            if let fail = fail{
                fail(MyCheckWallet.notLoggedInError())
            }
        }
    }
    func addPayPal(_ nonce: String, success: @escaping ((PaymentMethod?) -> Void) , fail: ((NSError) -> Void)? ){
        
        if let token = token{
            Networking.manager.addPayPal(token, nonce: nonce, success: success, fail: fail)
        }else{
            if let fail = fail{
                fail(MyCheckWallet.notLoggedInError())
            }
        }
    }
}
