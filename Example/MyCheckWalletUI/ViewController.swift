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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //paymentMethodsBut.enabled = false
        MyCheckWallet.manager.login("eyJpdiI6InBCOEJwTEZEUExwRkROcW9LMm42Rmc9PSIsInZhbHVlIjoidmQ4enRsTmZQTFVMRFp6Q2ljcHFqZz09IiwibWFjIjoiNDU4YzA0ZGI5YTQ4MmYwNmJhN2UxMmNhMjFjYWU2YjM2MDQxMTlkZDFjZDkzYzI1M2YwZjE3N2E4MTUwNTg0OCJ9", publishableKey: "pk_MRWdeNtVaPHA273ijAjSjz2vF7Wyc", success: {
            
          
                let checkoutView = MCCheckoutView()
                 self.view.addSubview(checkoutView)
                        NSLayoutConstraint(item: checkoutView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 150).active = true
                
                        NSLayoutConstraint(item: checkoutView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: -24).active = true
                        NSLayoutConstraint(item: checkoutView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 24).active = true
                        NSLayoutConstraint(item: checkoutView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .BottomMargin, multiplier: 1.0, constant: -40).active = true
           

            } , fail: { error in
        
        })
    }
}

//extension ViewController : MCPaymentMethodsViewControllerDelegate{
//    func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
//    {
//    
//    }
//
//}

