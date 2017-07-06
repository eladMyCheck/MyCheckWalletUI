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
  
    }
  
  
  
  
  



///Represents a payment method the user has.
public struct CreditCardPaymentMethod{
  
  /// The Id of the payment method.
  fileprivate let _Id : String
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
  internal let issuer: CreditCardType
  
  ///The issuer name
  fileprivate let _type: PaymentMethodType
  
  //the JSON represintation of the object
  fileprivate let JSON : NSDictionary?
  
  
  
  internal  init(for type: PaymentMethodType, name:String?, Id: String, token: String , checkoutName: String?){
    self._type = type
    self.name = name
    _Id = Id
    self.token = token
    issuer = .Unknown
    issuerFull = ""
    issuerShort = ""
    _isDefault = false
    _isSingleUse = false
    JSON = nil
  }
  
  
  
  }

extension CreditCardPaymentMethod: PaymentMethodInterface{
 

 
  

 

 
  

  
  ///Init function
  ///
  ///    - parameter JSON: A JSON that comes from the wallet endpoint
  ///    - returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
  
    public init?(JSON: NSDictionary){
    
    guard let source = JSON["source"] as? String else{
      return nil
    }
    self.JSON = JSON
    var number = JSON["id"] as! NSNumber
    _Id = number.stringValue
    
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
    
    if _type != .creditCard{
      return nil
    }
    
    
  }
  
 
  public func generatePaymentToken(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: @escaping (String) -> Void,  fail: @escaping (NSError) -> Void) {
    success(token)

  }
    ///A readable description of the Credit Card e.g. XXXX - 1234
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
  
  public var  isSingleUse : Bool{ get{
    return _isSingleUse
    }
  }
  //Used for displaying the number to the user example: 'XXXX - 1234'
  public var extaDescription: String{get{
    return " \(name ?? "") "
    }}
  //Used for displaying the number to the user example: 'XXXX - 1234'
  public var extraSecondaryDescription: String{get{
    guard var year = expireYear, let month = expireMonth else{
      return ""
    }
    
    
    if year.characters.count > 2 {
      year = year.substring(from: year.characters.index(year.startIndex, offsetBy: 2))
    }
    return String(format: "%@/%@", month, year)
    
    }
  }
  
  ///Is the payment method the default payment method or not
  public var  isDefault : Bool{ get{ return _isDefault} set(value){
    _isDefault = value
    }}
  ///The type of the payment method
  public var  type : PaymentMethodType{ get{return _type} }
  
  public var ID: String {
    return _Id
  }
  
  
}


extension CreditCardPaymentMethod{
  public func getBackgroundImage() -> UIImage {
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    switch self.issuer {
    case .MasterCard:
      return UIImage(named: "master_card_background", in: bundle, compatibleWith: nil)!
    case .Visa:
      return UIImage(named: "visa_background", in: bundle, compatibleWith: nil)!
    case .Diners:
      return UIImage(named: "diners_background", in: bundle, compatibleWith: nil)!
    case .Discover:
      return UIImage(named: "discover_background", in: bundle, compatibleWith: nil)!
    case .Amex:
      return UIImage(named: "amex_background", in: bundle, compatibleWith: nil)!
    case .JCB:
      return UIImage(named: "jcb_background", in: bundle, compatibleWith: nil)!
    case .Maestro:
      return UIImage(named: "maestro_background", in: bundle, compatibleWith: nil)!
      
    default:
      return UIImage(named: "notype_background" , in: bundle, compatibleWith: nil)!
    }
  }
  public func setupMethodImage(for imageview: UIImageView){
    imageview.kf.setImage(with: self.issuer.imageURLForDropdown())
    
  }
}


extension CreditCardType{
  func imageURLForDropdown( ) -> URL?{
    switch self {
    case .MasterCard:
      return URL(string:  LocalData.manager.getString("cardsDropDownmastercard"))!
    case .Visa:
      return URL(string:  LocalData.manager.getString("cardsDropDownvisa"))!
    case .Diners:
      return URL(string:  LocalData.manager.getString("cardsDropDowndinersclub"))!
    case .Discover:
      return URL(string:  LocalData.manager.getString("cardsDropDowndiscover"))!
    case .Amex:
      return URL(string:  LocalData.manager.getString("cardsDropDownamex"))!
    case .JCB:
      return URL(string:  LocalData.manager.getString("cardsDropDownJCB"))!
    case .Maestro:
      return URL(string:  LocalData.manager.getString("cardsDropDownmaestro"))!
      
    default:
      return nil
    }
  }
  
  
  
}
