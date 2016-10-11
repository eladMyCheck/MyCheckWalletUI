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
    var checboxButton : UIButton?
    var editMode = false
    var delegate : CreditCardViewDelegate?
    
    init(frame: CGRect, method: PaymentMethod){
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.paymentMethod = method
        
        let setCardAsDefaultButton = UIButton(frame: CGRectMake(0, 0, 163, 102))
        setCardAsDefaultButton.addTarget(self, action: #selector(creditCardPressed(_:)), forControlEvents: .TouchUpInside)
        setCardAsDefaultButton.setImage(self.setImageForType(self.getType(method.issuer)), forState: .Normal)
        setCardAsDefaultButton.adjustsImageWhenHighlighted = false
        addSubview(setCardAsDefaultButton)
        
        //credit card number label
        let creditCardNumberlabel = UILabel(frame: CGRectMake(10, 70, 80, 18))
        creditCardNumberlabel.textAlignment = NSTextAlignment.Center
        creditCardNumberlabel.textColor = UIColor.whiteColor()
        creditCardNumberlabel.font =  UIFont(name: creditCardNumberlabel.font.fontName, size: 9)
        creditCardNumberlabel.text = String(format: "XXXX-%@", method.lastFourDigits)
        addSubview(creditCardNumberlabel)
        
        //expiration date label
        let expirationDateLabel = UILabel(frame: CGRectMake(112, 70, 30, 18))
        expirationDateLabel.textAlignment = NSTextAlignment.Center
        expirationDateLabel.textColor = UIColor.whiteColor()
        expirationDateLabel.font =  UIFont(name: expirationDateLabel.font.fontName, size: 9)
      var year = method.expireYear
      if year.characters.count > 2 {
      year = year.substringFromIndex(year.startIndex.advancedBy(2))
      }
        expirationDateLabel.text = String(format: "%@/%@", method.expireMonth, year)
        addSubview(expirationDateLabel)
        
        
        //default card checkbox
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        
        self.checboxButton = UIButton(frame: CGRectMake(165, 0, 20, 20))
        self.checboxButton?.addTarget(self, action: #selector(checkboxPressed(_:)), forControlEvents: .TouchUpInside)
        self.checboxButton?.adjustsImageWhenHighlighted = false
        addSubview(self.checboxButton!)
        
        if ((self.paymentMethod!.isDefault) == true) {
            self.checboxButton?.setImage(UIImage(named: "v", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
            self.checboxButton?.hidden = false
        }else{
            self.checboxButton?.hidden = true
        }
    }
    
    func checkboxPressed(sender: UIButton!) {
        if editMode == true {
            MyCheckWallet.manager.deletePaymentMethod(self.paymentMethod!, success: {
                print("payment method deleted")
                if let del = self.delegate{
                    del.deletedPaymentMethod()
                }
                }, fail: { (error) in
                    print("did not delete payment")
            })
        }
    }
    
    func creditCardPressed(sender: UIButton!){
        if editMode == false {
            if self.paymentMethod?.isDefault == false {
                self.delegate?.startActivityIndicator()
                MyCheckWallet.manager.setPaymentMethodAsDefault(self.paymentMethod!, success: {
                    print("payment set as default")
                    if let del = self.delegate{
                        del.setPaymentAsDefault()
                    }
                    }, fail: { (error) in
                        print("did not set payment as default")
                })
            }
        }
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
            return UIImage(named: "master_card_background", inBundle: bundle, compatibleWithTraitCollection: nil)!
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
    
    func toggleEditMode(){
        self.editMode = !self.editMode
        if self.editMode == true {
            let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
            self.checboxButton?.setImage(UIImage(named: "delete", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
            self.checboxButton?.hidden = false
        }else{
            if self.paymentMethod!.isDefault == true {
                let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
                self.checboxButton?.setImage(UIImage(named: "v", inBundle: bundle, compatibleWithTraitCollection: nil)!, forState: .Normal)
                self.checboxButton?.hidden = false
            }else{
                self.checboxButton?.hidden = true
            }
        }
    }
}
