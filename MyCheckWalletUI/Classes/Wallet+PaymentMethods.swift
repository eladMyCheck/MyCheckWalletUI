//
//  Wallet+PaymentMethods.swift
//  Pods
//
//  Created by elad schiller on 6/19/17.
//
//

import Foundation
import MyCheckCore

extension Wallet{

    func callPaymentMethods( success: @escaping (( [PaymentMethod] ) -> Void) , fail: ((NSError) -> Void)? ) {
        let params: [String: Any] = [ : ]
        
        let urlStr = Networking.shared.domain! + URIs.paymentMethods
        
        self.request(urlStr , method: .get, parameters: params , success: { JSON in
            var returnArray : [PaymentMethod] = []
            
            if  let methodsJSON = JSON["PaymentMethods"] as? NSArray{
                
                for dic in methodsJSON as! [NSDictionary]{
                    if let method = PaymentMethod(JSON: dic){
                        if let factory = Wallet.shared.getFactory(method.type){
                            
                        }
                        returnArray.append(method)
                    }
                }
                returnArray.sort(by: {$0.isSingleUse && !$1.isSingleUse}) //sorts temporary cards to be first in the list
                success(returnArray)
            }else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
            }
            
            // success()
            
        }, fail: fail)
    }

}
