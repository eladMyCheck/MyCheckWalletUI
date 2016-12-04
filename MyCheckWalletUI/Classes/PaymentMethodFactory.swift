//
//  PaymentMethodRapperViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//
                    
import UIKit
internal protocol PaymentMethodFactoryDelegate{
    func error(controller: PaymentMethodFactory , error:NSError)
    func addedPaymentMethod(controller: PaymentMethodFactory ,token:String)
    func displayViewController(controller: UIViewController )

    func dismissViewController(controller: UIViewController )
  func showLoadingIndicator(controller: PaymentMethodFactory ,show: Bool)
}

public class PaymentMethodFactory: NSObject {
    internal var delegate : PaymentMethodFactoryDelegate? = nil
    //was the factory ever initiated.
    static var initiated = false

    var type :PaymentMethodType { get { return PaymentMethodType.Non }}
    
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
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))

        let image = UIImage(named: "checkout_wallet_but_bg" , inBundle: bundle, compatibleWithTraitCollection: nil)
        but.frame = CGRect(x: 0, y: 0, width: 133.0, height: 41.0)
        but.setBackgroundImage(image, forState: .Normal)
        but.addConstraint(NSLayoutConstraint(
            item: but,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 133))
        but.addConstraint(NSLayoutConstraint(
            item: but,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 41))
        return but
    }
    
    //this is called by the mycheck wallet singlton after the user has logged in
     func configureAfterLogin(){
    
    }
    func getCreditCardView(frame: CGRect, method: PaymentMethod) -> CreditCardView?{
        return PayPalView(frame: frame, method: method)
    }
  
  
  //for returning urls in the app delegate
  public  func handleOpenURL(url: NSURL, sourceApplication: String?) -> Bool{
  return false
  }
  //creats a new copy of the payment method but as the desired subclass
  internal func getPaymentMethod(other: PaymentMethod) -> PaymentMethod?{
   
    return PaymentMethod(other: other)!
  }
}


