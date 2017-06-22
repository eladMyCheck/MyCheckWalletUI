//
//  ApplePayViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import PassKit
open class ApplePayFactory : PaymentMethodFactory{
    //was the factory ever initiated.
    static var initiated = false
    
    override var type :PaymentMethodType { get { return PaymentMethodType.applePay }}
    
    open static func initiate(_ scheme: String){
        if !initiated {
            let factory = ApplePayFactory()
            Wallet.shared.factories.append(factory)
            initiated = true
            
            
        }
    }
   
    override func getAddMethodViewControllere(  ){
        
        
    }
    
    
    override func getAddMethodButton() -> PaymentMethodButtonRapper{
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        
        let butRap = PaymentMethodButtonRapper(forType: .applePay)
        butRap.button.setBackgroundImage(UIImage(named: "paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
        butRap.button.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgApplePay")), for: .normal , options: [.scaleFactor(2.0)])
        //but.setImage(UIImage(named: "ApplePay_but", in: bundle, compatibleWith: nil), for: UIControlState())
        butRap.button.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        //    but.setBackgroundImage(UIImage(named: "amex_small" , inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
        return butRap
    }
    
    
    override func getCreditCardView(_ frame: CGRect, method: PaymentMethod) -> CreditCardView?{
        return ApplePayView(frame: frame, method: method)
    }
    @objc fileprivate func addMethodButPressed(_ sender: UIButton){
        if Wallet.shared.hasPaymentMethodOfType(.applePay){
            
            
            
            
            getAddMethodViewControllere()
        }
    }
    
    
       override func getSmallAddMethodButton() -> PaymentMethodButtonRapper{

        //  superRapper = super.getSmallAddMethodButton()
        let but = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .white)
        but.frame = CGRect(x: 0, y: 0, width: 22, height: 44)
        return PaymentMethodButtonRapper(button: but, forType: .applePay)
    }
    
    
    //creats a new copy of the payment method but as the desired subclass
    internal override func getPaymentMethod(_ other: PaymentMethod) -> PaymentMethod?{
        if other.type == .applePay{
            return ApplePayPaymentMethod(other: other)
        }
        return PaymentMethod(other: other)!
    }
}




