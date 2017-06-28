//
//  PaymentMethodRapperViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
internal protocol PaymentMethodFactoryDelegate{
    func error(_ controller: PaymentMethodFactory , error:NSError)
    func addedPaymentMethod(_ controller: PaymentMethodFactory ,token:String)
    func displayViewController(_ controller: UIViewController )
    
    func dismissViewController(_ controller: UIViewController )
    func showLoadingIndicator(_ controller: PaymentMethodFactory ,show: Bool)
    //askes the delegate if to add the payment method for single use or not
    func shouldBeSingleUse(_ controller: PaymentMethodFactory) -> Bool
}

open class PaymentMethodFactory: NSObject {
    internal var delegate : PaymentMethodFactoryDelegate? = nil
    
    var type :PaymentMethodType { get { return PaymentMethodType.non }}
    
    func getAddMethodViewControllere( ){
        
        let errormessage = "you must subclass this"
        let errorWithMessage = NSError(domain: "error", code: 334 , userInfo: [NSLocalizedDescriptionKey : errormessage])
        if let delegate = delegate{
            delegate.error(self, error: errorWithMessage)
        }
    }
    
    internal func getAddMethodButton() -> PaymentMethodButtonRapper{
        let but = PaymentMethodButtonRapper(forType: .non)
        return but
    }
    
    //this button is meant for use in the checkout view controller
    internal func getSmallAddMethodButton() -> PaymentMethodButtonRapper{
        let butRap = PaymentMethodButtonRapper(forType: .non)
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        
        let image = UIImage(named: "checkout_wallet_but_bg" , in: bundle, compatibleWith: nil)
        butRap.button.frame = CGRect(x: 0, y: 0, width: 133.0, height: 41.0)
        butRap.button.setBackgroundImage(image, for: UIControlState())
        butRap.button.addConstraint(NSLayoutConstraint(
            item: butRap.button,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 133))
        butRap.button.addConstraint(NSLayoutConstraint(
            item: butRap.button,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 41))
        return butRap
    }
    
    //this is called by the mycheck wallet singlton after the user has logged in
    internal func configureAfterLogin(){
        
    }
    internal func getCreditCardView(_ frame: CGRect, method: PaymentMethodInterface) -> CreditCardView?{
        return CreditCardView(frame: frame, method: method)
    }
    
    
    //for returning urls in the app delegate
    open  func handleOpenURL(_ url: URL, sourceApplication: String?) -> Bool{
        return false
    }
    //creats a new copy of the payment method but as the desired subclass
    internal func getPaymentMethod(JSON: NSDictionary) -> PaymentMethodInterface?{
        
        return CreditCardPaymentMethod(JSON: JSON)
    }
}


