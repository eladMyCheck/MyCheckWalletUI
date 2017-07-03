//
//  PaymentMethodType+imageURLForFropDown.swift
//  Pods
//
//  Created by elad schiller on 7/3/17.
//
//

import Foundation
import MyCheckCore


extension PaymentMethodType{
    func imageURLForDropdown( ) -> URL?{
        switch self {
        case .applePay:
            return URL(string:  LocalData.manager.getString("cardsDropDownapplePay"))!
        case .payPal:
            return URL(string:  LocalData.manager.getString("cardsDropDownpaypal"))!
            //    case .masterPass:
            //      return URL(string:  LocalData.manager.getString("cardsDropDowndinersclub"))!
            //    case .visaCheckout:
        //      return URL(string:  LocalData.manager.getString("cardsDropDowndiscover"))!
        default:
            return nil
        }
    }
}
