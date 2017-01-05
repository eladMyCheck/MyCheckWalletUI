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
    func dismissedMCPaymentMethodsViewController(_ controller: MCPaymentMethodsViewController)
    
}

///A view controller that provides the user with the ability to add a payment method, set a default payment method and delete payment methods. The view controller is meant to be displayed modely.
open class MCPaymentMethodsViewController: MCViewController {
  @IBOutlet weak var activityInidicator: UIActivityIndicatorView!
    fileprivate var creditCardVC: MCAddCreditCardViewController?
    fileprivate var creditCardListVC: MCCreditCardsViewController?
    
    @IBOutlet weak var creditCardContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var walletsSuperview: UIView!
    ///The delegate method that will be called when the View Controller is ready to be dismissed.
    weak var delegate: MCPaymentMethodsViewControllerDelegate?
    
    internal var paymentMethods: Array<PaymentMethod>!
    @IBOutlet weak var doNotStoreCheckbox: UIButton!
    @IBOutlet weak var doNotStoreLabel: UILabel!
    
    @IBOutlet weak var walletHeaderLabel: UILabel!
    @IBOutlet weak var pciLabel: UILabel!
    @IBOutlet var seporators: [UIView]!
    @IBOutlet fileprivate weak var creditCardListContainer: UIView!
    @IBOutlet fileprivate weak var addCreditCardContainer: UIView!
    @IBOutlet fileprivate weak var outputForTesting: UILabel!
    
    @IBOutlet fileprivate weak var creditCardInCenterConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletsSeporator: UIView!
    
    @IBOutlet weak var weAcceptSuperview: UIView!
    @IBOutlet weak internal var titleLabel: UILabel!
    @IBOutlet weak internal var footerLabel: UILabel!
    @IBAction func addCreditCardPressed(_ sender: AnyObject) {
        showEnterCreditCard(true , animated: true)
    }
    internal static func createPaymentMethodsView (_ delegate: MCPaymentMethodsViewControllerDelegate?, withPaymentMethods : Array<PaymentMethod>!) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  Bundle(for: self.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: "MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        controller.paymentMethods = withPaymentMethods
        
        return controller
    }
    ///Create an instance of the manage payment methods page.
    ///
    ///   - parameter delegate: The delegate will be called when the View controller should be dismissed.
    ///    - returns: An instance of MCPaymentMethodsViewController that is ready for display.
    
    open static func createPaymentMethodsViewController(_ delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController{
        let storyboard = MCViewController.getStoryboard(  Bundle(for: self.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: "MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        controller.paymentMethods = MyCheckWallet.manager.methods
        
        return controller
    }
    
    //MARK: - lifeCycle
    
    open override func viewDidLoad(){
        super.viewDidLoad()
      activityInidicator.stopAnimating();
      //setting up UI and updating it if the user logges in... just incase
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MCAddCreditCardViewController.setupUI), name: NSNotification.Name(rawValue: MyCheckWallet.loggedInNotification), object: nil)
        setupUI()
        
        //recieving events from all intergrated sdks
        showEnterCreditCard(false , animated: false)
        
        if let creditCardVC = creditCardVC{
            creditCardVC.delegate = self
        }
        
        if let creditCardListVC = creditCardListVC {
            creditCardListVC.delegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(MCPaymentMethodsViewController.addCreditCardPressedNotificationReceived(_:)), name:NSNotification.Name(rawValue: "AddCreditCardPressed"), object: nil)
        self.assignImages()
        
        setWalletButtons()
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyCheckWallet.manager.factoryDelegate = self
doNotStoreCheckbox.isSelected = false
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "creditCardSubViewController" {
            creditCardVC = segue.destination as? MCAddCreditCardViewController
            creditCardVC?.containerHeight = creditCardContainerHeight
        }else if segue.identifier == "creditCardsViewController"{
            creditCardListVC = segue.destination as? MCCreditCardsViewController
            creditCardListVC!.paymentMethods = self.paymentMethods
        }
    }
    //MARK: - actions
    
   
    @IBAction func doNotStorePressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    //MARK: - private functions
    
    func showEnterCreditCard(_ show: Bool , animated: Bool){
        creditCardVC!.resetView()
        if show{
            creditCardVC!.becomeFirstResponder()
        }else{
            creditCardVC!.resignFirstResponder()
            
        }
        creditCardInCenterConstraint.priority = show ? 999 : 1
        creditCardsVCCenterXConstraint.priority = show ? 1 : 999
        UIView.animate(withDuration: animated ? 0.4 : 0.0, animations: {
            self.view.layoutIfNeeded()
            self.walletsSuperview.alpha = show ? 0.0 : 1.0
            self.doNotStoreCheckbox.superview?.alpha = show ? 0.0 : 1.0
            self.weAcceptSuperview.alpha = show ? 0.0 : 1.0
            self.walletsSeporator.alpha = show ? 0.0 : 1.0
            self.creditCardListVC!.scrollView.alpha = show ? 0 : 1
            
        })
    }
    
    func addCreditCardPressedNotificationReceived(_ notification: Notification){
        if creditCardListVC?.editMode == true {
            creditCardListVC?.editPressed((creditCardListVC?.editButton)!)
        }
        self.showEnterCreditCard(true, animated: true)
    }
    
    fileprivate func assignImages(){
        let cardsImages = LocalData.manager.getArray("acceptedCardsPM")
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        weAcceptSuperview.addSubview(wrapper)
        
        let horizontalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: weAcceptSuperview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: weAcceptSuperview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 42)
        let heightConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 26)
        let width = cardsImages.count*48
        let widthConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(width))
            weAcceptSuperview.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
        
        for card in cardsImages {
            let index = cardsImages.index(of: card)
            let iv = UIImageView(frame: CGRect(x: 48*index!+5, y: 0, width: 38, height: 24))
            iv.kf.setImage(with: URL(string: card))
            wrapper.addSubview(iv)
        }
    }
    
    internal func setupUI(){
        titleLabel.text = LocalData.manager.getString("managePaymentMethodsheader" , fallback: titleLabel.text)
        self.footerLabel.text = LocalData.manager.getString("managePaymentMethodscardAcceptedWallet" , fallback: self.footerLabel.text)
        doNotStoreLabel.text = LocalData.manager.getString("managePaymentMethodsnotStoreCard" , fallback:doNotStoreLabel.text)
        //setting up colors
        view.backgroundColor = LocalData.manager.getColor("managePaymentMethodsColorsbackground", fallback: UIColor.white)
        for seporator in seporators{
            seporator.backgroundColor = LocalData.manager.getColor("managePaymentMethodsColorsseporator", fallback: seporator.backgroundColor!)
        }
        footerLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorsseporatorText" , fallback: footerLabel.textColor)
        walletHeaderLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorsseporatorText" , fallback: walletHeaderLabel.textColor)
        pciLabel.textColor = LocalData.manager.getColor("managePaymentMethodsColorspciNotice" , fallback: pciLabel.textColor)

    }
    
    
    fileprivate func setWalletButtons(){
        
        walletsSeporator.isHidden = MyCheckWallet.manager.factories.count == 0
        for factory in MyCheckWallet.manager.factories{
            
            let  but = factory.getAddMethodButton()
            self.walletsSuperview.addSubview(but)
            but.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            walletsSuperview.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16)
            walletsSuperview.addConstraint(verticalConstraint)
            
        }
    }
    
}


extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate, MCCreditCardsViewControllerrDelegate{
    
    func recivedError(_ controller: MCAddCreditCardViewController , error:NSError){
        outputForTesting.text = error.localizedDescription
    }
    func addedNewPaymentMethod(_ controller: MCAddCreditCardViewController ,token:String){
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
    internal func shouldBeSingleUse(_ controller: PaymentMethodFactory) -> Bool {
        return doNotStoreCheckbox.isSelected
    }
    func error(_ controller: PaymentMethodFactory , error:NSError){
        printIfDebug( error.localizedDescription )
        
        let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert);
        let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .default, handler:
            {(alert: UIAlertAction!) in
                
                
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addedPaymentMethod(_ controller: PaymentMethodFactory ,token:String){
        if let creditCardListVC = creditCardListVC{
            creditCardListVC.reloadMethods()
            self.showEnterCreditCard(false , animated: true)

        }
    }
    func displayViewController(_ controller: UIViewController ){
        self.present(controller, animated: true, completion: nil)
    }
    
    func dismissViewController(_ controller: UIViewController ){
        controller.dismiss(animated: true, completion: nil)
    }
  func showLoadingIndicator(_ controller: PaymentMethodFactory, show: Bool) {
    show ? activityInidicator.startAnimating() : activityInidicator.stopAnimating()
    self.view.isUserInteractionEnabled = !show

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


