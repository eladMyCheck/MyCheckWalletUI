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
}

open class PaymentMethodFactory: NSObject {
    internal var delegate : PaymentMethodFactoryDelegate? = nil
    //was the factory ever initiated.
    static var initiated = false

    var type :PaymentMethodType { get { return PaymentMethodType.non }}
    
       func getAddMethodViewControllere( ){
        
         let errormessage = "you must subclass this"
            let errorWithMessage = NSError(domain: "error", code: 334 , userInfo: [NSLocalizedDescriptionKey : errormessage])
        if let delegate = delegate{
        delegate.error(self, error: errorWithMessage)
        }
        }
    
    func getAddMethodButton() -> PaymentMethodButton{
        let but = PaymentMethodButton()
        return but
    }
    
    //this button is meant for use in the checkout view controller
    func getSmallAddMethodButton() -> PaymentMethodButton{
        let but = PaymentMethodButton()
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))

        let image = UIImage(named: "checkout_wallet_but_bg" , in: bundle, compatibleWith: nil)
        but.frame = CGRect(x: 0, y: 0, width: 133.0, height: 41.0)
        but.setBackgroundImage(image, for: UIControlState())
        but.addConstraint(NSLayoutConstraint(
            item: but,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 133))
        but.addConstraint(NSLayoutConstraint(
            item: but,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 41))
        return but
    }
    
    //this is called by the mycheck wallet singlton after the user has logged in
     func configureAfterLogin(){
    
    }
    func getCreditCardView(_ frame: CGRect, method: PaymentMethod) -> CreditCardView?{
        return PayPalView(frame: frame, method: method)
    }
  
  
  //for returning urls in the app delegate
  open  func handleOpenURL(_ url: URL, sourceApplication: String?) -> Bool{
  return false
  }
  //creats a new copy of the payment method but as the desired subclass
  internal func getPaymentMethod(_ other: PaymentMethod) -> PaymentMethod?{
   
    return PaymentMethod(other: other)!
  }
}


