//
//  ViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 09/25/2016.
//  Copyright (c) 2016 elad schiller. All rights reserved.
//

import UIKit
import MyCheckWalletUI
class ViewController: UIViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       containerView.hidden = true
        MyCheckWallet.manager.login("eyJpdiI6InBCOEJwTEZEUExwRkROcW9LMm42Rmc9PSIsInZhbHVlIjoidmQ4enRsTmZQTFVMRFp6Q2ljcHFqZz09IiwibWFjIjoiNDU4YzA0ZGI5YTQ4MmYwNmJhN2UxMmNhMjFjYWU2YjM2MDQxMTlkZDFjZDkzYzI1M2YwZjE3N2E4MTUwNTg0OCJ9", publishableKey: "pk_MRWdeNtVaPHA273ijAjSjz2vF7Wyc", success: {
            //The view should only be displaid after a user is logged in
            self.containerView.hidden = false
        
            } , fail: { error in
        
        })
    }


internal override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "checkout" {
           let    checkoutViewController = segue.destinationViewController as? MCCheckoutViewController
          checkoutViewController?.checkoutDelegate = self
    }
}

}

extension ViewController : CheckoutDelegate {
    
    func checkoutViewShouldResizeHeight(newHeight : Float , animationDuration: NSTimeInterval)  -> Void {
        self.heightConstraint.constant = CGFloat(newHeight);
    }

}
