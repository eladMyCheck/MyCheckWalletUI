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
    guard let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) else {
      return nil
    }
    
    return String(data: data, encoding: String.Encoding.utf8)!
  }
  
  func toBase64() -> String? {
    guard let data = self.data(using: String.Encoding.utf8) else {
      return nil
    }
    
    return data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
  }
}
