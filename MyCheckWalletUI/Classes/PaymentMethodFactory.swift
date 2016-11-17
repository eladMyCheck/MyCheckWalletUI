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
}


