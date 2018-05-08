//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import Braintree
import MyCheckCore

open class PaypalFactory : PaymentMethodFactory{
    //was the factory ever initiated.
    static var initiated = false

    override var type : PaymentMethodType { get { return PaymentMethodType.payPal }}
  
    open static func initiate(_ scheme: String){
    if !initiated {
      let factory = PaypalFactory()
      Wallet.shared.factories.append(factory)
      initiated = true
      
      BTAppSwitch.setReturnURLScheme(scheme)
      
    }
  }
    
  override func configureAfterLogin(){
    //getting the token
    Wallet.shared.getBraintreeToken( {
      token in
      printIfDebug(token);
      } , fail:nil)
  }
  override func getAddMethodViewControllere(  ){
   
    if let delegate = self.delegate{
      delegate.showLoadingIndicator(self, show: true)
        let singleUse = delegate.shouldBeSingleUse(self)

    
    Wallet.shared.getBraintreeToken({token in
      
      
      
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
          Wallet.shared.addPayPal(nonce.nonce, singleUse: singleUse, success: { method in
              
            delegate.showLoadingIndicator(self, show: false)
                
            delegate.addedPaymentMethod(self, method: method!)
            Wallet.shared.addedAPaymentMethod()

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
  
  
  override func getAddMethodButton() -> PaymentMethodButtonRapper{
    
    let butRap = PaymentMethodButtonRapper(forType: .payPal)
    butRap.button.translatesAutoresizingMaskIntoConstraints = false
    
    let innerBut = UIImageView()
    innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgPaypal")))
    innerBut.translatesAutoresizingMaskIntoConstraints = false
    innerBut.contentMode = .scaleAspectFit
    butRap.button.addSubview(innerBut)
    
    innerBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
    innerBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
    
    let heightConstraint = NSLayoutConstraint(item: innerBut,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: butRap.button,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 0)
    
    butRap.button.addConstraint(heightConstraint)
    
    //adding target
    butRap.button.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), for: .touchUpInside)
    
    return butRap
  }
    
    
  override func getCreditCardView(_ frame: CGRect, method: PaymentMethodInterface) -> CreditCardView?{
    return PayPalView(frame: frame, method: method)
  }
    
  @objc fileprivate func addMethodButPressed(_ sender: UIButton){
    if Wallet.shared.hasPaymentMethodOfType(.payPal){
      
      
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
    butRap.type = .payPal
    butRap.button.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgPaypalCheckout") ), for: .normal ,  options: [.scaleFactor(2.0)])
    butRap.button.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), for: .touchUpInside)
    return butRap
  }
  //for returning urls in the app delegate
  open  override func handleOpenURL(_ url: URL, sourceApplication: String?) -> Bool{
    return   BTAppSwitch.handleOpen(url, sourceApplication:sourceApplication)
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
