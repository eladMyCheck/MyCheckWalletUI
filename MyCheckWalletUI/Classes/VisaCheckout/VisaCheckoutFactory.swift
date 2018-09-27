//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import MyCheckCore
import VisaCheckoutSDK

open class VisaCheckoutFactory : PaymentMethodFactory,VisaCheckoutConfigurrationDelegate{
    
    //was the factory ever initiated.
    static var initiated = false
    var apiKey : String?
    var checkoutVisaButRap : VisaCheckoutConfigurration?
    var methodsManagerVisaButRap : VisaCheckoutConfigurration?
    
    override var type :PaymentMethodType { get { return PaymentMethodType.visaCheckout }}
    
    public static func initiate(apiKey: String){
        if !initiated {
            let factory = VisaCheckoutFactory()
            
            factory.apiKey = apiKey
            
            VisaCheckoutSDK.configure()
            
            Wallet.shared.factories.append(factory)
            initiated = true
        }
    }
    
    override func getAddMethodViewControllere() {
        
    }
    
    public func resultHandler(result: CheckoutResult) {
        if let delegate = self.delegate{
            if let JSON = result.payload{//if this object exsists it means the visa checkout succeeded
                let singleUse = delegate.shouldBeSingleUse(self)
                
                Wallet.shared.addVisaCheckout(payload: JSON, singleUse: singleUse, success: { method in
                    Wallet.shared.applePayController.changeApplePayDefault(to: false)
                    if let delegate = self.delegate{
                        delegate.addedPaymentMethod(self, method: method , message: LocalData.manager.getAddedVisaCheckoutMessage())
                    }
                }, fail: {error in
                    
                })
            }
        }
    }
    
    @objc private func buttonClicked(_ sender : UIButton){
        switch sender.tag {
        case VisaCheckoutConfigurration.VisaCheckoutButtonRaperType.checkout.rawValue:
            if let rapper = self.checkoutVisaButRap,let launchCheckout = rapper.getLaunchCheckout(){
                launchCheckout()
            }
            break
        case VisaCheckoutConfigurration.VisaCheckoutButtonRaperType.methodsManager.rawValue:
            if let rapper = self.methodsManagerVisaButRap,let launchCheckout = rapper.getLaunchCheckout(){
                launchCheckout()
            }
            break
        default:
            print("VisaCheckout Error")
            break
        }
    }
    
    override func getAddMethodButton(presenter : UIViewController) -> PaymentMethodButtonRapper{
        
        let butRap = PaymentMethodButtonRapper(forType: .visaCheckout)

        butRap.button.translatesAutoresizingMaskIntoConstraints = false

        //creating the apple pay button and adding it into the super button
        let innerBut = UIImageView()
        innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgViseCheckout")))
        innerBut.translatesAutoresizingMaskIntoConstraints = false
        innerBut.contentMode = .scaleAspectFit
        innerBut.tag = VisaCheckoutConfigurration.VisaCheckoutButtonRaperType.methodsManager.rawValue
        butRap.button.addSubview(innerBut)
        
        innerBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
        innerBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
        
        let heightConstraint = NSLayoutConstraint(item: innerBut,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: butRap.button,
                                                  attribute: .height,
                                                  multiplier: 1.03,
                                                  constant: 0)
        
        butRap.button.addConstraint(heightConstraint)

        //adding target
        butRap.button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        
        if let apiKey = self.apiKey {
            self.methodsManagerVisaButRap = VisaCheckoutConfigurration(delegate: self, type: .methodsManager, apiKey: apiKey, presenter: presenter, btnRapper: butRap)
        }
        
        return butRap
    }
    
    override func getSmallAddMethodButton(presenter : UIViewController) -> PaymentMethodButtonRapper{
        let butRap = super.getSmallAddMethodButton(presenter: presenter)
        
        //creating the apple pay button and adding it into the super button
        let innerBut = UIButton(type: .custom)
        innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgViseCheckout")), for: .normal)
        innerBut.translatesAutoresizingMaskIntoConstraints = false
        innerBut.tag = VisaCheckoutConfigurration.VisaCheckoutButtonRaperType.checkout.rawValue
        butRap.button.addSubview(innerBut)

        innerBut.leadingAnchor.constraint(greaterThanOrEqualTo: butRap.button.leadingAnchor, constant: 10).isActive = true

        innerBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
        innerBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
        //aspect ratio
        let aspectRatioConstraint = NSLayoutConstraint(item: innerBut,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: innerBut,
                                                       attribute: .width,
                                                       multiplier: (109.0 / 502.0),
                                                       constant: 0)
        
        innerBut.addConstraint(aspectRatioConstraint)
        
        //adding target
        butRap.button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        innerBut.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        if let apiKey = self.apiKey {
            self.checkoutVisaButRap = VisaCheckoutConfigurration(delegate: self, type: .checkout, apiKey: apiKey, presenter: presenter, btnRapper: butRap)
        }
        
        return butRap
    }
}
