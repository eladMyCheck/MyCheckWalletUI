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
    case visaCheckout
    /// Support PayPal using the Brain Tree SDK.
    case payPal
    /// Master Pass.
    case masterPass
    case creditCard
    case non
}

///A Credit Card issuer type.
public enum CreditCardType : String{
    ///Visa
    case Visa = "visa"
    ///Master Card
    case MasterCard = "mastercard"
    ///American express
    case Amex = "amex"
    ///Discover
    case Discover = "discover"
    ///JBC
    case JCB = "jcb"
    ///Diners Club
    case Diners = "dinersclub"
    ///Maestro
    case Maestro = "maestro"
    ///Invalid type or simply unrecognised by any of our regular expressions
    case Unknown = ""
}


///Represents a payment method the user has.
open class PaymentMethod{
    
    /// The Id of the payment method.
    open let Id : String
    /// The token that must be used in order to chard the payment method.
   open var token : String 
  
  // A string with a user readable description of the payment method, e.g. XXXX-1234
  internal  var  name : String? = nil

    var checkoutName: String? {get{
        
        guard let lastFourDigits = self.lastFourDigits else{
        return self.issuerFull
        }
       
        var toReturn = issuerFull.capitalizingFirstLetter() + " " + lastFourDigits
        if isSingleUse{
        
            return toReturn + " " + LocalData.manager.getString("checkoutPagetemporaryCard", fallback: "(temporary card)")
        }
        return toReturn
        }}
    
    /// The month the credit card expires
  open  var  expireMonth : String? = nil
    
    /// The year the credit card expires
   open var expireYear : String? = nil
    
    /// The credit card's  last 4 digits
   open var lastFourDigits : String? = nil
    
    /// True if the payment method is the default payment method
   open let isDefault : Bool
    
    /// True if the payment method will be valid for a single use only
   open let isSingleUse: Bool
    
    ///A short form string of the issuer name
   open let issuerShort: String
    private let issuerFull : String

    ///The issuer name
   open let issuer: CreditCardType
    
    ///The issuer name
     open let type: PaymentMethodType
  
  //the JSON represintation of the object
  internal let JSON : NSDictionary
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    internal init?(JSON: NSDictionary){
        do {
            guard let source = JSON["source"] as? String else{
                return nil
            }
            self.JSON = JSON
            var number = JSON["id"] as! NSNumber
            Id = number.stringValue
            
            token = JSON["token"] as! String
            
            if let str = JSON["exp_month"] as? String{
                expireMonth = str 
            }else if let str =  JSON["exp_month"] as? NSNumber{
                expireMonth = String(describing: str)
            }
            
            if let number = JSON["exp_year4"] as? NSNumber{
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
           let  issuerStr = JSON["issuer_full"] as! String
            issuerFull = issuerStr
            let tmpType = CreditCardType(rawValue: issuerStr)
            if let tmpType = tmpType{
            issuer = tmpType
            }else{
            issuer = .Unknown
            }
          name = JSON["name"] as? String
           
            switch (source){
            case "BRAINTREE":
                type = .payPal
            default:
                type = .creditCard
            }
            
            
        } catch {
            return nil
        }
        
    }
  
  internal convenience init?(other:PaymentMethod){
      self.init(JSON: other.JSON)
      }
    
}
