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
    //was the factory ever initiated.
    static var initiated = false

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
        let singleUse = delegate.shouldBeSingleUse(self)

    
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
          if let nonce = nonce , let delegate = self.delegate{
          MyCheckWallet.manager.addPayPal(nonce.nonce, singleUse: singleUse, success: { method in
              var token = ""
              if let method = method {
                token = method.token
              }
                delegate.showLoadingIndicator(self, show: false)
                
                delegate.addedPaymentMethod(self, token: token)
            
              }, fail: { error in
                  delegate.error(self, error: error)
                  delegate.showLoadingIndicator(self, show: false)
                  
                
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
  }
  
  
  override func getAddMethodButton() -> PaymentMethodButton{
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    
    let but = PaymentMethodButton(type: .custom)
    but.setBackgroundImage(UIImage(named: "paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
    but.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgPaypal")), for: .normal , options: [.scaleFactor(2.0)])
    but.type = .payPal
    //but.setImage(UIImage(named: "paypal_but", in: bundle, compatibleWith: nil), for: UIControlState())
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
    but.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgPaypalCheckout") ), for: .normal ,  options: [.scaleFactor(3.0)])
    
    
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
    /*!
     @brief The payment driver requires presentation of a view controller in order to proceed.
     
     @discussion Your implementation should present the viewController modally, e.g. via
     `presentViewController:animated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to present
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        if let delegate = self.delegate{
            delegate.displayViewController(viewController)
        }
    }

    /*!
     @brief The payment driver requires dismissal of a view controller.
     
     @discussion Your implementation should dismiss the viewController, e.g. via
     `dismissViewControllerAnimated:completion:`
     
     @param driver         The payment driver
     @param viewController The view controller to be dismissed
     */
    @available(iOS 2.0, *)
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        if let delegate = self.delegate{
            delegate.dismissViewController(viewController)
            //  delegate.showLoadingIndicator(self, show: false)
        }
    }


  
}
