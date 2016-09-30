//
//  CreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

class CreditCardView: UIView, UIGestureRecognizerDelegate {

    var paymentMethod : PaymentMethod?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

    init(frame: CGRect, method: PaymentMethod){
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.paymentMethod = method
        backgroundColor = UIColor.orangeColor()
        
        //credit card number label
        var creditCardNumberlabel = UILabel(frame: CGRectMake(8, 70, 80, 18))
        creditCardNumberlabel.textAlignment = NSTextAlignment.Center
        creditCardNumberlabel.backgroundColor = UIColor.blackColor()
        creditCardNumberlabel.textColor = UIColor.whiteColor()
        creditCardNumberlabel.font =  UIFont(name: creditCardNumberlabel.font.fontName, size: 9)
        creditCardNumberlabel.text = String(format: "XXXX-%@", method.lastFourDigits)
        addSubview(creditCardNumberlabel)
        
        //expiration date label
        var expirationDateLabel = UILabel(frame: CGRectMake(120, 70, 30, 18))
        expirationDateLabel.textAlignment = NSTextAlignment.Center
        expirationDateLabel.backgroundColor = UIColor.blackColor()
        expirationDateLabel.textColor = UIColor.whiteColor()
        expirationDateLabel.font =  UIFont(name: expirationDateLabel.font.fontName, size: 9)
        expirationDateLabel.text = String(format: "%d/%d", method.expireMonth, method.expireYear%100)
        addSubview(expirationDateLabel)
        
        //credic card issue image
        var creditCardIssuerImage = UIImageView(frame: CGRectMake(8, 8, 73, 44))
        creditCardIssuerImage.image = self.setImageForType(self.getType(method.issuer))
        addSubview(creditCardIssuerImage)
        
        //default card checkbox
        if ((self.paymentMethod!.isDefault) == true) {
            let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
            var defaultCardCheckbox = UIImageView(frame: CGRectMake(165, 0, 20, 20))
            defaultCardCheckbox.image = UIImage(named: "v", inBundle: bundle, compatibleWithTraitCollection: nil)!
            addSubview(defaultCardCheckbox)
        }

        var recognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        recognizer.delegate = self;
        self.addGestureRecognizer(recognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.paymentMethod = nil
    }
    
    private func getType(type : String) -> CreditCardType {
        switch type {
        case "Visa":
            return CreditCardType.visa
            //        case .MasterCard:
            //            return CreditCardType.masterCard
            //        case .Discover:
            //            return CreditCardType.discover
            //        case .Amex:
            //            return CreditCardType.amex
            //        case .JCB:
            //            return CreditCardType.JCB
            //        case .Diners:
            //            return CreditCardType.diners
            //        case .Maestro:
            //            return CreditCardType.maestro
            
        default:
            return CreditCardType.unknown
        }
    }
    
    private func setImageForType( type: CreditCardType) -> UIImage{
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .masterCard:
            return UIImage(named: "master_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            
        case .visa:
            return UIImage(named: "visa_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .Diners:
            //            return UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .Discover:
            //            return UIImage(named: "discover_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .Amex:
            //            return UIImage(named: "amex_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .Diners:
            //            return UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .JCB:
            //            return UIImage(named: "jcb_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            //        case .Maestro:
            //            return UIImage(named: "maestro_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            
        default:
            return UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)!
        }
    }
    
    func buttonPressed(recognizer : UITapGestureRecognizer) {
        if self.paymentMethod?.isDefault == false {
            MyCheckWallet.manager.setPaymentMethodAsDefault(self.paymentMethod!, success: {
                print("set payment as default")
                }, fail: { (error) in
                    print("did not set payment as default")
            })
        }
    }
}
