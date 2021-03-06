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
    func deletedPaymentMethod(_ method : PaymentMethodInterface , _ array : [PaymentMethodInterface])
    func setPaymentAsDefault(method: PaymentMethodInterface)
    func showActivityIndicator(_ show: Bool)
}

internal class CreditCardView: UIView, UIGestureRecognizerDelegate {
    
    var paymentMethod : PaymentMethodInterface?
    @IBOutlet weak var checkboxButton : UIButton!
    var delegate : CreditCardViewDelegate?
    
    @IBOutlet weak var tempCardIcon: UIImageView!
    @IBOutlet weak var creditCardNumberlabel: UILabel?
    @IBOutlet weak var expirationDateLabel: UILabel?
    @IBOutlet weak  var backgroundButton: UIButton?
    @IBOutlet weak var removeButton: UIButton!
    
    
    init(frame: CGRect, method: PaymentMethodInterface){
        super.init(frame: frame)
        
        
        self.isUserInteractionEnabled = true
        self.paymentMethod = method
        
        xibSetup()
        
        
        tempCardIcon.isHidden = !method.isSingleUse
        //credit card number label
        if let creditCardNumberlabel = creditCardNumberlabel {
            creditCardNumberlabel.layer.cornerRadius = 4
            creditCardNumberlabel.clipsToBounds = true
            creditCardNumberlabel.textColor = UIColor.white
            creditCardNumberlabel.font = UIFont.ragularFont(withSize: creditCardNumberlabel.font.pointSize)
            creditCardNumberlabel.text = method.extaDescription
            
        }
        //expiration date label
        
        if let expirationDateLabel = expirationDateLabel{
            expirationDateLabel.textColor = UIColor.white
            expirationDateLabel.layer.cornerRadius = 4
            expirationDateLabel.clipsToBounds = true
        
            expirationDateLabel.font = UIFont.ragularFont(withSize: expirationDateLabel.font.pointSize)

            expirationDateLabel.text = method.extraSecondaryDescription
            
        }
        
        backgroundButton?.setBackgroundImage(method.getBackgroundImage(), for: .normal)
        
        //default card checkbox
        
        
        if ((self.paymentMethod!.isDefault) == true) {
            
            self.checkboxButton.layer.cornerRadius = ((40 / 260) * frame.width) / 2
            self.checkboxButton.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.23).cgColor
            self.checkboxButton.layer.shadowRadius = 6.0
            self.checkboxButton.layer.shadowOpacity = 1.0
            self.checkboxButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.checkboxButton.layer.masksToBounds = false
            
            let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
            if let tintimage = UIImage(named: "checkmark", in: bundle, compatibleWith: nil){
                self.checkboxButton.setImage(tintimage.withRenderingMode(.alwaysTemplate), for: UIControlState())
                self.checkboxButton.tintColor = LocalData.manager.getColor("managePaymentMethodscolorsdefaultVcolor" , fallback: self.checkboxButton.tintColor)

            }
            
            self.checkboxButton.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsdefaultCircleBackground" , fallback: self.checkboxButton.backgroundColor!)
            
            self.checkboxButton.isHidden = false
        }else{
            self.checkboxButton.isHidden = true
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
    
    @IBAction func deletePressed(_ sender: UIButton!) {
        
        Wallet.shared.deletePaymentMethod(self.paymentMethod!, success: { array in
            printIfDebug("payment method deleted")
            if let del = self.delegate{
                del.deletedPaymentMethod(self.paymentMethod! , array)
            }
        }, fail: { (error) in
            printIfDebug("did not delete payment")
        })
    }
    
    @IBAction func creditCardPressed(_ sender: UIButton!){
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
    
   
    

}


 

