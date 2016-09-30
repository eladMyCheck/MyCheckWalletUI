//
//  AddCreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/30/16.
//
//

import UIKit

class AddCreditCardView: UIView , UIGestureRecognizerDelegate{

    var paymentMethod : PaymentMethod?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.blueColor()
    
        var recognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        recognizer.delegate = self;
        self.addGestureRecognizer(recognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonPressed(recognizer : UITapGestureRecognizer) {
        NSNotificationCenter.defaultCenter().postNotificationName("AddCreditCardPressed", object: nil)

    }
}
