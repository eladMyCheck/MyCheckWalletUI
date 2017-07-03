//
//  CreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit
import MyCheckCore

internal protocol CreditCardViewDelegate : class{
    func deletedPaymentMethod(_ method : PaymentMethodInterface)
    func setPaymentAsDefault(method: PaymentMethodInterface)
    func showActivityIndicator(_ show: Bool)
}

internal class CreditCardView: UIView, UIGestureRecognizerDelegate {
    
    var paymentMethod : PaymentMethodInterface?
    @IBOutlet weak var checboxButton : UIButton?
    var editMode = false
    var delegate : CreditCardViewDelegate?
    
    
    @IBOutlet weak var tempCardIcon: UIImageView!
    @IBOutlet weak var creditCardNumberlabel: UILabel?
    @IBOutlet weak var numberToTrailing: NSLayoutConstraint!
    @IBOutlet weak var expirationDateLabel: UILabel?
    @IBOutlet weak  var backgroundButton: UIButton?
    
    
    init(frame: CGRect, method: PaymentMethodInterface){
        super.init(frame: frame)
        
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        
        self.isUserInteractionEnabled = true
        self.paymentMethod = method
        
        xibSetup()
        
        
        tempCardIcon.isHidden = !method.isSingleUse
        //credit card number label
        if let creditCardNumberlabel = creditCardNumberlabel {
            creditCardNumberlabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
            creditCardNumberlabel.layer.cornerRadius = 4
            creditCardNumberlabel.clipsToBounds = true
            creditCardNumberlabel.textColor = UIColor.white
            creditCardNumberlabel.font =  UIFont(name: creditCardNumberlabel.font.fontName, size: creditCardNumberlabel.font.pointSize)
            creditCardNumberlabel.text = method.extaDescription
            
        }
        //expiration date label
        
        if let expirationDateLabel = expirationDateLabel{
            expirationDateLabel.textColor = UIColor.white
            expirationDateLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)
            expirationDateLabel.layer.cornerRadius = 4
            expirationDateLabel.clipsToBounds = true
            expirationDateLabel.font =  UIFont(name: expirationDateLabel.font.fontName, size: expirationDateLabel.font.pointSize )
            
            expirationDateLabel.text = method.extraSecondaryDescription
            
            
        }
        
        
        
        backgroundButton?.setImage(method.getBackgroundImage(), for: .normal)
        
        //default card checkbox
        
        
        if ((self.paymentMethod!.isDefault) == true) {
            self.checboxButton?.setImage(UIImage(named: "v", in: bundle, compatibleWith: nil)!, for: UIControlState())
            self.checboxButton?.isHidden = false
        }else{
            self.checboxButton?.isHidden = true
        }
    }
    
    //constuction helper function
    private func xibSetup() {
        //loading from nib
        let bundle =  MCViewController.getBundle( Bundle(for: CreditCardView.classForCoder()))
        let nib = UINib(nibName: "CreditCardView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    
    @IBAction func checkboxPressed(_ sender: UIButton!) {
        if editMode == true {
            Wallet.shared.deletePaymentMethod(self.paymentMethod!, success: {
                printIfDebug("payment method deleted")
                if let del = self.delegate{
                    del.deletedPaymentMethod(self.paymentMethod!)
                }
            }, fail: { (error) in
                printIfDebug("did not delete payment")
            })
        }
    }
    
    @IBAction func creditCardPressed(_ sender: UIButton!){
        if editMode == false {
            if (self.paymentMethod?.isSingleUse)! {
                return
            }
            if self.paymentMethod?.isDefault == false {
                self.delegate?.showActivityIndicator(true)
                Wallet.shared.setPaymentMethodAsDefault(self.paymentMethod!, success: {
                    self.delegate?.showActivityIndicator(false)
                    
                    printIfDebug("payment set as default")
                    if let del = self.delegate{
                        del.setPaymentAsDefault(method: self.paymentMethod!)
                        
                    }
                }, fail: { (error) in
                    self.delegate?.showActivityIndicator(false)
                    
                    printIfDebug("did not set payment as default")
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.paymentMethod = nil
    }
    
    internal func getType(_ type : String) -> CreditCardType {
        switch type {
        case "visa":
            return CreditCardType.Visa
        case "mastercard":
            return CreditCardType.MasterCard
        case "discover":
            return CreditCardType.Discover
        case "amex":
            return CreditCardType.Amex
        case "jcb":
            return CreditCardType.JCB
        case "dinersclub":
            return CreditCardType.Diners
        case "maestro":
            return CreditCardType.Maestro
            
        default:
            return CreditCardType.Unknown
        }
    }
    
   
    
    func toggleEditMode(){
        self.editMode = !self.editMode
        if self.editMode == true {
            let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
            self.checboxButton?.setImage(UIImage(named: "delete", in: bundle, compatibleWith: nil)!, for: UIControlState())
            self.checboxButton?.isHidden = false
        }else{
            if self.paymentMethod!.isDefault == true {
                let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
                self.checboxButton?.setImage(UIImage(named: "v", in: bundle, compatibleWith: nil)!, for: UIControlState())
                self.checboxButton?.isHidden = false
            }else{
                self.checboxButton?.isHidden = true
            }
        }
    }
}


 

