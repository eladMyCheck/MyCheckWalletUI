//
//  StringData.swift
//  Pods
//
//  Created by elad schiller on 10/18/16.
//
//

import Foundation


internal class StringData{

    static let manager = StringData()
    
    var strings : [String : String ] = [:]
    
    
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
}
