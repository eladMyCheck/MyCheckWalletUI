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

open class VisaCheckoutFactory : PaymentMethodFactory{
    
    //was the factory ever initiated.
    static var initiated = false
    
    override var type :PaymentMethodType { get { return PaymentMethodType.visaCheckout }}
    
    open static func initiate(apiKey: String){
        if !initiated {
            let factory = VisaCheckoutFactory()
            Wallet.shared.factories.append(factory)
            initiated = true
            let profile = Profile(environment:  Networking.shared.environment == .production ? .production : .sandbox,
                                  apiKey: apiKey)
            profile.datalevel = .full
            VisaCheckoutSDK.configure(profile: profile)
            
        }
    }
    
    
    override func getAddMethodViewControllere(  ){
         if let delegate = self.delegate{
        VisaCheckoutSDK.checkout(total: 0.0, currency:  Currency(string: LocalData.manager.getString("currencyCode")), completion: {
            result in
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
        })
        }
    }
    
    
    override func getAddMethodButton() -> PaymentMethodButtonRapper{
        let butRap = PaymentMethodButtonRapper(forType: .visaCheckout)
        
        butRap.button.translatesAutoresizingMaskIntoConstraints = false
     
        //creating the apple pay button and adding it into the super button
        let innerBut = UIButton(type: .custom)
        innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgViseCheckout")), for: .normal)
        innerBut.translatesAutoresizingMaskIntoConstraints = false
        
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
        butRap.button.addTarget(self, action: #selector(VisaCheckoutFactory.getAddMethodViewControllere), for: .touchUpInside)
        innerBut.addTarget(self, action: #selector(VisaCheckoutFactory.getAddMethodViewControllere), for: .touchUpInside)


        return butRap
    }
    
    
    
    
    
    
    override func getSmallAddMethodButton() -> PaymentMethodButtonRapper{
        let butRap = super.getSmallAddMethodButton()
        
        
        
        //creating the apple pay button and adding it into the super button
        let innerBut = UIButton(type: .custom)
        innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgViseCheckout")), for: .normal)
        innerBut.translatesAutoresizingMaskIntoConstraints = false
        
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
        butRap.button.addTarget(self, action: #selector(VisaCheckoutFactory.getAddMethodViewControllere), for: .touchUpInside)
        innerBut.addTarget(self, action: #selector(VisaCheckoutFactory.getAddMethodViewControllere), for: .touchUpInside)
        
        
        
        //adding target
        butRap.button.addTarget(self, action: #selector(VisaCheckoutFactory.getAddMethodViewControllere), for: .touchUpInside)
        
        
        
        return butRap
    }
}


extension Currency{
    init(string: String){
    self = .usd
    }
}

