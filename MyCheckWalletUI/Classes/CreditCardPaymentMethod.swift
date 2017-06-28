//
//  PaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation

import MyCheckCore

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
    
    internal func smallImageURL() -> URL?{
        // let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        switch self {
        case .MasterCard:
            return URL(string:  LocalData.manager.getString("addCreditImagesmastercard"))!
        case .Visa:
            return URL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        case .Diners:
            return URL(string:  LocalData.manager.getString("addCreditImagesdinersclub"))!
        case .Discover:
            return URL(string:  LocalData.manager.getString("addCreditImagesdiscover"))!
        case .Amex:
            return URL(string:  LocalData.manager.getString("addCreditImagesamex"))!
        case .JCB:
            return URL(string:  LocalData.manager.getString("addCreditImagesJCB"))!
        case .Maestro:
            return URL(string:  LocalData.manager.getString("addCreditImagesmaestro"))!
            
        default:
            return URL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        }
    }
}


///Represents a payment method the user has.
public struct CreditCardPaymentMethod{
    
    /// The Id of the payment method.
    fileprivate let Id : String
    /// The token that must be used in order to chard the payment method.
    fileprivate var token : String
    
    // A string with a user readable description of the payment method, e.g. XXXX-1234
    fileprivate  var  name : String? = nil
    
    
    /// The month the credit card expires
    fileprivate  var  expireMonth : String? = nil
    
    /// The year the credit card expires
    fileprivate var expireYear : String? = nil
    
    /// The credit card's  last 4 digits
    fileprivate var lastFourDigits : String? = nil
    
    /// True if the payment method is the default payment method
    fileprivate var _isDefault : Bool
    
    /// True if the payment method will be valid for a single use only
    fileprivate let _isSingleUse: Bool
    
    ///A short form string of the issuer name
    fileprivate let issuerShort: String
    fileprivate  let issuerFull : String
    
    ///The issuer name
    fileprivate let issuer: CreditCardType
    
    ///The issuer name
    fileprivate let _type: PaymentMethodType
    
    //the JSON represintation of the object
    fileprivate let JSON : NSDictionary?
    
    
    
    internal  init(for type: PaymentMethodType, name:String?, Id: String, token: String , checkoutName: String?){
        self._type = type
        self.name = name
        self.Id = Id
        self.token = token
        issuer = .Unknown
        issuerFull = ""
        issuerShort = ""
        _isDefault = false
        _isSingleUse = false
        JSON = nil
    }
    
    
    
    //internal init?(other:CreditCardPaymentMethod){
    //  guard let JSON = other.JSON else{
    // self.init(for: other.type, name: other.name, Id: other.Id, token: other.token, checkoutName: other.checkoutName)
    //return
    //}
    //self.init(JSON: JSON)
    //
    // }
}

extension CreditCardPaymentMethod: PaymentMethodInterface{
    ///Init function
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    internal init?(JSON: NSDictionary){
        
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
        if let defNum  = JSON["is_default"] as? NSNumber{
            _isDefault = defNum.boolValue
        }else{
            _isDefault = false;
        }
        number  = JSON["is_single_use"] as! NSNumber
        _isSingleUse = number.boolValue
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
        
        _type = PaymentMethodType.init(source: source)
        
        if type != .CreditCard{
        return nil
        }
        
        
    }
    
    
    public var description: String {get{
        
        guard let lastFourDigits = self.lastFourDigits else{
            return self.issuerFull
        }
        
        let toReturn = issuerFull.capitalizingFirstLetter() + " " + lastFourDigits
        if isSingleUse{
            
            return toReturn + " " + LocalData.manager.getString("checkoutPagetemporaryCard", fallback: "(temp card)")
        }
        return toReturn
        }
    }
    
    var  isSingleUse : Bool{ get{
        return _isSingleUse
        }
    }
    //Used for displaying the number to the user example: 'XXXX - 1234'
    internal var extaDescription: String{get{
        return " \(name ?? "") "
        }}
    //Used for displaying the number to the user example: 'XXXX - 1234'
    internal var extraSecondaryDescription: String?{get{
        guard var year = expireYear, let month = expireMonth else{
            return nil
        }
        if year.characters.count > 2 {
            year = year.substring(from: year.characters.index(year.startIndex, offsetBy: 2))
        }
        return String(format: "%@/%@", month, year)
        
        }
    }
    
    ///Is the payment method the default payment method or not
    var  isDefault : Bool{ get{ return _isDefault}}
    ///The type of the payment method
    var  type : PaymentMethodType{ get{return _type} }
    
    //sets up the image in the button reprisenting the payment method
    func setupMethodImage(for imageview: UIImageView, fallback: UIImage){
        
        if issuer == .Unknown {
            
            imageview.image = fallback
        }else{
            
            imageview.kf.setImage(with:issuer.smallImageURL())}
    }
    
}


