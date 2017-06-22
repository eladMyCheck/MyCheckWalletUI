//
//  ApplePayView.swift
//  Pods
//
//  Created by elad schiller on 11/15/16.
//
//

import UIKit

class ApplePayView: CreditCardView {
    var emailLabel : UILabel? {
        get{
        return creditCardNumberlabel
        }}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
   override init(frame: CGRect, method: PaymentMethod){
   super.init(frame: frame, method: method)
    self.expirationDateLabel?.removeFromSuperview()
    emailLabel?.textColor = LocalData.manager.getColor("managePaymentMethodsColorsApplePayCardText", fallback: (emailLabel?.textColor)!)
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    let image = UIImage(named: "ApplePay_background" , in: bundle, compatibleWith: nil)
    backgroundButton!.setImage(image, for: UIControlState())
    if let numberToTrailing = self.numberToTrailing{
       numberToTrailing.priority = 999
       
      

    }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //moving the label into position
        if let creditCardNumberlabel = self.creditCardNumberlabel{
            creditCardNumberlabel.textAlignment = NSTextAlignment.center;
            
            //moving the label into position
            var frame = creditCardNumberlabel.frame
            frame.size.width = backgroundButton!.frame.size.width - 20.0
            frame.origin.y = 68
            creditCardNumberlabel.frame = frame
            
        }
    }
}
