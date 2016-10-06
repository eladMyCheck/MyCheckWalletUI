//
//  CreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

internal protocol CreditCardViewDelegate {
    func deletedPaymentMethod()
    func setPaymentAsDefault()
    func startActivityIndicator()
}

internal class CreditCardView: UIView, UIGestureRecognizerDelegate {

    var paymentMethod : PaymentMethod?
    var checkbox : UIImageView?
    var editMode = false
    var delegate : CreditCardViewDelegate?
    
    init(frame: CGRect, method: PaymentMethod){
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.paymentMethod = method
        
        backgroundColor = UIColor.init(patternImage: self.setImageForType(self.getType(method.issuer)))
        
        //credit card number label
        var creditCardNumberlabel = UILabel(frame: CGRectMake(10, 70, 80, 18))
        creditCardNumberlabel.textAlignment = NSTextAlignment.Center
        creditCardNumberlabel.textColor = UIColor.whiteColor()
        creditCardNumberlabel.font =  UIFont(name: creditCardNumberlabel.font.fontName, size: 9)
        creditCardNumberlabel.text = String(format: "XXXX-%@", method.lastFourDigits)
        addSubview(creditCardNumberlabel)
        
        //expiration date label
        var expirationDateLabel = UILabel(frame: CGRectMake(112, 70, 30, 18))
        expirationDateLabel.textAlignment = NSTextAlignment.Center
        expirationDateLabel.textColor = UIColor.whiteColor()
        expirationDateLabel.font =  UIFont(name: expirationDateLabel.font.fontName, size: 9)
        expirationDateLabel.text = String(format: "%d/%d", method.expireMonth, method.expireYear%100)
        addSubview(expirationDateLabel)
        
        
        //default card checkbox
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        self.checkbox = UIImageView(frame: CGRectMake(165, 0, 20, 20))
        addSubview(self.checkbox!)
        if ((self.paymentMethod!.isDefault) == true) {
            self.checkbox!.image = UIImage(named: "v", inBundle: bundle, compatibleWithTraitCollection: nil)!
            self.checkbox?.hidden = false
        }else{
            self.checkbox?.hidden = true
        }

        var recognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        recognizer.delegate = self;
        self.addGestureRecognizer(recognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.paymentMethod = nil
    }
    
    internal func getType(type : String) -> CreditCardType {
        switch type {
        case "visa":
            return CreditCardType.visa
        case "mastercard":
            return CreditCardType.masterCard
        case "discover":
            return CreditCardType.discover
        case "amex":
            return CreditCardType.amex
        case "jcb":
            return CreditCardType.JCB
        case "dinersclub":
            return CreditCardType.diners
        case "maestro":
            return CreditCardType.maestro
            
        default:
            return CreditCardType.unknown
        }
    }
    
    internal func setImageForType( type: CreditCardType) -> UIImage{
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .masterCard:
            return UIImage(named: "master_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .visa:
            return UIImage(named: "visa_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .diners:
            return UIImage(named: "diners_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .discover:
            return UIImage(named: "discover_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .amex:
            return UIImage(named: "amex_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .diners:
            return UIImage(named: "diners_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .JCB:
            return UIImage(named: "jcb_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .maestro:
            return UIImage(named: "maestro_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
            
        default:
            return UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)!
        }
    }
    
    func buttonPressed(recognizer : UITapGestureRecognizer) {
        if editMode == false {
            if self.paymentMethod?.isDefault == false {
                self.delegate?.startActivityIndicator()
                MyCheckWallet.manager.setPaymentMethodAsDefault(self.paymentMethod!, success: {
                    print("payment set as default")
                    self.delegate?.setPaymentAsDefault()
                    }, fail: { (error) in
                        print("did not set payment as default")
                })
            }
        }else{
            MyCheckWallet.manager.deletePaymentMethod(self.paymentMethod!, success: {
                print("payment method deleted")
                self.delegate?.deletedPaymentMethod()
                }, fail: { (error) in
                    print("did not delete payment")
            })
        }
    }
    
    func toggleEditMode(){
        self.editMode = !self.editMode
        if self.editMode == true {
            let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
            self.checkbox!.image = UIImage(named: "delete", inBundle: bundle, compatibleWithTraitCollection: nil)!
            self.checkbox?.hidden = false
        }else{
            if ((self.paymentMethod!.isDefault) == true) {
                let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
                self.checkbox!.image = UIImage(named: "v", inBundle: bundle, compatibleWithTraitCollection: nil)!
                self.checkbox?.hidden = false
            }else{
                self.checkbox?.hidden = true
            }
        }
    }
}
