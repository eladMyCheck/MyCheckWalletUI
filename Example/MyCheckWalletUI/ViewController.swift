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

    @IBOutlet weak var paymentMethodsBut: UIButton!
    var paymentMethods: Array<PaymentMethod>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        paymentMethodsBut.enabled = false
        MyCheckWallet.manager.login("eyJpdiI6IjhJcFBCZzBJWFRCdjhJdXA1ck9yeHc9PSIsInZhbHVlIjoiSHc3Ym5KUlVMRitRREtIN1ZnYnplUT09IiwibWFjIjoiNzFkYzM0ZDg5Y2M2NTk0NTg1ZjRiNTUyNDhhYmY2MTM5MGNlMTFjMTVjYjRjMTU5YzMwYzNiN2YxYzEwNDdiNyJ9", publishableKey: "pk_abc318RxSM2eyGa1Kvzp9uabGEefg", success: {
            self.paymentMethodsBut.enabled = true
            
            MyCheckWallet.manager.getPaymentMethods({ (array) in
                self.paymentMethods = array
                }, fail: { error in

            })
            } , fail: { error in
        
        })
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func managePaymentMethodsPressed(sender: AnyObject) {
     let controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: self.paymentMethods)
     self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension ViewController : MCPaymentMethodsViewControllerDelegate{
    func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    
    }

}

