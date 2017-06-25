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
    
    
    
    private var _supportedPaymentNetworks: [PKPaymentNetwork]?
    //The methods apple pay should support for this device
    fileprivate var supportedPaymentNetworks: [PKPaymentNetwork] { get{
        
        guard let cached = _supportedPaymentNetworks else {
            let strings = LocalData.manager.getArray("supportedApplePayCardTypes")
            return ApplePayCreditCardTypes.stringsToPKPaymentNetworks(strings: strings)
            
        }
        return cached
        }
    }
    open static func initiate(_ scheme: String){
        if !initiated {
            //if the user can't make payments we will not add it to the wallet
            if PKPaymentAuthorizationViewController.canMakePayments() {
                let factory = ApplePayFactory()
                Wallet.shared.factories.append(factory)
                Wallet.shared.applePayLogic = self as! ApplePayInterface
            }
            initiated = true
            
            
        }
    }
    
    override func getAddMethodViewControllere(  ){
        
        
    }
    
    
    override func getAddMethodButton() -> PaymentMethodButtonRapper{
        
        
        //setting the big background button
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        
        let butRap = PaymentMethodButtonRapper(forType: .applePay)
        
        
        butRap.button.translatesAutoresizingMaskIntoConstraints = false
        
        butRap.button.setBackgroundImage(UIImage(named: "paymen_method_bg" , in: bundle, compatibleWith: nil), for: UIControlState())
        
        //creating the apple pay button and adding it into the super button
        let appleBut = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        appleBut.translatesAutoresizingMaskIntoConstraints = false
        
        butRap.button.addSubview(appleBut)
        
        appleBut.widthAnchor.constraint(equalToConstant: 90).priority = 900
        appleBut.heightAnchor.constraint(equalToConstant: 44)
        appleBut.leadingAnchor.constraint(greaterThanOrEqualTo: butRap.button.leadingAnchor, constant: 10)
        appleBut.trailingAnchor.constraint(greaterThanOrEqualTo: butRap.button.trailingAnchor, constant: 10)
        
        appleBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
        appleBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
        
        
        //adding target
        butRap.button.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        appleBut.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        
        
        
        return butRap
    }
    
    
    override func getCreditCardView(_ frame: CGRect, method: PaymentMethod) -> CreditCardView?{
        return ApplePayView(frame: frame, method: method)
    }
    
    @objc fileprivate func addMethodButPressed(_ sender: UIButton){
        
        //opening the wallet app
        UIApplication.shared.openURL(URL(string: "shoebox://")!)
        
    }
    
    
    override func getSmallAddMethodButton() -> PaymentMethodButtonRapper{
        
        let  butRapper = super.getSmallAddMethodButton()
        let superFrame = butRapper.button.frame
        
        //creating the apple pay button and adding it into the super button
        let appleBut = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        appleBut.frame = CGRect(x: 0, y: 0, width: superFrame.size.width - 20, height: superFrame.size.height - 20)
        
        butRapper.button.addSubview(appleBut)
        appleBut.center = butRapper.button.center
        butRapper.button.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        appleBut.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        
        return butRapper
    }
    
    
    //creats a new copy of the payment method but as the desired subclass
    internal override func getPaymentMethod(_ other: PaymentMethod) -> PaymentMethod?{
        if other.type == .applePay{
            return ApplePayPaymentMethod(other: other)
        }
        return PaymentMethod(other: other)!
    }
    
    
    //ApplePay specific functions
    
    fileprivate func canPayWithApplePay() -> Bool{
        return  PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.supportedPaymentNetworks)
        
    }
}


extension ApplePayFactory: ApplePayInterface{
    func isApplePayDefault() -> Bool {
        if canPayWithApplePay(){
            return LocalData.wasApplePayDefault()
        }
        
        return false
    }
    
    func changeApplePayDefault(to newDefault: Bool) {
        if canPayWithApplePay(){
            LocalData.changeApplePayDefault(to: newDefault)
        }
    }
    
}



