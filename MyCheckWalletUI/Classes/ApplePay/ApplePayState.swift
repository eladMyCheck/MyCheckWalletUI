//
//  ApplePayState.swift
//  Pods
//
//  Created by elad schiller on 7/2/17.
//
//

import Foundation
import PassKit
import MyCheckCore

struct ApplePayState: ApplePayController{
    let credentials: ApplePayCredentials
    
    init(credentials: ApplePayCredentials) {
        self.credentials = credentials
    }
    func isApplePayDefault() -> Bool {
        if canPayWithApplePay(){
            return LocalData.wasApplePayDefault()
        }
        
        return false
    }
    
    func changeApplePayDefault(to newDefault: Bool) {
        if canPayWithApplePay(){
            LocalData.changeApplePayDefault(to: newDefault)
        }
    }
    func getApplePayPaymentMethod() -> PaymentMethodInterface?{
        if canPayWithApplePay(){
            return    ApplePayPaymentMethod(credentials: self.credentials , methodIsDefault: isApplePayDefault())
            
        }
        
        return nil
        
    }
    
    func canPayWithApplePay() -> Bool{
        return applePayConfigured() && PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: credentials.applePayCreditCardTypes)
    }
    
    func applePayConfigured() -> Bool{
        return ApplePayFactory.initiated
    }
    
    
    
    
}

