//
//  ApplePayCreditCardTypes.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation
import PassKit
internal enum ApplePayCreditCardTypes: String {
    case amex = "Amex"
    case carteBancaire = "CarteBancaire"
    case chinaUnionPay = "ChinaUnionPay"
    case discover = "Discover"
    case interac = "Interac"
    case masterCard = "MasterCard"
    case privateLabel = "PrivateLabel"
    case visa = "Visa"
    case jCB = "JCB"
    case suica = "Suica"
    case quicPay = "QuicPay"
    case iDCredit = "IDCredit"
    
    //TO-DO improve this (no one is actauly using the enum...
    //Converts ApplePayCreditCardTypes to PKPaymentNetwork if the ios version supports iot and nil otherwise
    private func convert( ) -> PKPaymentNetwork?{
        switch self {
        case .amex:
            return .amex
        case .carteBancaire:
            if #available(iOS 10.3, *) {
                return .carteBancaire
            } else {
                return nil
            }
        case .chinaUnionPay:
            if #available(iOS 9.2, *) {
                return .chinaUnionPay
            } else {
                return nil
            }
        case .discover:
            return .discover
        case .interac:
            if #available(iOS 9.2, *) {
                return .interac
            } else {
                return nil
            }
        case .masterCard:
            return .masterCard
        case .privateLabel:
            return .privateLabel
        case .visa:
            return .visa
        case .jCB:
            if #available(iOS 10.1, *) {
                return .JCB
            } else {
                return nil
            }
        case .suica:
            if #available(iOS 10.1, *) {
                return .suica
            } else {
                return nil
            }
        case .quicPay:
            if #available(iOS 10.3, *) {
                return .quicPay
            } else {
                return nil
            }
        case .iDCredit:
            if #available(iOS 10.3, *) {
                return .idCredit
            } else {
                return nil
            }
      
        }
    }
    
   internal static func stringsToPKPaymentNetworks(strings: [String]) -> [PKPaymentNetwork] {
        let networskArray = strings.map{
            ApplePayCreditCardTypes(rawValue: $0)
            }
            .flatMap{ $0 }
            .map{
                $0.convert()
            }
            .flatMap{$0}

        return networskArray
    }
    
}
