//
//  ViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 09/25/2016.
//  Copyright (c) 2016 QuickCheck LTD. All rights reserved.
//

import UIKit
import MyCheckWalletUI
class ViewController: UIViewController {
  
     var checkoutViewController : MCCheckoutViewController?
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       containerView.isHidden = true
        MyCheckWallet.manager.login("eyJpdiI6InlxV2ZSWVJWOWdXc1lNeU92Y1VyRGc9PSIsInZhbHVlIjoiMU00MCtRUTZRQ3dLVFdkdE5pTGtyQT09IiwibWFjIjoiMzVhY2MxY2VhYzNlNTY2YzEzYzQzZmU2YzRlN2Q2NTNhOTZjMzliMjY2YjEyYWI4Yjg5ZmNmYWVmZTRjNmZhYiJ9", success: {
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
