//
//  ViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 09/25/2016.
//  Copyright (c) 2016 QuickCheck LTD. All rights reserved.
//

import UIKit
import MyCheckWalletUI
import MyCheckCore
class ViewController: UIViewController {
  
     var checkoutViewController : MCCheckoutViewController?
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       containerView.isHidden = true
        Session.shared.login("eyJpdiI6ImprMnJDVnVDZzBsXC9BNXBEWE9JRnJ3PT0iLCJ2YWx1ZSI6Ill2NFliVGpMOHk0QkVhT25BdHk2U3duS1k0WXJrZ2xPeW5aQVhUWWt5c1wvbjZiSGJndExOZEpcL2Z1bmdUMHV2diIsIm1hYyI6IjhjMzcwMWRjYWYxYWM5NTFiYmUyNjUwNTI2MGQ2NDlkMWFjZjZjNzIyZTgxOTRjN2QyMGMwN2JmM2MyYzc3NjIifQ==", success: {
            //The view should only be displaid after a user is logged in
            self.containerView.isHidden = false
        
            } , fail: { error in
        
        })
    }


internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "checkout" {
               checkoutViewController = segue.destination as? MCCheckoutViewController
          checkoutViewController?.checkoutDelegate = self
    }
}
//MARK: - actions
  @IBAction func paymentMethodsPressed(_ sender: AnyObject) {
    let controller = MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
    self.present(controller, animated: true, completion: nil)
  }
    
    
  @IBAction func payPressed(_ sender: AnyObject) {
    var message = "No payment method available"
    
    //when a payment method is available you can get the method from the checkoutViewController using the selectedMethod variable. If it's nil non exist
    if let method = checkoutViewController!.selectedMethod {
    message =  " " + " token: " + method.token
      UIPasteboard.general.string = method.token

    }

    
    let alert = UIAlertController(title: "paying with:", message: message, preferredStyle: .alert);
    let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .default, handler:
      {(alert: UIAlertAction!) in
        
        
    })
    alert.addAction(defaultAction)
   self.present(alert, animated: true, completion: nil)
  }
    
}

extension ViewController : CheckoutDelegate {
    
    func checkoutViewShouldResizeHeight(_ newHeight : Float , animationDuration: TimeInterval)  -> Void {
        self.heightConstraint.constant = CGFloat(newHeight);
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()//resizing the container 

        })
    }

}

extension ViewController : MCPaymentMethodsViewControllerDelegate{
  
  
 func dismissedMCPaymentMethodsViewController(_ controller: MCPaymentMethodsViewController){
     controller.dismiss(animated: true, completion: nil)
  }
}
