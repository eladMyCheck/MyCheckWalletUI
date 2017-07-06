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
    
    func callPaymentMethods( success: @escaping (( [PaymentMethodInterface] ) -> Void) , fail: ((NSError) -> Void)? ) {
        let params: [String: Any] = [ : ]
        
        let urlStr = Networking.shared.domain! + URIs.paymentMethods
        
        self.request(urlStr , method: .get, parameters: params , success: { JSON in
            var returnArray : [PaymentMethodInterface] = []
            
            if  let methodsJSON = JSON["PaymentMethods"] as? NSArray{
                
                for dic in methodsJSON as! [NSDictionary]{
                    
                    //checking the type of the card and creating the correct stuct
                    if let source = dic["source"] as? String {
                        let type = PaymentMethodType(source: source)
                        if let factory = Wallet.shared.getFactory(type) , let method = factory.getPaymentMethod(JSON: dic){
                            returnArray.append(method)
                            continue
                        }
                        
                        if  let method = CreditCardPaymentMethod(JSON: dic){
                            returnArray.append(method)
                            continue
                        }
                    }
                }
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
