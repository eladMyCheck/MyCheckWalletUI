//
//  LocalData.swift
//  Pods
//
//  Created by elad schiller on 10/18/16.
//
//

import Foundation

public protocol KeyValueStorageProtocolOutput{
    
    func getString(_ key: String , fallback: String?) -> String
    
    func getColor(_ key: String , fallback: UIColor) -> UIColor
    
    func getDouble(_ key: String , fallback: Double) -> Double
    
    func getBool(_ key: String , fallback: Bool) -> Bool

    func getArray(_ key: String ) -> Array<String>
    
}


public protocol KeyValueStorageProtocolInput{
    func addStrings(_ prefix: String? , dictionary: NSDictionary)
   
    
}

public protocol KeyValueStorageProtocol: KeyValueStorageProtocolInput, KeyValueStorageProtocolOutput{
    
}

public extension KeyValueStorageProtocolOutput{
    func getString(_ key: String , fallback: String? = nil) -> String{
        return getString(key, fallback: fallback)
    }
    
  

}
public class LocalData : KeyValueStorageProtocol{

   public static let manager = LocalData()
    
   lazy var strings : [String : String ] = {
    return [:] 
        }()
    
    lazy var arrays : [String : [String]] = {
        return [:]
    }()
    
    
    
    //adds all the strings to strings parameter where the key is the same key with a prefix of all its parent's keys
  public  func addStrings(_ prefix: String? , dictionary: NSDictionary){
        let prefixFinal = prefix == nil ? "" : prefix!
        for (key , value) in dictionary{
            
            let keyFinal = "\(prefixFinal)\(key)"
            
            if let str = value as? String{
            strings[keyFinal] = str
            }else if let dic = value as? NSDictionary{
            self.addStrings( keyFinal , dictionary: dic)
            }else if let num = value as? NSNumber{
                strings[keyFinal] = String(describing: num)
            }else if value is Array<String>{
                arrays[keyFinal] = value as? Array<String>
                if keyFinal == "acceptedCardsCheckout"{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "acceptedCardsCheckoutSet"), object: nil)
                }
            }
        }
        
    }
    public func getString(_ key: String , fallback: String? = nil) -> String{
        if let string = strings[key]  {
        return string
        }
        if let fallback = fallback{
        return fallback
        }
        return ""
    }
    
    public func getColor(_ key: String , fallback: UIColor) -> UIColor{
   let hex = getString(key)
        if hex.characters.count > 2 {
    let color = UIColor.hex(hex)
            return color
        }
       return fallback

        
    }
    
    public func getDouble(_ key: String , fallback: Double) -> Double{
        let str = getString(key)
        if str.characters.count > 0 {
          return Double(str)!
        }
        return fallback
        
    }
    
    public func getArray(_ key: String ) -> Array<String> {
        if let arr = arrays[key] {
            return arr
        }else{
            return []
        }
    }
    
    public func getBool(_ key: String , fallback: Bool = false) -> Bool{
        let str = getString(key)
        let lowercase = str.lowercased()
        if lowercase == "true" || lowercase == "1"{
        return true
        }else if lowercase == "false" || lowercase == "0"{
        return false
        }
        if str.characters.count > 0 {
            return Bool(str)!
        }
        return fallback
    }
    
}

//specific value calls
internal extension LocalData{

     func getPaymentMethodRemoveButtonImageURL() -> URL?{
        return URL(string:getString("managePaymentMethodsimagesremoveButton"))
    }
    
     func getPaymentMethodDefaultMethodButtonImageURL() -> URL?{
        return URL(string:getString("managePaymentMethodsimagesdefaultButton"))
    }
    
     func doNotStoreEnabled() -> Bool{
        return getBool("settingsdoNotStoreEnabled", fallback: true)
    }
    
    func paymentMethodSelectorTextFieldColor() -> UIColor{
    return getColor("checkoutPagecolorscardNameDropDown", fallback: UIColor.white)
    }
    
    func addCreditCardUnderlineColor() -> UIColor{
    return getColor("addCreditColorsundeline", fallback: UIColor.darkText)
    }
    func addCreditCardInCheckoutVCHint() -> UIColor{
    return getColor("checkoutPagecolorshintTextColor", fallback: UIColor.lightText)
    }
    
    func getCheckoutPageDropdownImageURL() -> URL?{
        return URL(string:getString("checkoutPageimagesdropDownArrow"))
    }
    
    func getBackButtonImageURL() -> URL?{
        return URL(string:getString("managePaymentMethodsimagesheaderBackButton"))
    }
}

