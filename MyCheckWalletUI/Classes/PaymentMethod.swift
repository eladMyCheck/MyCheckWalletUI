//
//  PaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation


///A Credit Card issuer type.
public enum CreditCardType : String{
    case visa = "visa"
    case masterCard = "mastercard"
    case amex = "amex"
    case discover = "discover"
    case JCB = "jcb"
    case diners = "dinersclub"
    case maestro = "maestro"
    case unknown = ""
}
///Represents a payment method the user has.
public class PaymentMethod{
    
    /// The Id of the payment method.
    public let Id : String
    /// The token that must be used in order to chard the payment method.
    let token : String
    
    /// The month the 💳 expires
    let  expireMonth : String
    
    /// The year the 💳 expires
    let expireYear : String
    
    /// The 💳 last 4 digits
    let lastFourDigits : String
    
    /// True if the payment method is the default payment method
    let isDefault : Bool
    
    /// True if the payment method will be valid for a single use only
    let isSingleUse: Bool
    
    ///A short form string of the issuer name
    let issuerShort: String

    ///The issuer name
    let issuer: String
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    internal init?(JSON: NSDictionary){
        do {
            var number = JSON["id"] as! NSNumber
            Id = number.stringValue
            
            token = JSON["token"] as! String
          
            expireMonth = JSON["exp_month"] as! String
           
            number = JSON["exp_year4"] as! NSNumber
            let yearInt = Int(number)
            expireYear = String(yearInt)
          
            lastFourDigits =  JSON["last_4_digits"] as! String
            number  = JSON["is_default"] as! NSNumber
            isDefault = number.boolValue
            number  = JSON["is_single_use"] as! NSNumber
            isSingleUse = number.boolValue
            
            issuerShort = JSON["issuer_short"] as! String
            issuer = JSON["issuer_full"] as! String

        } catch {
            return nil
        }
        
    }
    
    
}
