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
  public  let  expireMonth : String
    
    /// The year the credit card expires
   public let expireYear : String
    
    /// The credit card's  last 4 digits
   public let lastFourDigits : String
    
    /// True if the payment method is the default payment method
   public let isDefault : Bool
    
    /// True if the payment method will be valid for a single use only
   public let isSingleUse: Bool
    
    ///A short form string of the issuer name
   public let issuerShort: String

    ///The issuer name
   public let issuer: String
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    internal init?(JSON: NSDictionary){
        do {
            var number = JSON["id"] as! NSNumber
            Id = number.stringValue
            
            token = JSON["token"] as! String
            
            if let str = JSON["exp_month"] as? String{
                expireMonth = str 
            }else if let str =  JSON["exp_month"] as? NSNumber{
                expireMonth = String(str)
            }else{
                expireMonth = ""
            }
            
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
