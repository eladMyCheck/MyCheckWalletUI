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
        MyCheckWallet.manager.login("eyJpdiI6IjhJcFBCZzBJWFRCdjhJdXA1ck9yeHc9PSIsInZhbHVlIjoiSHc3Ym5KUlVMRitRREtIN1ZnYnplUT09IiwibWFjIjoiNzFkYzM0ZDg5Y2M2NTk0NTg1ZjRiNTUyNDhhYmY2MTM5MGNlMTFjMTVjYjRjMTU5YzMwYzNiN2YxYzEwNDdiNyJ9", publishableKey: "pk_abc318RxSM2eyGa1Kvzp9uabGEefg", success: {
            
            MyCheckWallet.manager.getPaymentMethods({ (array) in
                _ = MCContainerView(controller: self, withPaymentMethods: array)
                }, fail: { error in

            })
            } , fail: { error in
        
        })
        

    }
}

extension ViewController : MCPaymentMethodsViewControllerDelegate{
    func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    
    }

}

