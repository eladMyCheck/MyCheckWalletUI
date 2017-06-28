//
//  PaymentMethodInterface.swift
//  Pods
//
//  Created by elad schiller on 6/28/17.
//
//

import Foundation
import MyCheckCore


///The diffrant 3rd party wallets that can be supported by MyCheck Wallet.
public enum PaymentMethodType : String{
    /// Visa Checkout.
    case visaCheckout = "Visa Checkout"
    /// Support PayPal using the Brain Tree SDK.
    case payPal = "PayPal"
    /// Master Pass.
    case masterPass = "MasterPass"
    //Credit Card
    case creditCard = "Credit Card"
    //ApplePay
    case applePay = "ApplePay"
    
    case non = "Non"
    
    init(source: String) {
        switch source {
        case "BRAINTREE":
            self = .payPal
        case "MASTERPASS":
           self = .masterPass
        case "APPLE_PAY":
            self = .applePay
            
        case "PAYPAL":
            self = .payPal
        default:
            self = .creditCard
        }
    }
}


public protocol PaymentMethodInterface: PaymentIdProtocol ,CustomStringConvertible{
   
    var  isSingleUse : Bool{ get}
    
    ///Is the payment method the default payment method or not
    var  isDefault : Bool{ get  set}
    
    ///The type of the payment method
    var  type : PaymentMethodType{ get }

    //used to display extra data abou the method , for example the email or the last 4 digits
    var extaDescription: String{get}
    //used to display extra data abou the method , for example the expiration date
    var extraSecondaryDescription: String{get}
    
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    init?(JSON: NSDictionary)
    //sets up the image in the button reprisenting the payment method
    func setupMethodBackgroundImage(for button: UIButton)
    //sets up the image reprisenting the payment method
    func setupMethodImage(for button: UIImageView, fallback: UIImage)
}
