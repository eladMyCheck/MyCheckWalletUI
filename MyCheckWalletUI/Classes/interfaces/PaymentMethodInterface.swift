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


public protocol PaymentMethodInterface: Chargeable ,CustomStringConvertible  {
   
    var  isSingleUse : Bool{ get}
    
    ///Is the payment method the default payment method or not
    var  isDefault : Bool{ get  set}
    
    ///The type of the payment method
    var  type : PaymentMethodType{ get }

    //used to display extra data abou the method , for example the email or the last 4 digits
    var extaDescription: String{get}
    //used to display extra data abou the method , for example the expiration date
    var extraSecondaryDescription: String{get}
  
  //The ID of the payment method. It is optional because it is created by the server and Apple Pay , for example , doesnt always have it in hand.
  var ID: String{get}
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    init?(JSON: NSDictionary)
  
  //gets the background image for the payment method. For MyCheck use only.
  func getBackgroundImage() -> UIImage
  //loads the correct image icon for the checkout page.
  func setupMethodImage(for imageview: UIImageView)

}
extension PaymentMethodInterface{
  public static func ==(lhs: Self, rhs: Self) -> Bool{
  return lhs.ID == rhs.ID &&
    lhs.type == rhs.type &&
    lhs.isSingleUse == rhs.isSingleUse &&
    lhs.isDefault == rhs.isDefault &&
    lhs.extaDescription == rhs.extaDescription &&
    lhs.extraSecondaryDescription == rhs.extraSecondaryDescription
  }
}

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
