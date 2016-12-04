//
//  LocalData.swift
//  Pods
//
//  Created by elad schiller on 10/18/16.
//
//

import Foundation


internal class LocalData{

    static let manager = LocalData()
    
   lazy var strings : [String : String ] = {
    return [:] 
        }()
    
    
    
    //adds all the strings to strings parameter where the key is the same key with a prefix of all its parent's keys
    func addStrings(_ prefix: String? , dictionary: NSDictionary){
        let prefixFinal = prefix == nil ? "" : prefix!
        
        for (key , value) in dictionary{
            if let str = value as? String{
            strings["\(prefixFinal)\(key)"] = str
            }else if let dic = value as? NSDictionary{
            self.addStrings( "\(prefixFinal)\(key)" , dictionary: dic)
            }
        }
    
    }
    func getString(key: String , fallback: String? = nil) -> String{
        if let string = strings[key]  {
        return string
        }
        if let fallback = fallback{
        return fallback
        }
        return ""
    }
    
    func getColor(key: String , fallback: UIColor) -> UIColor{
   let hex = getString(key)
        if hex.characters.count > 2 {
    let color = UIColor.hex(hex)
            return color
        }
        return fallback
   
    }
}
