//
//  MyCheckWallet+PayPal.swift
//  Pods
//
//  Created by elad schiller on 11/14/16.
//
//

import UIKit

extension MyCheckWallet {

    func getMasterPassCredentials(masterPassURL: String, success: @escaping ((_ token: String ,_ merchantId: String) -> Void) , fail: ((NSError) -> Void)? ){
        
        if let token = token{
            Networking.manager.getMasterPassCredentials(token, masterPassURL: masterPassURL, success: success, fail: fail)
        }else{
            if let fail = fail{
                fail(MyCheckWallet.notLoggedInError())
            }
    }
    }
    func addMasterPass(_ payload: String, singleUse: Bool,  success: @escaping ((PaymentMethod?) -> Void) , fail: ((NSError) -> Void)? ){
        
        if let token = token{
            Networking.manager.addMasterPass(token, payload: payload, singleUse: singleUse , success: success, fail: fail)
        }else{
            if let fail = fail{
                fail(MyCheckWallet.notLoggedInError())
            }
        }
    }
}
