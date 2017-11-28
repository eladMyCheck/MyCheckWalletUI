//
//  MCPaymentMethodsViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
import MyCheckCore

//The contained views have navigation items and this is how we get them in order to exchange the items in the navigation bar
internal protocol navigationItemHasViewController{
func getNavigationItem() -> UINavigationItem
}


///The protocol updates on important changes in MCPaymentMethodsViewController
public protocol MCPaymentMethodsViewControllerDelegate : class{
    
    ///Will be called whenever the view controller shoud be dismissed
    ///    - parameter controller: The controller calling for dismissal.
    func dismissedMCPaymentMethodsViewController(_ controller: MCPaymentMethodsViewController)
    
}

///A view controller that provides the user with the ability to add a payment method, set a default payment method and delete payment methods. The view controller is meant to be displayed modely.
open class MCPaymentMethodsViewController: MCViewController {
    
    @IBOutlet weak var doNotStoreSuperview: UIView!
    @IBOutlet weak var activityInidicator: UIActivityIndicatorView!
    fileprivate var creditCardVC: MCAddCreditCardViewController?
    fileprivate var creditCardListVC: MCCreditCardsViewController?
    
    @IBOutlet weak var creditCardContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var walletsSuperview: UIView!
    ///The delegate method that will be called when the View Controller is ready to be dismissed.
    weak var delegate: MCPaymentMethodsViewControllerDelegate?
    
    internal var paymentMethods: Array<PaymentMethodInterface>!
    @IBOutlet weak var doNotStoreCheckbox: UIButton!
    @IBOutlet weak var doNotStoreLabel: UILabel!
    
    @IBOutlet weak var walletHeaderLabel: UILabel!
    @IBOutlet weak var pciLabel: UILabel!
    @IBOutlet var seporators: [UIView]!
    @IBOutlet fileprivate weak var creditCardListContainer: UIView!
    @IBOutlet fileprivate weak var addCreditCardContainer: UIView!
    
    @IBOutlet fileprivate weak var creditCardInCenterConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletsSeporator: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var weAcceptSuperview: UIView!
    @IBOutlet weak var acceptedCards: UIView!
    @IBOutlet weak internal var footerLabel: UILabel!
    @IBAction func addCreditCardPressed(_ sender: AnyObject) {
        showEnterCreditCard(true , animated: true)
    }
    internal static func createPaymentMethodsView (_ delegate: MCPaymentMethodsViewControllerDelegate?, withPaymentMethods : Array<PaymentMethodInterface>!) -> MCPaymentMethodsViewController
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
    ///    - returns: An instance of MCPaymentMethodsViewController that is ready for display or nil if the user is not logged in.
    
    open static func createPaymentMethodsViewController(_ delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController?{
        if !Session.shared.isLoggedIn(){
            return nil
        }
        let storyboard = MCViewController.getStoryboard(  Bundle(for: self.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: "MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        controller.paymentMethods = Wallet.shared.methods
        
        return controller
    }
    
    //MARK: - lifeCycle
    
    open override func viewDidLoad(){
        super.viewDidLoad()
        activityInidicator.stopAnimating();
        //setting up UI and updating it if the user logges in... just incase
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MCAddCreditCardViewController.setupUI), name: NSNotification.Name(rawValue: Session.Const.loggedInNotification), object: nil)
        nc.addObserver(self, selector: #selector(MCPaymentMethodsViewController.receivedLogoutNotification), name: NSNotification.Name(rawValue: Session.Const.loggedOutNotification), object: nil)

        Wallet.shared.configureWallet(success: {
    self.setupUI()
    let str =  LocalData.manager.getString("managePaymentMethodsothePaymentMethodsHeader" , fallback:  self.walletHeaderLabel.text)
print(str)
}, fail: nil)
        
        navigationBar.delegate = self
        
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
        refreshPaymentMethods(animated:  false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Wallet.shared.factoryDelegate = self
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
        // creditCardVC!.resetView()
        if show{
            _ = creditCardVC!.becomeFirstResponder()
            
                self.navigationBar.popItem(animated: false)

            
            self.navigationBar.pushItem((creditCardVC?.getNavigationItem())!, animated: false)
        }else{
            _ = creditCardVC!.resignFirstResponder()
           self.navigationBar.popItem(animated: false)
            self.navigationBar.pushItem((creditCardListVC?.getNavigationItem())!, animated: false)

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
//            creditCardListVC?.editPressed((creditCardListVC?.editButton)!)
        }
        self.showEnterCreditCard(true, animated: true)
    }
    
    @objc fileprivate func receivedLogoutNotification(notification: NSNotification){
        self.paymentMethods = nil
        
        self.creditCardListVC!.paymentMethods = nil
        self.creditCardListVC!.setCreditCardsUI(false)
    }
    
    internal func setupUI(){
        
        self.footerLabel.text = LocalData.manager.getString("managePaymentMethodscardAcceptedWallet" , fallback: self.footerLabel.text)
      self.walletHeaderLabel.text = LocalData.manager.getString("managePaymentMethodsothePaymentMethodsHeader" , fallback:  self.walletHeaderLabel.text)
      self.pciLabel.text = LocalData.manager.getString("addCreditpciNotice2" , fallback:  self.pciLabel.text)

      
        doNotStoreLabel.text = LocalData.manager.getString("managePaymentMethodsnotStoreCard" , fallback:doNotStoreLabel.text)
        //setting up colors
        view.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsbackground", fallback: UIColor.white)
        for seporator in seporators{
            seporator.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsseporator", fallback: seporator.backgroundColor!)
        }
        footerLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorsseporatorText" , fallback: footerLabel.textColor)
        walletHeaderLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorsseporatorText" , fallback: walletHeaderLabel.textColor)
        pciLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorspciNotice" , fallback: pciLabel.textColor)
        
        doNotStoreSuperview.isHidden = !LocalData.manager.doNotStoreEnabled()
self.navigationBar.barTintColor = LocalData.manager.getColor("managePaymentMethodscolorsheaderBackground" , fallback: UIColor.clear)
        
        self.navigationBar.tintColor = LocalData.manager.getColor("managePaymentMethodscolorseditButtonText" , fallback: UIColor.white)
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : LocalData.manager.getColor("managePaymentMethodscolorsheaderText" , fallback: UIColor.white),
            NSFontAttributeName: UIFont.headerFont(withSize: 18)
        ]
    
    }
    
    
    
}

extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate, MCCreditCardsViewControllerrDelegate{
    
    func recivedError(_ controller: MCAddCreditCardViewController , error:NSError){
    }
    func addedNewPaymentMethod(_ controller: MCAddCreditCardViewController ,token:String){
        refreshPaymentMethods(animated: true)
        
        
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
    
    func addedPaymentMethod(_ controller: PaymentMethodFactory ,method:PaymentMethodInterface , message:String?){
        
        if let creditCardListVC = creditCardListVC{
            creditCardListVC.reloadMethods()
            self.showEnterCreditCard(false , animated: true)
            
        }
        
        if let message = message{
            self.showToast(message: message)
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

fileprivate extension MCPaymentMethodsViewController{
    
    
    fileprivate func assignImages(){
        let cardsImages = LocalData.manager.getArray("acceptedCardsPM")
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        acceptedCards.addSubview(wrapper)
        
        let horizontalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: acceptedCards, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: acceptedCards, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let verticalConstraint2 = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: acceptedCards, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let width = cardsImages.count*48
        let widthConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(width))
        acceptedCards.addConstraints([horizontalConstraint, verticalConstraint, verticalConstraint2, widthConstraint])
        
        for card in cardsImages {
            let index = cardsImages.index(of: card)
            let iv = UIImageView(frame: CGRect(x: 48*index!+5, y: 0, width: 38, height: Int( acceptedCards.frame.size.height)))
            iv.contentMode = .scaleAspectFit
            iv.kf.setImage(with: URL(string: card))
            wrapper.addSubview(iv)
        }
    }
    
    
    func refreshPaymentMethods(animated: Bool){
        
        Wallet.shared.getPaymentMethods(success: { (methods) in
            self.paymentMethods = methods
            self.creditCardListVC!.paymentMethods = methods
            self.creditCardListVC!.setCreditCardsUI(animated)
            self.showEnterCreditCard(false , animated: animated)
        }) { (error) in
            
        }
    }
    fileprivate func setWalletButtons(){
        switch Wallet.shared.factories.count {
        case 0:
            self.doNotStoreCheckbox.superview?.isHidden = true
        case 1:
            let factory = Wallet.shared.factories[0]
            let  butRap = factory.getAddMethodButton()
            self.walletsSuperview.addSubview(butRap.button)
            butRap.button.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalConstraint = NSLayoutConstraint(item: butRap.button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            walletsSuperview.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: butRap.button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16)
            walletsSuperview.addConstraint(verticalConstraint)
            
            if let image = butRap.button.backgroundImage(for: .normal) , image.size.width != 0{
                let ratio = image.size.height / image.size.width
                
                let aspectRationConstraint = NSLayoutConstraint(item: butRap.button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: butRap.button, attribute: NSLayoutAttribute.width, multiplier: ratio, constant: 0)
                walletsSuperview.addConstraint(aspectRationConstraint)
            }
            let widthConstraint = NSLayoutConstraint(item: butRap.button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.width, multiplier: 0.415625, constant: 0)
            walletsSuperview.addConstraint(widthConstraint)
        case 2...4:
            var buttons : [UIButton] = []
            for (index,factory) in Wallet.shared.factories.enumerated(){
                
                let  butRap = factory.getAddMethodButton()
                buttons.append( butRap.button)
                self.walletsSuperview.addSubview(butRap.button)
                
                addVerticalConstraintsToWalletButton(buttonRapper: butRap , bellow: index > 1 ? buttons[index - 2] : nil)
                
                addAspectRationConstraintsToWalletButton(buttonRapper: butRap)
                addWidthConstraintsToWalletButton(buttonRapper: butRap)
            }
            
            let  but1 = buttons[0]
            let  but2 = buttons[1]
            let margin = 20//0.0845410628 * walletsSuperview.frame.size.width;
            
            let constraint1Str = "H:|-(\(margin))-[but1]"
            let constraint2Str = "H:[but2]-(\(margin))-|"
            
            walletsSuperview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint1Str, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["but1":but1]))
            
            walletsSuperview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint2Str, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["but2":but2]))
            
            if buttons.count == 3 {
                let  but3 = buttons[2]
                walletsSuperview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(margin))-[but1]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["but1":but3]))
                
                
            }
            
            if buttons.count == 4 {
                let  but2 = buttons[2]
                let  but3 = buttons[3]
                walletsSuperview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint1Str, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["but1":but2]))
                
                walletsSuperview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: constraint2Str, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["but2":but3]))

            }
            
            
            
        default:
            break;
        }
        walletsSuperview.layoutIfNeeded()
        
            walletsSeporator.isHidden = Wallet.shared.factories.count == 0

    }
    
    func addAspectRationConstraintsToWalletButton(buttonRapper: PaymentMethodButtonRapper){
        //button aspect ration should have the images ration
        if let image = buttonRapper.button.backgroundImage(for: .normal) , image.size.width != 0{
            let ratio = image.size.height / image.size.width
            
            let aspectRationConstraint = NSLayoutConstraint(item: buttonRapper.button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: buttonRapper.button, attribute: NSLayoutAttribute.width, multiplier: ratio, constant: 0)
            walletsSuperview.addConstraint(aspectRationConstraint)
        }
    }
    
    func addWidthConstraintsToWalletButton(buttonRapper: PaymentMethodButtonRapper){
        //the width will hold its prepotion for all device sizes
        let widthConstraint = NSLayoutConstraint(item: buttonRapper.button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: walletsSuperview, attribute: NSLayoutAttribute.width, multiplier: 0.415625, constant: 0)
        walletsSuperview.addConstraint(widthConstraint)
        
    }
    func addVerticalConstraintsToWalletButton(buttonRapper: PaymentMethodButtonRapper , bellow: UIView? = nil){
        
        let getVerticalConstraint: () -> NSLayoutConstraint = {
            if let bellow = bellow{
           return NSLayoutConstraint(item: buttonRapper.button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: bellow, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 16)
            }else{
         return   NSLayoutConstraint(item: buttonRapper.button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.walletsSuperview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16)
            }
        }
            
            
        
        walletsSuperview.addConstraint(getVerticalConstraint())
        
        
        buttonRapper.button.translatesAutoresizingMaskIntoConstraints = false
        
        
        
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

extension MCPaymentMethodsViewController: UINavigationBarDelegate{
    public func position(for bar: UIBarPositioning) -> UIBarPosition{
    return .topAttached
    }
 }

