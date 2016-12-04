//
//  MCTextField.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/10/16.
//
//

import UIKit

class MCTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

}
