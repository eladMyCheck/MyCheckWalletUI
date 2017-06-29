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
      Wallet.shared.factories.append(factory)
      initiated = true
      
      
    }
  }

  override func getAddMethodViewControllere(  ){
   
    if let delegate = self.delegate{
      delegate.showLoadingIndicator(self, show: true)

    
        Wallet.shared.getMasterPassCredentials(masterPassURL: "TO-DO", success: {token , merchant in
        
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
  
  override func getAddMethodButton() -> PaymentMethodButtonRapper{
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    
    let butRap = PaymentMethodButtonRapper(forType: .masterPass)
    butRap.button.setBackgroundImage(UIImage(named: "masterpass_paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
    butRap.button.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgMasterpass")), for: .normal , options: [.scaleFactor(2.0)])

    //but.setImage(UIImage(named: "paypal_but", in: bundle, compatibleWith: nil), for: UIControlState())
    butRap.button.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
    //    but.setBackgroundImage(UIImage(named: "amex_small" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
    return butRap
  }
    
    

  @objc fileprivate func addMethodButPressed(_ sender: UIButton){
    if Wallet.shared.hasPaymentMethodOfType(.masterPass){
      
      
      if let delegate = self.delegate{
        let errorWithMessage = NSError(domain: "error", code: 3 , userInfo: [NSLocalizedDescriptionKey :LocalData.manager.getString("managePaymentMethodspaypalErrorMessage", fallback:  "Only 1 PayPal account can be added to the wallet.")])
        delegate.error(self, error: errorWithMessage)
      }
      return
    }
    
    getAddMethodViewControllere()
  }
  
  
  override func getSmallAddMethodButton() -> PaymentMethodButtonRapper{
    var butRap = super.getSmallAddMethodButton()
    
    butRap.type = .masterPass
    
    //  let i = LocalData.manager.getString("walletImgMasterpassCheckout")
    
    //  let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    butRap.button.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgMasterpassCheckout") ), for: .normal , options: [.scaleFactor(3.0)])
    
    
    butRap.button.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
    
    return butRap
  }
}


extension MasterPassFactory : AddMasterPassViewControllerDelegate{

    func addMasterPassReturned(payload: String){
        if let delegate = self.delegate{
            let singleUse = delegate.shouldBeSingleUse(self)
        Wallet.shared.addMasterPass(payload: payload, singleUse: singleUse, success: {method in
            if let delegate = self.delegate ,  let method = method{
                Wallet.shared.addedAPaymentMethod()
                delegate.addedPaymentMethod(self, method: method)
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

  
