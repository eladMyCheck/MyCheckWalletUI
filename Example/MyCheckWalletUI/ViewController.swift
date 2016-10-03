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
            
            MyCheckWallet.manager.getPaymentMethods({ (array) in
                self.paymentMethodsBut.enabled = true
                self.paymentMethods = array
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(containerView)
                NSLayoutConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .LeadingMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: containerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 0).active = true
                //NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .TopMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .BottomMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: containerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 200).active = true
                
                //containerView.backgroundColor = UIColor.redColor()
                // add child view controller view to container
                
                let controller = AddAndSelectCreditCardViewController.createAddAndSelectCreditCardViewController(self.paymentMethods)
                self.addChildViewController(controller)
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(controller.view)
                
                
                
                NSLayoutConstraint(item: controller.view, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .LeadingMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: controller.view, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .TrailingMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: controller.view, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .TopMargin, multiplier: 1.0, constant: 0).active = true
                NSLayoutConstraint(item: controller.view, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .BottomMargin, multiplier: 1.0, constant: 0).active = true
                
                controller.didMoveToParentViewController(self)
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

