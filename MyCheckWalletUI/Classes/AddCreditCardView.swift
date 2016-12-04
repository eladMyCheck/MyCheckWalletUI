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
        
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        backgroundColor = UIColor.init(patternImage: UIImage(named: "addcreditcardbackground", in: bundle, compatibleWith: nil)!)//UIColor.blueColor()
    
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddCreditCardView.buttonPressed(_:)))
        recognizer.delegate = self;
        self.addGestureRecognizer(recognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonPressed(_ recognizer : UITapGestureRecognizer) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AddCreditCardPressed"), object: nil)

    }
}
