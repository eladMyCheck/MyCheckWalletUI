//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import VisaCheckoutSDK
open class VisaCheckoutFactory : PaymentMethodFactory{
    
    //was the factory ever initiated.
    static var initiated = false

  override var type :PaymentMethodType { get { return PaymentMethodType.visaCheckout }}
  
  open static func initiate(){
    if !initiated {
      let factory = VisaCheckoutFactory()
      MyCheckWallet.manager.factories.append(factory)
      initiated = true
      
      
    }
  }

  override func getAddMethodViewControllere(  ){
   
    if let delegate = self.delegate{
        //   delegate.showLoadingIndicator(self, show: true)


      
      }
    }
  
  override func getAddMethodButton() -> PaymentMethodButton{
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    
    let but = PaymentMethodButton(type: .custom)
    but.setBackgroundImage(UIImage(named: "masterpass_paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())

    but.type = .visaCheckout
    
    let rect = CGRect(
        origin: CGPoint(x: 0, y: 0),
        size: CGSize(width: 100, height: 60)
    )
    let checkoutButton = VisaCheckoutButton(frame: rect)
    
    checkoutButton.style = .neutral
    but.addSubview(checkoutButton)
    return but
  }
    
    


  
  
  override func getSmallAddMethodButton() -> PaymentMethodButton{
    let but = super.getSmallAddMethodButton()
    
    but.type = .visaCheckout
    
    let i = LocalData.manager.getString("walletImgMasterpassCheckout")
    
        return but
  }
}



  
