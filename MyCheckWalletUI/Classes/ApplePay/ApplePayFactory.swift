//
//  ApplePayViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import PassKit
import MyCheckCore
open class ApplePayFactory : PaymentMethodFactory{
    //was the factory ever initiated.
    static var initiated = false
    
    override var type :PaymentMethodType { get { return PaymentMethodType.applePay }}
    
    
    fileprivate let credentials: ApplePayCredentials
  
    
    private init(credentials: ApplePayCredentials) {
        self.credentials = credentials
        super.init()

    }
    
    open static func initiate(merchantIdentifier: String){
        if !initiated {
            //if the user can't make payments we will not add it to the wallet
            if ApplePayFactory.deviceSupportsApplePay() {
                
                //fetching all the ApplePayCredentials
                Wallet.shared.configureWallet(success: {
                    let creditCardsStrings = LocalData.manager.getArray("applePaysupportedApplePayCardTypes")
                    //converting to payment network and removing nil 
                    let creditCards =  creditCardsStrings.map{
                        PKPaymentNetwork(string: $0)
                        }
                        .flatMap{ $0 }
                    
                    let credentials = ApplePayCredentials(merchantIdentifier: merchantIdentifier,
                                                          currencyCode: LocalData.manager.getString("currencyCode"),
                                                          countryCode: LocalData.manager.getString("applePaycountryCode"),
                                                          ApplePayCreditCardTypes: creditCards)
                    
                    
                    let factory = ApplePayFactory(credentials: credentials)
                    Wallet.shared.factories.append(factory)
                    Wallet.shared.applePayController = ApplePayState(credentials: credentials)
                    
                
                    initiated = true

                }, fail: nil)
                
            
        }
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

        appleBut.leadingAnchor.constraint(greaterThanOrEqualTo: butRap.button.leadingAnchor, constant: 10).isActive = true
        appleBut.trailingAnchor.constraint(greaterThanOrEqualTo: butRap.button.trailingAnchor, constant: 10).isActive = true
//        
        appleBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
        appleBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
      
        //aspect ratio
               let aspectRatioConstraint = NSLayoutConstraint(item: appleBut,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: appleBut,
                                                       attribute: .width,
                                                       multiplier: (109.0 / 502.0),
                                                       constant: 0)
        
        appleBut.addConstraint(aspectRatioConstraint)
        
        //adding target
        butRap.button.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        appleBut.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)

        
        
        return butRap
    }
    
    
    override func getCreditCardView(_ frame: CGRect, method: PaymentMethodInterface) -> CreditCardView?{
        return ApplePayView(frame: frame, method: method)
    }
  
    @objc fileprivate func addMethodButPressed(_ sender: UIButton){
        
        //opening the wallet app
        UIApplication.shared.openURL(URL(string: "shoebox://")!)
        
    }
    
    
    override func getSmallAddMethodButton() -> PaymentMethodButtonRapper{
        
        let  butRap = super.getSmallAddMethodButton()
        butRap.button.setBackgroundImage(nil, for: .normal)
        let superFrame = butRap.button.frame
        
        //creating the apple pay button and adding it into the super button
        let appleBut = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .white)
        appleBut.frame = CGRect(x: 0, y: 0, width: superFrame.size.width - 20, height: superFrame.size.height - 20)
        
        butRap.button.addSubview(appleBut)
        appleBut.center = butRap.button.center
        
        
        //creating the apple pay button and adding it into the super button
        
        appleBut.translatesAutoresizingMaskIntoConstraints = false
        
        butRap.button.addSubview(appleBut)
        
        appleBut.leadingAnchor.constraint(equalTo: butRap.button.leadingAnchor, constant: 0).isActive = true
        appleBut.trailingAnchor.constraint(equalTo: butRap.button.trailingAnchor, constant: 0).isActive = true
        //
        appleBut.topAnchor.constraint(equalTo: butRap.button.topAnchor, constant: 0).isActive = true
        appleBut.bottomAnchor.constraint(equalTo: butRap.button.bottomAnchor, constant: 0).isActive = true

        
        butRap.button.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        appleBut.addTarget(self, action: #selector(ApplePayFactory.addMethodButPressed(_:)), for: .touchUpInside)
        
        return butRap
    }
    
    
    
    
    
    //ApplePay specific functions
    private static func deviceSupportsApplePay() -> Bool{
        return PKPaymentAuthorizationViewController.canMakePayments()
        
    }
    }





