//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import Braintree

public class PaypalFactory : PaymentMethodFactory{
    
    override var type :PaymentMethodType { get { return PaymentMethodType.PayPal }}
    
    public static func initiate(scheme: String){
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
        
        
        MyCheckWallet.manager.getBraintreeToken({token in
            
            //
            //            //collecting device data
            //            if let brainClient  = BTAPIClient(authorization: token){
            //                let dataCollector = BTDataCollector(APIClient: brainClient)
            //                dataCollector.collectFraudData({data in
            //                    printIfDebug(data);
            //                })
            //            }
            //
            
            
            
            if let braintreeClient = BTAPIClient(authorization: token){
                
                let request = BTPayPalRequest()
                let driver = BTPayPalDriver(APIClient: braintreeClient)
                driver.viewControllerPresentingDelegate = self
                driver.requestBillingAgreement(request, completion: {nonce , error in
                    
                    if let error = error{
                        if let delegate = self.delegate{
                            delegate.error( self, error: error)
                            return;
                        }
                    }
                    if let nonce = nonce{
                        MyCheckWallet.manager.addPayPal(nonce.nonce, success: { method in
                            var token = ""
                            if let method = method {
                                token = method.token
                            }
                            self.delegate?.addedPaymentMethod(self, token: token)
                            }, fail: { error in
                                self.delegate?.error(self, error: error)
                        })
                    }
                })
            }
            }, fail: nil)
        
    }
    
    
    override func getAddMethodButton() -> PaymentMethodButton{
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        
        let but = PaymentMethodButton(type: .Custom)
        but.setBackgroundImage(UIImage(named: "paymen_method_bg" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        but.type = .PayPal
        but.setImage(UIImage(named: "paypal_but", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        but.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), forControlEvents: .TouchUpInside)
        //    but.setBackgroundImage(UIImage(named: "amex_small" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
        return but
    }
    override func getCreditCardView(frame: CGRect, method: PaymentMethod) -> CreditCardView?{
        return PayPalView(frame: frame, method: method)
    }
    @objc private func addMethodButPressed(sender: UIButton){
        if MyCheckWallet.manager.hasPaymentMethodOfType(.PayPal){
            
            
            if let delegate = self.delegate{
                let errorWithMessage = NSError(domain: "error", code: 3 , userInfo: [NSLocalizedDescriptionKey : "already have paypal"])
                delegate.error(self, error: errorWithMessage)
            }
            return
        }
        
        getAddMethodViewControllere()
    }
    
    
    override func getSmallAddMethodButton() -> PaymentMethodButton{
        let but = super.getSmallAddMethodButton()
        
        but.type = .PayPal
        
        
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        but.kf_setImageWithURL(NSURL( string: LocalData.manager.getString("walletIconspaypal") ), forState: .Normal , placeholderImage: nil , optionsInfo: [.ScaleFactor(3.0)])
        but.addTarget(self, action: #selector(PaypalFactory.addMethodButPressed(_:)), forControlEvents: .TouchUpInside)
        
        return but
    }
    //for returning urls in the app delegate
    public  override func handleOpenURL(url: NSURL, sourceApplication: String?) -> Bool{
        return   BTAppSwitch.handleOpenURL(url, sourceApplication:sourceApplication)
    }
}
extension PaypalFactory : BTViewControllerPresentingDelegate{
    @objc public func paymentDriver(driver: AnyObject, requestsDismissalOfViewController viewController: UIViewController) {
        if let delegate = self.delegate{
            delegate.dismissViewController(viewController)
        }
    }
    @objc public func paymentDriver(driver: AnyObject, requestsPresentationOfViewController viewController: UIViewController){
        if let delegate = self.delegate{
            delegate.displayViewController(viewController)
        }
    }
    
}
