//
//  ApplePayCredentials.swift
//  Pods
//
//  Created by elad schiller on 7/2/17.
//
//

import Foundation
import PassKit

internal struct ApplePayCredentials {
    let countryCode: String
    let currencyCode: String
    let merchantIdentifier: String
    let applePayCreditCardTypes: [PKPaymentNetwork]
    
    
    init(merchantIdentifier: String , currencyCode:String , countryCode: String ,ApplePayCreditCardTypes: [PKPaymentNetwork]) {
        self.countryCode = countryCode
        self.currencyCode = currencyCode
        self.merchantIdentifier = merchantIdentifier
        self.applePayCreditCardTypes = ApplePayCreditCardTypes
    }
}
