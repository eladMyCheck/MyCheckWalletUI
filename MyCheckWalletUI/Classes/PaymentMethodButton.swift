//
//  PaymentMethodButton.swift
//  Pods
//
//  Created by elad schiller on 11/13/16.
//
//

import UIKit
import MyCheckCore

internal struct PaymentMethodButtonRapper {
     var type: PaymentMethodType
    let button: UIButton
    
    init(button: UIButton = UIButton(type: .custom), forType type: PaymentMethodType) {
        self.button = button
        self.type = type
    }
}
