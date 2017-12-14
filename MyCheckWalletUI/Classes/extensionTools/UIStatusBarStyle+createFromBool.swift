//
//  UIStatusBarStyle+createFromBool.swift
//  Pods
//
//  Created by elad schiller on 12/14/17.
//

import Foundation


internal extension UIStatusBarStyle{
    
    static func styleFromBool(light: Bool) -> UIStatusBarStyle{
        let style : UIStatusBarStyle = (light == true)  ? .lightContent : .default
        return style
    }
}
