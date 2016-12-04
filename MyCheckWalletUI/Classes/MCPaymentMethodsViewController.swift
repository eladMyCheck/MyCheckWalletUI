//
//  MCPaymentMethodsViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit

///The protocol updates on important changes in MCPaymentMethodsViewController
public protocol MCPaymentMethodsViewControllerDelegate : class{
    
    ///Will be called whenever the view controller shoud be dismissed
    ///    - parameter controller: The controller calling for dismissal.
    func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController)
    
}

///A view controller that provides the user with the ability to add a payment method, set a default payment method and delete payment methods. The view controller is meant to be displayed modely.
public class MCPaymentMethodsViewController: MCViewController {
  @IBOutlet weak var activityInidicator: UIActivityIndicatorView!
    private var creditCardVC: MCAddCreditCardViewController?
    private var creditCardListVC: MCCreditCardsViewController?
    
    @IBOutlet weak var walletsSuperview: UIView!
    ///The delegate method that will be called when the View Controller is ready to be dismissed.
    weak var delegate: MCPaymentMethodsViewControllerDelegate?
    
    internal var paymentMethods: Array<PaymentMethod>!
    
    @IBOutlet weak var walletHeaderLabel: UILabel!
    @IBOutlet weak var pciLabel: UILabel!
    @IBOutlet var seporators: [UIView]!
    @IBOutlet private weak var creditCardListContainer: UIView!
    @IBOutlet private weak var addCreditCardContainer: UIView!
    @IBOutlet private weak var outputForTesting: UILabel!
    
    @IBOutlet private weak var creditCardInCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletsSeporator: UIView!
    @IBOutlet private weak var visaImageView: UIImageView!
    @IBOutlet private weak var mastercardImageView: UIImageView!
    @IBOutlet private weak var dinersImageView: UIImageView!
    @IBOutlet private weak var amexImageView: UIImageView!
    @IBOutlet private weak var discoverImageView: UIImageView!
    
    @IBOutlet weak internal var titleLabel: UILabel!
    @IBOutlet weak internal var footerLabel: UILabel!
    @IBAction func addCreditCardPressed(sender: AnyObject) {
        showEnterCreditCard(true , animated: true)
    }
    internal static func createPaymentMethodsView (delegate: MCPaymentMethodsViewControllerDelegate?, withPaymentMethods : Array<PaymentMethod>!) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        controller.paymentMethods = withPaymentMethods
        
        return controller
    }
    ///Create an instance of the manage payment methods page.
    ///
    ///   - parameter delegate: The delegate will be called when the View controller should be dismissed.
    ///    - returns: An instance of MCPaymentMethodsViewController that is ready for display.
    
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
      activityInidicator.stopAnimating();
      //setting up UI and updating it if the user logges in... just incase
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(MCAddCreditCardViewController.setupUI), name: MyCheckWallet.loggedInNotification, object: nil)
        setupUI()
        
        //recieving events from all intergrated sdks
        showEnterCreditCard(false , animated: false)
        
        if let creditCardVC = creditCardVC{
            creditCardVC.delegate = self
        }
        
        if let creditCardListVC = creditCardListVC {
            creditCardListVC.delegate = self
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MCPaymentMethodsViewController.addCreditCardPressedNotificationReceived(_:)), name:"AddCreditCardPressed", object: nil)
        self.assignImages()
        
        setWalletButtons()
        
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MyCheckWallet.manager.factoryDelegate = self

    }
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "creditCardSubViewController" {
            creditCardVC = segue.destinationViewController as? MCAddCreditCardViewController
        }else if segue.identifier == "creditCardsViewController"{
            creditCardListVC = segue.destinationViewController as? MCCreditCardsViewController
            creditCardListVC!.paymentMethods = self.paymentMethods
        }
    }
    //MARK: - actions
    
   
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
            self.creditCardListVC!.scrollView.alpha = show ? 0 : 1
            
        })
    }
    
    func addCreditCardPressedNotificationReceived(notification: NSNotification){
        if creditCardListVC?.editMode == true {
            creditCardListVC?.editPressed((creditCardListVC?.editButton)!)
        }
        self.showEnterCreditCard(true, animated: true)
    }
    
    private func assignImages(){
        visaImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsvisa" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/VI.png"))))
        mastercardImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsmastercard" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/MC.png"))))
        dinersImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsdinersclub" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DC.png"))))
        discoverImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsdiscover" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DS.png"))))
        amexImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsAMEX" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/AX.png"))))
    }
    
    internal func setupUI(){
        titleLabel.text = LocalData.manager.getString("managePaymentMethodsheader" , fallback: titleLabel.text)
        self.footerLabel.text = LocalData.manager.getString("managePaymentMethodscardAcceptedWallet" , fallback: self.footerLabel.text)
        
        //setting up colors
        view.backgroundColor = LocalData.manager.getColor("managePaymentMethodsColorsbackground", fallback: UIColor.whiteColor())
        for seporator in seporators{
            seporator.backgroundColor = LocalData.manager.getColor("managePaymentMethodsColorsseporator", fallback: seporator.backgroundColor!)
        }
        footerLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorsseporatorText" , fallback: footerLabel.textColor)
        walletHeaderLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorsseporatorText" , fallback: walletHeaderLabel.textColor)
        pciLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorspciNotice" , fallback: pciLabel.textColor)

    }
    
    
    private func setWalletButtons(){
        
        walletsSeporator.hidden = MyCheckWallet.manager.factories.count == 0
        for factory in MyCheckWallet.manager.factories{
            
            let  but = factory.getAddMethodButton()
            self.walletsSuperview.addSubview(but)
            but.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            walletsSuperview.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            walletsSuperview.addConstraint(verticalConstraint)
            
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
            self.creditCardListVC!.setCreditCardsUI(true)
            self.showEnterCreditCard(false , animated: true)
            self.outputForTesting.text = "credit card added"
        }) { (error) in
            
        }
        
    }
    func canceled(){
        showEnterCreditCard(false , animated: true)
        
    }
    
    func backPressed() {
        printIfDebug("payment methods vc dissmissed")
        self.delegate?.dismissedMCPaymentMethodsViewController(self)
        
    }
    
}
extension MCPaymentMethodsViewController : PaymentMethodFactoryDelegate{
    func error(controller: PaymentMethodFactory , error:NSError){
        printIfDebug( error.localizedDescription )
        
        let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .Alert);
        let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .Default, handler:
            {(alert: UIAlertAction!) in
                
                
        })
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addedPaymentMethod(controller: PaymentMethodFactory ,token:String){
        if let creditCardListVC = creditCardListVC{
            creditCardListVC.reloadMethods()
            self.showEnterCreditCard(false , animated: true)

        }
    }
    func displayViewController(controller: UIViewController ){
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func dismissViewController(controller: UIViewController ){
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
  func showLoadingIndicator(controller: PaymentMethodFactory, show: Bool) {
    show ? activityInidicator.startAnimating() : activityInidicator.stopAnimating()
  
  }
    
}
//extension MCPaymentMethodsViewController : BTViewControllerPresentingDelegate{
//    public func paymentDriver(driver: AnyObject, requestsDismissalOfViewController viewController: UIViewController) {
//        viewController.dismissViewControllerAnimated(true, completion: nil)
//    }
//    public func paymentDriver(driver: AnyObject, requestsPresentationOfViewController viewController: UIViewController){
//    self.presentViewController(viewController, animated: true, completion: nil)
//    }
//    
//}


