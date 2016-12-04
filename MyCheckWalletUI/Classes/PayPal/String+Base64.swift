//
//  String+Base64.swift
//  Pods
//
//  Created by elad schiller on 04/12/2016.
//
//
import UIKit

extension String {
  
  func fromBase64() -> String? {
    guard let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0)) else {
      return nil
    }
    
    return String(data: data, encoding: NSUTF8StringEncoding)!
  }
  
  func toBase64() -> String? {
    guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else {
      return nil
    }
    
    return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
  }
}
