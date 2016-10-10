//
//  MCTextField.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/10/16.
//
//

import UIKit

class MCTextField: UITextField {

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }

}
