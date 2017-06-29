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
  
  func addApplePay(applePayToken: String, success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ){
    
    
    
    let params: [String: Any] = [ "source": "applepay" , "token": applePayToken]
    
    if let domain = Networking.shared.domain {
      let urlStr = domain + URIs.addApplePay
      
      self.request(urlStr, method: .post, parameters: params , success: { JSON in
        if let newToken = JSON["token"] as? String{
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
}
