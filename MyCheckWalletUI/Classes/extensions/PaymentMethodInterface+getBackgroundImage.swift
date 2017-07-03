//
//  File.swift
//  Pods
//
//  Created by elad schiller on 7/3/17.
//
//

import Foundation
import MyCheckCore
//a default implementation fot the function
extension PaymentMethodInterface{
    func getBackgroundImage() -> UIImage {
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        switch self.type {
        case .applePay:
            return UIImage(named: "apple_pay_background", in: bundle, compatibleWith: nil)!
        case .payPal:
            return UIImage(named: "paypal_background", in: bundle, compatibleWith: nil)!
            //      case .masterPass:
            //        return UIImage(named: "diners_background", in: bundle, compatibleWith: nil)!
            //      case .visaCheckout:
        //        return UIImage(named: "discover_background", in: bundle, compatibleWith: nil)!
        default:
            return UIImage(named: "notype_background" , in: bundle, compatibleWith: nil)!
        }
    }
}
