//
//  MCPaymentMethodsViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
public protocol MCPaymentMethodsViewControllerDelegate {
    func userDismissed( controller: MCPaymentMethodsViewControllerDelegate)

    
}
public class MCPaymentMethodsViewController: MCViewController {
    var creditCardVC: MCAddCreditCardViewController?
    var delegate: MCPaymentMethodsViewControllerDelegate?
    
    @IBOutlet weak var outputForTesting: UILabel!
    @IBAction func addCreditCardPressed(sender: AnyObject) {
        showEnterCreditCard(true , animated: true)
    }
    @IBOutlet weak var creditCardInCenterConstraint: NSLayoutConstraint!
    
   public static func createPaymentMethodsViewController(delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
            
        controller.delegate = delegate
       
        return controller
    }
    
    //MARK: - lifeCycle
    
    public override func viewDidLoad(){
    super.viewDidLoad()
        showEnterCreditCard(false , animated: false)

        if let creditCardVC = creditCardVC{
            creditCardVC.delegate = self
        }
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "creditCardSubViewController" {
            creditCardVC = segue.destinationViewController as? MCAddCreditCardViewController
        }
    }

    //MARK: - private functions
    
    func showEnterCreditCard(show: Bool , animated: Bool){
        creditCardVC!.resetView()
        if animated{
        creditCardVC!.becomeFirstResponder()
        }else{
            creditCardVC!.resignFirstResponder()

        }
        creditCardInCenterConstraint.priority = show ? 999 : 1
        UIView.animateWithDuration(animated ? 0.4 : 0.0, animations: {
        self.view.layoutIfNeeded()
        })
    }
}

extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate{
    
    func recivedError(controller: MCAddCreditCardViewController , error:NSError){
    outputForTesting.text = error.localizedDescription
    }
    func addedNewPaymentMethod(controller: MCAddCreditCardViewController ,token:String){
    showEnterCreditCard(false , animated: true)
        outputForTesting.text = "credit card added"
    }
    func canceled(){
        showEnterCreditCard(false , animated: true)

    }
}
