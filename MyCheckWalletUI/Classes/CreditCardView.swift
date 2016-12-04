//
//  CreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

internal protocol CreditCardViewDelegate : class{
    func deletedPaymentMethod(_ method : PaymentMethod)
    func setPaymentAsDefault()
  func showActivityIndicator(_ show: Bool)
}

internal class CreditCardView: UIView, UIGestureRecognizerDelegate {
    
    var paymentMethod : PaymentMethod?
    var checboxButton : UIButton?
    var editMode = false
    var delegate : CreditCardViewDelegate?
    
    
    var creditCardNumberlabel: UILabel?
    var expirationDateLabel: UILabel?
    var backgroundButton: UIButton?
    init(frame: CGRect, method: PaymentMethod){
        super.init(frame: frame)
      
      let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))

        self.isUserInteractionEnabled = true
        self.paymentMethod = method
        
         backgroundButton = UIButton(frame: CGRect(x: 0, y: 0, width: 163, height: 102))
        if  let backgroundButton = backgroundButton{
        backgroundButton.addTarget(self, action: #selector(creditCardPressed(_:)), for: .touchUpInside)
        backgroundButton.setImage(self.setImageForType(method.issuer), for: UIControlState())
        backgroundButton.adjustsImageWhenHighlighted = false
        addSubview(backgroundButton)
        }
      
      if method.isSingleUse {
      let singleUseImg = UIImageView(image:UIImage(named: "singleUseBanner", in: bundle, compatibleWith: nil) )
        singleUseImg.contentMode = .topRight
        singleUseImg.frame = (backgroundButton?.frame)!
        addSubview(singleUseImg)
      }
        //credit card number label
        creditCardNumberlabel  = UILabel(frame: CGRect(x: 10, y: 70, width: 80, height: 18))
        if let creditCardNumberlabel = creditCardNumberlabel {
        creditCardNumberlabel.textAlignment = NSTextAlignment.center
        creditCardNumberlabel.textColor = UIColor.white
        creditCardNumberlabel.font =  UIFont(name: creditCardNumberlabel.font.fontName, size: 9)
        if let lastFourDigits = method.lastFourDigits{
            creditCardNumberlabel.text = method.name
          }
        addSubview(creditCardNumberlabel)
            }
        //expiration date label
       expirationDateLabel = UILabel(frame: CGRect(x: 112, y: 70, width: 30, height: 18))

        if let expirationDateLabel = expirationDateLabel{
        expirationDateLabel.textAlignment = NSTextAlignment.center
        expirationDateLabel.textColor = UIColor.white
        expirationDateLabel.font =  UIFont(name: expirationDateLabel.font.fontName, size: 9)
        if var year = method.expireYear, let month = method.expireMonth{
            if year.characters.count > 2 {
                year = year.substring(from: year.characters.index(year.startIndex, offsetBy: 2))
                
                expirationDateLabel.text = String(format: "%@/%@", month, year)
                addSubview(expirationDateLabel)
            }
            }
        }
        
        
        
        //default card checkbox
      
        self.checboxButton = UIButton(frame: CGRect(x: 165, y: 0, width: 20, height: 20))
        self.checboxButton?.addTarget(self, action: #selector(checkboxPressed(_:)), for: .touchUpInside)
        self.checboxButton?.adjustsImageWhenHighlighted = false
        addSubview(self.checboxButton!)
        
        if ((self.paymentMethod!.isDefault) == true) {
            self.checboxButton?.setImage(UIImage(named: "v", in: bundle, compatibleWith: nil)!, for: UIControlState())
            self.checboxButton?.isHidden = false
        }else{
            self.checboxButton?.isHidden = true
        }
    }
    
    func checkboxPressed(_ sender: UIButton!) {
        if editMode == true {
            MyCheckWallet.manager.deletePaymentMethod(self.paymentMethod!, success: {
                printIfDebug("payment method deleted")
                if let del = self.delegate{
                    del.deletedPaymentMethod(self.paymentMethod!)
                }
                }, fail: { (error) in
                    printIfDebug("did not delete payment")
            })
        }
    }
    
    func creditCardPressed(_ sender: UIButton!){
        if editMode == false {
            if self.paymentMethod?.isDefault == false {
                self.delegate?.showActivityIndicator(true)
                MyCheckWallet.manager.setPaymentMethodAsDefault(self.paymentMethod!, success: {
                  self.delegate?.showActivityIndicator(false)

                    printIfDebug("payment set as default")
                    if let del = self.delegate{
                        del.setPaymentAsDefault()
                        
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
    
    internal func setImageForType( _ type: CreditCardType) -> UIImage{
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .MasterCard:
            return UIImage(named: "master_card_background", in: bundle, compatibleWith: nil)!
        case .Visa:
            return UIImage(named: "visa_background", in: bundle, compatibleWith: nil)!
        case .Diners:
            return UIImage(named: "diners_background", in: bundle, compatibleWith: nil)!
        case .Discover:
            return UIImage(named: "discover_background", in: bundle, compatibleWith: nil)!
        case .Amex:
            return UIImage(named: "amex_background", in: bundle, compatibleWith: nil)!
        case .Diners:
            return UIImage(named: "diners_background", in: bundle, compatibleWith: nil)!
        case .JCB:
            return UIImage(named: "jcb_background", in: bundle, compatibleWith: nil)!
        case .Maestro:
            return UIImage(named: "maestro_background", in: bundle, compatibleWith: nil)!
            
        default:
            return UIImage(named: "notype_background" , in: bundle, compatibleWith: nil)!
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
