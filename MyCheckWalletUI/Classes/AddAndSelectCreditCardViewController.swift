//
//  AddAndSelectCreditCardViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit

public class AddAndSelectCreditCardViewController: MCAddCreditCardViewController {

    @IBOutlet weak var managePaymentMethodsButton: UIButton!
    public var paymentMethods: Array<PaymentMethod>!
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func managePaymentMethodsButtonPressed(_ sender: UIButton) {
        let controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: self.paymentMethods)
        self.presentViewController(controller, animated: true, completion: nil)
    }

    public static func createAddAndSelectCreditCardViewController(withPaymentMethods : Array<PaymentMethod>!) -> AddAndSelectCreditCardViewController{
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("AddAndSelectCreditCardViewController") as! AddAndSelectCreditCardViewController
        controller.paymentMethods = withPaymentMethods
        //controller.delegate = delegate
        
        return controller
    }

}

extension AddAndSelectCreditCardViewController : MCPaymentMethodsViewControllerDelegate{
    public func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    }
}
