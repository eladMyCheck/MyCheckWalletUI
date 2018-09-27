//
//  VisaCheckoutButtonRaper.swift
//  MyCheckWalletUI
//
//  Created by MSApps on 27/09/2018.
//

import UIKit
import VisaCheckoutSDK
import MyCheckCore

public protocol VisaCheckoutConfigurrationDelegate{
    func resultHandler(result : CheckoutResult)
    
}

class VisaCheckoutConfigurration: NSObject {
    
    enum VisaCheckoutButtonRaperType : Int{
        case checkout = 11
        case methodsManager = 12
    }
    
    var delegate : VisaCheckoutConfigurrationDelegate?
    var presenter : UIViewController?
    var launchCheckout: LaunchHandle?
    var apiKey : String?
    var type : VisaCheckoutButtonRaperType?
    var buttonRapper : PaymentMethodButtonRapper?
    
    init(delegate : VisaCheckoutConfigurrationDelegate,type : VisaCheckoutButtonRaperType ,apiKey : String ,presenter : UIViewController, btnRapper : PaymentMethodButtonRapper) {
        super.init()
        
        self.delegate = delegate
        self.type = type
        self.apiKey = apiKey
        self.presenter = presenter
        
        self.setRapperTag()
        self.configureCustomButton()
        
    }
    
    private func setRapperTag(){
        if let rapper = self.buttonRapper,let type = self.type{
            rapper.button.tag = type.rawValue
            
            for view in rapper.button.subviews{
                if view is UIButton{
                    view.tag = type.rawValue
                }
            }
        }
    }
    
    private func configureCustomButton() {
        guard let apiKey = self.apiKey , let presenter = self.presenter else{
            return
        }
        
        let profile = Profile(environment:  Networking.shared.environment == .production ? .production : .sandbox,
                              apiKey: apiKey, profileName: nil)
        profile.datalevel = .full
        let amount = CurrencyAmount(double: 0.0)
        let currency = Currency(string: LocalData.manager.getString("currencyCode"))
        let purchaseInfo = PurchaseInfo(total: amount, currency: currency)
        
        VisaCheckoutSDK.configureManualCheckoutSession(profile: profile, purchaseInfo: purchaseInfo, presenting: presenter, onReady: { (launchHandle) in
            self.launchCheckout = launchHandle
            
        }, result: self.ResultHandler())
    }
    
    private func ResultHandler() -> VisaCheckoutResultHandler {
        return { result in
            // Make sure to re-init in your result handler
            self.configureCustomButton()
            
            switch (result.statusCode) {
            case .statusSuccess:
                print("SUCCESS");
                self.delegate?.resultHandler(result: result)
            case .statusInternalError:
                print("ERROR");
            case .statusNotConfigured:
                print("NOT CONFIGURED");
            case .statusDuplicateCheckoutAttempt:
                print("DUPLICATE CHECKOUT ATTEMPT");
            case .statusUserCancelled:
                NSLog("USER CANCELLED");
            case .default:
                print("SUCCESS");
            }
        }
    }
    
    public func getLaunchCheckout() ->LaunchHandle?{
        guard let launchCheckout = self.launchCheckout else {
            return nil
        }
        return launchCheckout
    }
}

extension Currency{
    init(string: String){
        self = .usd
    }
}
