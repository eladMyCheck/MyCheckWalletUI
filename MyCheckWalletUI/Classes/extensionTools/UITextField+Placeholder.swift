//
//  UITextField+Placeholder.swift
//  Pods
//
//  Created by elad schiller on 11/2/16.
//
//

import Foundation

extension UITextField {
    func placeholderColor(_ color: UIColor){
        
        if let placeholder = placeholder {
              self.attributedPlaceholder = NSMutableAttributedString(string:placeholder,
                                                                     attributes:[NSAttributedString.Key.foregroundColor: color])
        }
    }

}
