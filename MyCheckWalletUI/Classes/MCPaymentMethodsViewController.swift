//
//  MCPaymentMethodsViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
///The protocol updates on important changes in MCPaymentMethodsViewController
public protocol MCPaymentMethodsViewControllerDelegate {
  ///Will be called whenever the view controller shoud be dismissed
  ///    - parameter controller: The controller calling for dismissal.

  func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController)
  
}
public class MCPaymentMethodsViewController: MCViewController {
  private var creditCardVC: MCAddCreditCardViewController?
  private var creditCardListVC: MCCreditCardsViewController?
  ///The delegate method that will be called when the View Controller is ready to be dismissed.
  var delegate: MCPaymentMethodsViewControllerDelegate?
  
  internal var paymentMethods: Array<PaymentMethod>!
  
  @IBOutlet private weak var creditCardListContainer: UIView!
  @IBOutlet private weak var addCreditCardContainer: UIView!
  @IBOutlet private weak var outputForTesting: UILabel!

  @IBOutlet private weak var creditCardInCenterConstraint: NSLayoutConstraint!
  @IBOutlet private weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
  @IBOutlet private weak var visaImageView: UIImageView!
  @IBOutlet private weak var mastercardImageView: UIImageView!
  @IBOutlet private weak var dinersImageView: UIImageView!
  @IBOutlet private weak var amexImageView: UIImageView!
  @IBOutlet private weak var discoverImageView: UIImageView!
 
  @IBAction func addCreditCardPressed(sender: AnyObject) {
    showEnterCreditCard(true , animated: true)
  }
  internal static func createPaymentMethodsViewController(delegate: MCPaymentMethodsViewControllerDelegate?, withPaymentMethods : Array<PaymentMethod>!) -> MCPaymentMethodsViewController
  {
    
    let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
    let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
    
    controller.delegate = delegate
    controller.paymentMethods = withPaymentMethods
    
    return controller
  }
  ///Create an instance of the manage payment methods page.
  ///    - parameter delegate: The delegate will be called when the View controller should be dismissed.
  ///    - Returns: An instance of MCPaymentMethodsViewController that is ready for display.
  
  public static func createPaymentMethodsViewController(delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController{
    let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
    let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
    
    controller.delegate = delegate
    controller.paymentMethods = MyCheckWallet.manager.methods
    
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
    self.assignImages()
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
    if creditCardListVC?.editMode == true {
      creditCardListVC?.editPressed(nil)
    }
    self.showEnterCreditCard(true, animated: true)
  }
  
  private func assignImages(){
    if let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/VI.png"){
      if let data = NSData(contentsOfURL: url){
        if let image = UIImage(data: data){
          visaImageView.image = image
        }
      }
    }
    
    if let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/MC.png"){
      if let data = NSData(contentsOfURL: url){
        if let image = UIImage(data: data){
          mastercardImageView.image = image
        }
      }
    }
    
    if let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DC.png"){
      if let data = NSData(contentsOfURL: url){
        if let image = UIImage(data: data){
          dinersImageView.image = image
        }
      }
    }
    
    if let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DS.png"){
      if let data = NSData(contentsOfURL: url){
        if let image = UIImage(data: data){
          discoverImageView.image = image
        }
      }
    }
    
    if let url = NSURL(string: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/AX.png"){
      if let data = NSData(contentsOfURL: url){
        if let image = UIImage(data: data){
          amexImageView.image = image
        }
      }
    }
    
  }
}


extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate, MCCreditCardsViewControllerrDelegate{
  
  func recivedError(controller: MCAddCreditCardViewController , error:NSError){
    outputForTesting.text = error.localizedDescription
  }
  func addedNewPaymentMethod(controller: MCAddCreditCardViewController ,token:String){
    MyCheckWallet.manager.getPaymentMethods({ (methods) in
      self.paymentMethods = methods
      self.creditCardListVC!.paymentMethods = methods
      self.creditCardListVC!.setCrediCards()
      self.showEnterCreditCard(false , animated: true)
      self.outputForTesting.text = "credit card added"
    }) { (error) in
      
    }
    
  }
  func canceled(){
    showEnterCreditCard(false , animated: true)
    
  }
  
  func backPressed() {
      print("payment methods vc dissmissed")
      self.delegate?.dismissedMCPaymentMethodsViewController(self)
    
  }
}
