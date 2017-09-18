//
//  LocalData.swift
//  Pods
//
//  Created by elad schiller on 10/18/16.
//
//

import Foundation

public protocol KeyValueStorageProtocol{
    
    func getString(_ key: String , fallback: String?) -> String
    
    func getColor(_ key: String , fallback: UIColor) -> UIColor
    
    func getDouble(_ key: String , fallback: Double) -> Double
    
    func getArray(_ key: String ) -> Array<String>
    
}

public extension KeyValueStorageProtocol{
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
}

