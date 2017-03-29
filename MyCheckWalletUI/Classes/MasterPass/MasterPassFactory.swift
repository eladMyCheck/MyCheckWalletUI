//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit

open class MasterPassFactory : PaymentMethodFactory{
    
    //was the factory ever initiated.
    static var initiated = false

  override var type :PaymentMethodType { get { return PaymentMethodType.masterPass }}
  
  open static func initiate(){
    if !initiated {
      let factory = MasterPassFactory()
      MyCheckWallet.manager.factories.append(factory)
      initiated = true
      
      
    }
  }

  override func getAddMethodViewControllere(  ){
   
    if let delegate = self.delegate{
      delegate.showLoadingIndicator(self, show: true)

    
        MyCheckWallet.manager.getMasterPassCredentials(masterPassURL: "TO-DO", success: {token , merchant in
        
            delegate.showLoadingIndicator(self, show: false)
            let controller = AddMasterPassViewController(delegate: self)
            delegate.displayViewController(controller)
        }, fail: {error in
            if let delegate = self.delegate{
            delegate.error(self, error: error)
            delegate.showLoadingIndicator(self, show: false)
            
            }
            
            })
      
      }
    }
  
  override func getAddMethodButton() -> PaymentMethodButton{
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    
    let but = PaymentMethodButton(type: .custom)
    but.setBackgroundImage(UIImage(named: "masterpass_paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
    but.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgMasterpass")), for: .normal , options: [.scaleFactor(2.0)])

    but.type = .masterPass
    //but.setImage(UIImage(named: "paypal_but", in: bundle, compatibleWith: nil), for: UIControlState())
    but.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
    //    but.setBackgroundImage(UIImage(named: "amex_small" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
    return but
  }
    
    

  @objc fileprivate func addMethodButPressed(_ sender: UIButton){
    if MyCheckWallet.manager.hasPaymentMethodOfType(.masterPass){
      
      
      if let delegate = self.delegate{
        let errorWithMessage = NSError(domain: "error", code: 3 , userInfo: [NSLocalizedDescriptionKey :LocalData.manager.getString("managePaymentMethodspaypalErrorMessage", fallback:  "Only 1 PayPal account can be added to the wallet.")])
        delegate.error(self, error: errorWithMessage)
      }
      return
    }
    
    getAddMethodViewControllere()
  }
  
  
  override func getSmallAddMethodButton() -> PaymentMethodButton{
    let but = super.getSmallAddMethodButton()
    
    but.type = .masterPass
    
    let i = LocalData.manager.getString("walletImgMasterpassCheckout")
    
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    but.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgMasterpassCheckout") ), for: .normal , options: [.scaleFactor(3.0)])
    
    
    but.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
    
    return but
  }
}


extension MasterPassFactory : AddMasterPassViewControllerDelegate{

    func addMasterPassReturned(payload: String){
        if let delegate = self.delegate{
            let singleUse = delegate.shouldBeSingleUse(self)
        MyCheckWallet.manager.addMasterPass(payload, singleUse: singleUse, success: {method in
            if let delegate = self.delegate ,  let method = method{
                
                delegate.addedPaymentMethod(self, token: method.token)
            }
        }, fail: {error in
            if let delegate = self.delegate{
                delegate.error(self, error: error)
            }
        })
        }
    }
    func masterPassFailed(error: NSError){
        if let delegate = self.delegate{
            delegate.error(self, error: error)
        }
    }
}

  
