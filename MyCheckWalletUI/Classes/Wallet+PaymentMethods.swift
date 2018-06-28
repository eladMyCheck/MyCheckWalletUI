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
        
        let showGiftcard : Bool = LocalData.manager.getBool("managePaymentMethodsshowGiftcard")
        
        let params: [String: Any] = [ "with_giftcards" : showGiftcard]
        
        let urlStr = Networking.shared.domain! + URIs.paymentMethods
        
        self.request(urlStr , method: .get, parameters: params , success: { JSON in
            var returnArray : [PaymentMethodInterface] = []
            
            if  let methodsJSON = JSON["PaymentMethods"] as? NSArray{
                
                for dic in methodsJSON as! [NSDictionary]{
                    
                    //checking the type of the card and creating the correct stuct
                    if let source = dic["source"] as? String {
                        let type = PaymentMethodType(source: source)
                        if let factory = Wallet.shared.getFactory(type) , let method = factory.getPaymentMethod(JSON: dic){
                            if method.type == .payPal, let payPalMethod = PayPalPaymentMethod(JSON: dic){
                                returnArray.append(payPalMethod)
                            }else{
                                returnArray.append(method)
                            }
                            continue
                        }
                        
                        if  let method = CreditCardPaymentMethod(JSON: dic), type == .creditCard{
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
    
    func callDeleteMethods(_ method: PaymentMethodInterface , success: @escaping (( [PaymentMethodInterface] ) -> Void) , fail: ((NSError) -> Void)? ) {
        let params = [  "ID": method.ID , "get_list":1] as [String : Any]
        let urlStr = Networking.shared.domain! + URIs.deletePaymentMethod
        
        self.request(urlStr , method: .delete, parameters: params , success: { JSON in
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
                        
                        if  let method = CreditCardPaymentMethod(JSON: dic), type == .creditCard{
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
