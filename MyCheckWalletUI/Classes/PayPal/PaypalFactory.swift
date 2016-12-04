//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import Braintree

open class PaypalFactory : PaymentMethodFactory{
  
  override var type :PaymentMethodType { get { return PaymentMethodType.payPal }}
  
  open static func initiate(_ scheme: String){
    if !initiated {
      let factory = PaypalFactory()
      MyCheckWallet.manager.factories.append(factory)
      initiated = true
      
      BTAppSwitch.setReturnURLScheme(scheme)
      
    }
  }
  override func configureAfterLogin(){
    //getting the token
    MyCheckWallet.manager.getBraintreeToken( {
      token in
      printIfDebug(token);
      } , fail:nil)
  }
  override func getAddMethodViewControllere(  ){
    
    if let delegate = self.delegate{
      delegate.showLoadingIndicator(self, show: true)
    }
    MyCheckWallet.manager.getBraintreeToken({token in
      
      
      
      if let braintreeClient = BTAPIClient(authorization: token){
        
        let request = BTPayPalRequest()
        let driver = BTPayPalDriver(apiClient: braintreeClient)
        driver.viewControllerPresentingDelegate = self
        driver.requestBillingAgreement(request, completion: {nonce , error in
          
          if let error = error{
            if let delegate = self.delegate{
              delegate.error( self, error: error as NSError)
              delegate.showLoadingIndicator(self, show: false)
              return;
            }
          }
          if let nonce = nonce{
            MyCheckWallet.manager.addPayPal(nonce.nonce, success: { method in
              var token = ""
              if let method = method {
                token = method.token
              }
              if let delegate = self.delegate{
                delegate.showLoadingIndicator(self, show: false)
                
                delegate.addedPaymentMethod(self, token: token)
              }
              }, fail: { error in
                if let delegate = self.delegate{
                  delegate.error(self, error: error)
                  delegate.showLoadingIndicator(self, show: false)
                  
                }
            })
          }else{                              if let delegate = self.delegate{
            
            delegate.showLoadingIndicator(self, show: false)
            }
          }
        })
      }
      }, fail: {error in
        if let delegate = self.delegate{
          delegate.error(self, error: error)
          delegate.showLoadingIndicator(self, show: false)
          
        }
        
    })
    
  }
  
  
  override func getAddMethodButton() -> PaymentMethodButton{
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    
    let but = PaymentMethodButton(type: .custom)
    but.setBackgroundImage(UIImage(named: "paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
    but.type = .payPal
    but.setImage(UIImage(named: "paypal_but", in: bundle, compatibleWith: nil), for: UIControlState())
    but.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), for: .touchUpInside)
    //    but.setBackgroundImage(UIImage(named: "amex_small" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
    return but
  }
  override func getCreditCardView(_ frame: CGRect, method: PaymentMethod) -> CreditCardView?{
    return PayPalView(frame: frame, method: method)
  }
  @objc fileprivate func addMethodButPressed(_ sender: UIButton){
    if MyCheckWallet.manager.hasPaymentMethodOfType(.payPal){
      
      
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
    
    but.type = .payPal
    
    
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    but.kf_setImageWithURL(URL( string: LocalData.manager.getString("walletIconspaypal") ), forState: .Normal , placeholderImage: nil , optionsInfo: [.ScaleFactor(3.0)])
    but.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), for: .touchUpInside)
    
    return but
  }
  //for returning urls in the app delegate
  open  override func handleOpenURL(_ url: URL, sourceApplication: String?) -> Bool{
    return   BTAppSwitch.handleOpen(url, sourceApplication:sourceApplication)
  }
  
  //creats a new copy of the payment method but as the desired subclass
  internal override func getPaymentMethod(_ other: PaymentMethod) -> PaymentMethod?{
    if other.type == .payPal{
      return PayPalPaymentMethod(other: other)
    }
    return PaymentMethod(other: other)!
  }
}
extension PaypalFactory : BTViewControllerPresentingDelegate{
  @objc public func paymentDriver(_ driver: AnyObject, requestsDismissalOf viewController: UIViewController) {
    if let delegate = self.delegate{
      delegate.dismissViewController(viewController)
      //  delegate.showLoadingIndicator(self, show: false)
    }
  }
  @objc public func paymentDriver(_ driver: AnyObject, requestsPresentationOf viewController: UIViewController){
    if let delegate = self.delegate{
      delegate.displayViewController(viewController)
    }
  }
  
}
