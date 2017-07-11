//
//  ApplePayCreditCardTypes.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation
import PassKit



extension PKPaymentNetwork{
   
    init?(string: String){
        switch string {
        case "Amex":
           self = .amex
        case "CarteBancaire":
            if #available(iOS 10.3, *) {
                self = .carteBancaire
            } else {
                return nil
            }
        case "ChinaUnionPay":
            if #available(iOS 9.2, *) {
                self =  .chinaUnionPay
            } else {
                return nil
            }
        case "Discover":
            self =  .discover
        case "Interac":
            if #available(iOS 9.2, *) {
                self =  .interac
            } else {
                return nil
            }
        case "MasterCard":
            self =  .masterCard
        case "PrivateLabel":
            self =  .privateLabel
        case "Visa":
            self =  .visa
        case "JCB":
            if #available(iOS 10.1, *) {
                self =  .JCB
            } else {
                return nil
            }
        case "Suica":
            if #available(iOS 10.1, *) {
                self =  .suica
            } else {
                return nil
            }
        case "QuicPay":
            if #available(iOS 10.3, *) {
                self =  .quicPay
            } else {
                return nil
            }
        case "IDCredit":
            if #available(iOS 10.3, *) {
                self =  .idCredit
            } else {
                return nil
            }
        default: return nil
        }

    }
}

