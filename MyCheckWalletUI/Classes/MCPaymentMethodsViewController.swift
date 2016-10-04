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
    var creditCardListVC: MCCreditCardsViewController?
    var delegate: MCPaymentMethodsViewControllerDelegate?
    public var paymentMethods: Array<PaymentMethod>!
    
    @IBOutlet weak var creditCardListContainer: UIView!
    @IBOutlet weak var addCreditCardContainer: UIView!
    @IBOutlet weak var outputForTesting: UILabel!
    @IBAction func addCreditCardPressed(sender: AnyObject) {
        showEnterCreditCard(true , animated: true)
    }
    @IBOutlet weak var creditCardInCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
    
    public static func createPaymentMethodsViewController(delegate: MCPaymentMethodsViewControllerDelegate?, withPaymentMethods : Array<PaymentMethod>!) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
            
        controller.delegate = delegate
        controller.paymentMethods = withPaymentMethods
        
        return controller
    }
    
    //MARK: - lifeCycle
    
    public override func viewDidLoad(){
    super.viewDidLoad()
        showEnterCreditCard(false , animated: false)

        if let creditCardVC = creditCardVC{
            creditCardVC.delegate = self
        }
        
        if let creditCardListVC = creditCardListVC {
            creditCardListVC.delegate = self
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MCPaymentMethodsViewController.addCreditCardPressedNotificationReceived(_:)), name:"AddCreditCardPressed", object: nil)
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "creditCardSubViewController" {
            creditCardVC = segue.destinationViewController as? MCAddCreditCardViewController
        }else if segue.identifier == "creditCardsViewController"{
            creditCardListVC = segue.destinationViewController as? MCCreditCardsViewController
            creditCardListVC!.paymentMethods = self.paymentMethods
        }
    }

    //MARK: - private functions
    
    func showEnterCreditCard(show: Bool , animated: Bool){
        creditCardVC!.resetView()
        if show{
        creditCardVC!.becomeFirstResponder()
        }else{
            creditCardVC!.resignFirstResponder()

        }
        creditCardInCenterConstraint.priority = show ? 999 : 1
        creditCardsVCCenterXConstraint.priority = show ? 1 : 999
        UIView.animateWithDuration(animated ? 0.4 : 0.0, animations: {
        self.view.layoutIfNeeded()
        })
    }
    
     func addCreditCardPressedNotificationReceived(notification: NSNotification){
        self.showEnterCreditCard(true, animated: true)
    }
}


extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate, MCCreditCardsViewControllerrDelegate{
    
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
    
    func backPressed() {
        self.dismissViewControllerAnimated(true) { 
            print("payment methods vc dissmissed")
        }
    }
}
