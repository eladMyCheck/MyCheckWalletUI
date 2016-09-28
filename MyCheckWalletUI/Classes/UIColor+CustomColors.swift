//
//  UIColor+CustomColors.swift
//  Pods
//
//  Created by elad schiller on 9/27/16.
//
//

import UIKit

internal extension UIColor{
    
    //so we d9ont need to devide by  255 every time
    convenience init( r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let white = CGFloat(255)
        let rr = r / white
        let gg = g / white
        let bb = b / white

        
        self.init(red:rr, green: gg , blue: bb , alpha: a)
    }
    
    static func fieldUnderline() -> UIColor {
    return UIColor(r: 126, g: 166, b: 171, a: 1)
    }
    
   static func fieldUnderlineInvalid() -> UIColor {
        return UIColor(r: 203, g: 22, b: 33, a: 1)
    }
   static func fieldTextInvalid() -> UIColor {
        return UIColor.fieldUnderlineInvalid()
    }
  static  func fieldTextValid() -> UIColor {
        return UIColor(r: 0, g: 0, b: 0, a: 1)
    }
}
