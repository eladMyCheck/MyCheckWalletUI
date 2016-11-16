//
//  PaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation


///The diffrant 3rd party wallets that can be supported by MyCheck Wallet.
public enum PaymentMethodType {
    /// Visa Checkout.
    case VisaCheckout
    /// Support PayPal using the Brain Tree SDK.
    case PayPal
    /// Master Pass.
    case MasterPass
    case CreditCard
    case Non
}

///A Credit Card issuer type.
public enum CreditCardType : String{
    ///Visa
    case visa = "visa"
    ///Master Card
    case masterCard = "mastercard"
    ///American express
    case amex = "amex"
    ///Discover
    case discover = "discover"
    ///JBC
    case JCB = "jcb"
    ///Diners Club
    case diners = "dinersclub"
    ///Maestro
    case maestro = "maestro"
    ///Invalid type or simply unrecognised by any of our regular expressions
    case unknown = ""
}


///Represents a payment method the user has.
public class PaymentMethod{
    
    /// The Id of the payment method.
    public let Id : String
    /// The token that must be used in order to chard the payment method.
   public let token : String
    
    /// The month the credit card expires
  public  var  expireMonth : String? = nil
    
    /// The year the credit card expires
   public var expireYear : String? = nil
    
    /// The credit card's  last 4 digits
   public var lastFourDigits : String? = nil
    
    /// True if the payment method is the default payment method
   public let isDefault : Bool
    
    /// True if the payment method will be valid for a single use only
   public let isSingleUse: Bool
    
    ///A short form string of the issuer name
   public let issuerShort: String

    ///The issuer name
   public let issuer: String
    
    ///The issuer name
     public let type: PaymentMethodType
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    internal init?(JSON: NSDictionary){
        do {
            guard let source = JSON["source"] as? String else{
                return nil
            }
            
            var number = JSON["id"] as! NSNumber
            Id = number.stringValue
            
            token = JSON["token"] as! String
            
            if let str = JSON["exp_month"] as? String{
                expireMonth = str 
            }else if let str =  JSON["exp_month"] as? NSNumber{
                expireMonth = String(str)
            }
            
            if number == JSON["exp_year4"] as? NSNumber{
            let yearInt = Int(number)
                 expireYear = String(yearInt)
            }
            if let str =  JSON["last_4_digits"] as? String {
            lastFourDigits =  str
            }
            number  = JSON["is_default"] as! NSNumber
            isDefault = number.boolValue
            number  = JSON["is_single_use"] as! NSNumber
            isSingleUse = number.boolValue
            
            issuerShort = JSON["issuer_short"] as! String
            issuer = JSON["issuer_full"] as! String

            switch (source){
            case "paypal":
                type = .PayPal
            default:
                type = .CreditCard
            }
            
            
        } catch {
            return nil
        }
        
    }
    
    
}
