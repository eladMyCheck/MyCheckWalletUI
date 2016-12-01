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
        
       containerView.hidden = true
        MyCheckWallet.manager.login("eyJpdiI6IkZ4N3hGMHU5UG42ZzMrOHlFcTFnRGc9PSIsInZhbHVlIjoibmJQR3VkVU9oN2NxbnB1T3BYV1NSM3FEbVNjQU52blB0Y2VnOEZycVZXZz0iLCJtYWMiOiJjYWI2NWY5Mzg5YTRmYmM5OWZjNWYyYjVjNTg0N2VkYWE3OWUzMGJlZWQwYWQ0MjNkNjMzYTRkMzNhMmVjNzNjIn0", success: {
            //The view should only be displaid after a user is logged in
            self.containerView.hidden = false
        
            } , fail: { error in
        
        })
    }


internal override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "checkout" {
               checkoutViewController = segue.destinationViewController as? MCCheckoutViewController
          checkoutViewController?.checkoutDelegate = self
    }
}
//MARK: - actions
  @IBAction func paymentMethodsPressed(sender: AnyObject) {
    let controller = MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
    self.presentViewController(controller, animated: true, completion: nil)
  }
    
    
  @IBAction func payPressed(sender: AnyObject) {
    var message = "No payment method available"
    
    //when a payment method is available you can get the method from the checkoutViewController using the selectedMethod variable. If it's nil non exist
    if let method = checkoutViewController!.selectedMethod {
    message =  " " + " token: " + method.token
    }
    
    
    let alert = UIAlertController(title: "paying with:", message: message, preferredStyle: .Alert);
    let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .Default, handler:
      {(alert: UIAlertAction!) in
        
        
    })
    alert.addAction(defaultAction)
   self.presentViewController(alert, animated: true, completion: nil)
  }
    
}

extension ViewController : CheckoutDelegate {
    
    func checkoutViewShouldResizeHeight(newHeight : Float , animationDuration: NSTimeInterval)  -> Void {
        self.heightConstraint.constant = CGFloat(newHeight);
        UIView.animateWithDuration(animationDuration, animations: {
            self.view.layoutIfNeeded()//resizing the container 

        })
    }

}

extension ViewController : MCPaymentMethodsViewControllerDelegate{
  
  
 func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController){
     controller.dismissViewControllerAnimated(true, completion: nil)
  }
}
