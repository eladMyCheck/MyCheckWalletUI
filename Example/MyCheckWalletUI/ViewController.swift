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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func managePaymentMethodsPressed(sender: AnyObject) {
     let controller =  MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
    self.presentViewController(controller, animated: true, completion: nil)
    }
}

extension ViewController : MCPaymentMethodsViewControllerDelegate{
    func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    
    }

}

