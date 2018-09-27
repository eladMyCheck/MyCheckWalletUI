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
    @IBOutlet weak var factoryHolderStackView: UIStackView!
    @IBOutlet weak var pciLabel: UILabel!
    @IBOutlet fileprivate weak var creditCardListContainer: UIView!
    @IBOutlet fileprivate weak var addCreditCardContainer: UIView!
    
    @IBOutlet fileprivate weak var creditCardInCenterConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var creditCardsVCCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var walletsSeporator: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var addCardBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weAcceptSuperview: UIView!
    @IBOutlet weak var weAcceptSeperator: UIView!
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
    
    public static func createPaymentMethodsViewController(_ delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController?{
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
    
    func keyboardWillShow(notification:NSNotification){
        print("keyboard show")
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let kbHeight = keyboardFrame.size.height
        
        addCardBottomConstraint.constant = kbHeight + 16.0
    }
    
    func keyboardWillHide(notification:NSNotification){
        print("keyboard hide")
        addCardBottomConstraint.constant = 16.0
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
    
    func switchAddCardButton(on : Bool){
        if addCardButton.layer.cornerRadius != addCardButton.frame.height / 2 {
            addCardButton.layer.cornerRadius = addCardButton.frame.height / 2
        }
        addCardButton.isHidden = !on
        addCardButton.isEnabled = on
    }
    
    func switchAddCardButtonObserver(_ notification: NSNotification) {
        
        if let mode = notification.userInfo?["mode"] as? Bool {
            switchAddCardButton(on: mode)
        }
    }
    
    @IBAction func addCardPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name:  Notification.Name("add_card_button_pressed") , object: nil)
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle  {
        return LocalData.manager.getPaymentMethodsStatusBarColor()
    }
    //MARK: - actions
    
    
    @IBAction func doNotStorePressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    //MARK: - private functions
    
    func showEnterCreditCard(_ show: Bool , animated: Bool){
        // creditCardVC!.resetView()
        switchAddCardButton(on: show)
        if show{
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.switchAddCardButtonObserver(_:)), name: NSNotification.Name(rawValue: "add_card_switch_mode"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
            //
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            _ = creditCardVC!.becomeFirstResponder()
            
                self.navigationBar.popItem(animated: false)
            
            self.navigationBar.pushItem((creditCardVC?.getNavigationItem())!, animated: false)
            
            self.navigationBar.barStyle = .black
            self.navigationBar.barTintColor = .white
            self.navigationBar.tintColor = .black
        }else{
//            weAcceptSeperator.backgroundColor = self.addCreditCardContainer.backgroundColor
            _ = creditCardVC!.resignFirstResponder()
           self.navigationBar.popItem(animated: false)
            self.navigationBar.pushItem((creditCardListVC?.getNavigationItem())!, animated: false)
            
            self.navigationBar.barStyle = .default
            self.navigationBar.barTintColor = LocalData.manager.getColor("managePaymentMethodscolorsheaderBackground" , fallback: UIColor.clear)
            self.navigationBar.tintColor = LocalData.manager.getColor("managePaymentMethodscolorsbackButton" , fallback: UIColor(red:0.99, green:0.74, blue:0.18, alpha:1))
        }
        
        creditCardInCenterConstraint.priority = show ? 999 : 1
        creditCardsVCCenterXConstraint.priority = show ? 1 : 999
        UIView.animate(withDuration: animated ? 0.4 : 0.0, animations: {
            self.view.layoutIfNeeded()
            
            self.walletsSuperview.alpha = show ? 0.0 : 1.0
            self.doNotStoreCheckbox.superview?.alpha = show ? 0.0 : 1.0
            self.weAcceptSuperview.alpha = show ? 0.0 : 1.0
            self.weAcceptSeperator.alpha = show ? 0.0 : 1.0
            self.creditCardListVC!.scrollView.alpha = show ? 0 : 1
            
        })
    }
    
    func addCreditCardPressedNotificationReceived(_ notification: Notification){
        self.showEnterCreditCard(true, animated: true)
    }
    
    @objc fileprivate func receivedLogoutNotification(notification: NSNotification){
        self.paymentMethods = nil
        
        self.creditCardListVC!.paymentMethods = nil
        self.creditCardListVC!.setCreditCardsUI(false)
    }
    
    internal func setupUI(){
        
        creditCardListContainer.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorscardsListBackground", fallback: creditCardListContainer.backgroundColor!)
        
        weAcceptSeperator.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsseporator", fallback: creditCardListContainer.backgroundColor!)
        
        addCreditCardContainer.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsbackground", fallback: .white)
        
        addCardButton.setTitle( LocalData.manager.getString("addCreditapplyAddingCardButton" , fallback: self.addCardButton.titleLabel?.text ?? "") , for: UIControlState())
        addCardButton.setTitle( LocalData.manager.getString("addCreditapplyAddingCardButton" , fallback: self.addCardButton.titleLabel?.text ?? "") , for: .highlighted)
        addCardButton.backgroundColor = LocalData.manager.getColor("addCreditColorsapplyBackgroundColor", fallback: .black)
        
        addCardButton.setTitleColor(LocalData.manager.getColor("addCreditColorsapplyButtonText", fallback: UIColor(red:0.99, green:0.74, blue:0.18, alpha:1)), for: UIControlState())
        
        self.footerLabel.text = LocalData.manager.getString("managePaymentMethodscardAcceptedWallet" , fallback: self.footerLabel.text)
        self.footerLabel.font = UIFont.ragularFont(withSize: 14)
        self.walletHeaderLabel.text = LocalData.manager.getString("managePaymentMethodsothePaymentMethodsHeader" , fallback:  self.walletHeaderLabel.text)
        self.walletHeaderLabel.font = UIFont.ragularFont(withSize: 14)
        self.pciLabel.text = LocalData.manager.getString("addCreditpciNotice2" , fallback:  self.pciLabel.text)
        self.pciLabel.font = UIFont.ragularFont(withSize: 13)
        doNotStoreLabel.text = LocalData.manager.getString("managePaymentMethodsnotStoreCard" , fallback:doNotStoreLabel.text)
        doNotStoreLabel.font = UIFont.ragularFont(withSize: 14)
        
        view.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsbackground", fallback: UIColor.white)
        footerLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorsseporatorText" , fallback: footerLabel.textColor)
        walletHeaderLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorsseporatorText" , fallback: walletHeaderLabel.textColor)
        pciLabel.textColor = LocalData.manager.getColor("managePaymentMethodscolorspciNotice" , fallback: pciLabel.textColor)
        
        doNotStoreSuperview.isHidden = !LocalData.manager.doNotStoreEnabled()
        self.navigationBar.barTintColor = LocalData.manager.getColor("managePaymentMethodscolorsheaderBackground" , fallback: .black)
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = LocalData.manager.getColor("managePaymentMethodscolorsbackButton" , fallback: UIColor(red:0.99, green:0.74, blue:0.18, alpha:1))
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : LocalData.manager.getColor("managePaymentMethodscolorsheaderText" , fallback: .white),
            NSFontAttributeName: UIFont.headerFont(withSize: 14) 
        ]
    
    }
    
}

extension MCPaymentMethodsViewController : MCAddCreditCardViewControllerDelegate, MCCreditCardsViewControllerrDelegate{
    
    func recivedError(_ controller: MCAddCreditCardViewController , error:NSError){
    }
    func addedNewPaymentMethod(_ controller: MCAddCreditCardViewController ,token:String){
        refreshPaymentMethods(animated: true, completion: {success in
            
            self.showEnterCreditCard(false, animated: false)
        })
        
        
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
        weAcceptSuperview.addSubview(wrapper)
        
        var screenSize = UIScreen.main.bounds
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            if let topPadding = window?.safeAreaInsets.top , topPadding > 0{
                screenSize.size.height = 667.0
            }
        }
        
        let smallCardWidth = 37 / 375 * screenSize.width
        let smallCardHeight = 23 / 667 * screenSize.height
        let smallCardsMargin = smallCardHeight + smallCardWidth
        
        let horizontalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: weAcceptSuperview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 16)
        let verticalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: weAcceptSuperview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 8)
        let heightConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 26)
        let width = CGFloat(cardsImages.count) * smallCardsMargin
        let widthConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(width))
        weAcceptSuperview.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
        
        for card in cardsImages {
            let index = cardsImages.index(of: card)
            let iv = UIImageView(frame: CGRect(x:smallCardsMargin * CGFloat(index!), y: 0, width: smallCardWidth, height: smallCardHeight))
            iv.kf.setImage(with: URL(string: card))
            wrapper.addSubview(iv)
        }
    }
    
    
    func refreshPaymentMethods(animated: Bool, completion:(( Bool) -> Void)? = nil){
        
        Wallet.shared.getPaymentMethods(success: { (methods) in
            self.paymentMethods = methods
            self.creditCardListVC!.paymentMethods = methods
            self.creditCardListVC!.setCreditCardsUI(animated)
            if let completion = completion{
                completion(true)
            }
        }) { (error) in
            if let completion = completion{
                completion(false)
            }
        }
    }
    
    fileprivate func setWalletButtons(){
        switch Wallet.shared.factories.count {
        case 0:
            self.doNotStoreCheckbox.superview?.isHidden = true
            handleNoFactories()
        case 1...4:
            
            let verticalSpacing = (20 / 667) * self.view.frame.height
            let horizontalSpacing = (40 / 667) * self.view.frame.height
            
            //Stack View
            factoryHolderStackView.axis = .vertical
            factoryHolderStackView.spacing = verticalSpacing
            factoryHolderStackView.distribution = .fillEqually
            factoryHolderStackView.alignment = .center
            
            var firstRaw : [UIButton] = []
            var secondRaw : [UIButton] = []
            
            for (index,factory) in Wallet.shared.factories.enumerated(){
                let butRap = factory.getAddMethodButton(presenter: self)
                
                let button = butRap.button
                
                if index <= 1{
                    firstRaw.append(button)
                }else if index > 1{
                    secondRaw.append(button)
                }
            }
            
            let firstRowStackView = UIStackView(arrangedSubviews: firstRaw)
            if(firstRaw.count > 1){
                firstRowStackView.axis = .vertical
                firstRowStackView.spacing = horizontalSpacing
            }else{
                firstRowStackView.axis = .horizontal
                firstRowStackView.spacing = verticalSpacing
            }
            
            firstRowStackView.distribution = .fillEqually
            firstRowStackView.alignment = .center
            
            factoryHolderStackView.addArrangedSubview(firstRowStackView)
            
            for btn in firstRaw{
                let height = NSLayoutConstraint(item: btn,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: self.factoryHolderStackView,
                                                attribute: .height,
                                                multiplier: 0.35,
                                                constant: 0)
                let width = NSLayoutConstraint(item: btn,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: self.factoryHolderStackView,
                                               attribute: .width,
                                               multiplier: 0.35,
                                               constant: 0)
                
                self.view.addConstraints([height,width])
            }
            
            if secondRaw.count > 0 {
                factoryHolderStackView.distribution = .fillEqually
                factoryHolderStackView.alignment = .center
                
                firstRowStackView.axis = .horizontal
                
                let secondRowStackView = UIStackView(arrangedSubviews: secondRaw)
                secondRowStackView.axis = .horizontal
                secondRowStackView.distribution = .fillEqually
                secondRowStackView.alignment = .center
                secondRowStackView.spacing = horizontalSpacing
                
                factoryHolderStackView.addArrangedSubview(secondRowStackView)
                
                for btn in secondRaw{
                    let height = NSLayoutConstraint(item: btn,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: self.factoryHolderStackView,
                                                    attribute: .height,
                                                    multiplier: 0.35,
                                                    constant: 0)
                    let width = NSLayoutConstraint(item: btn,
                                                    attribute: .width,
                                                    relatedBy: .equal,
                                                    toItem: self.factoryHolderStackView,
                                                    attribute: .width,
                                                    multiplier: 0.35,
                                                    constant: 0)
                    
                    self.view.addConstraints([height,width])
                }
            }
            
            
            
        default:
            break;
        }
        
        walletsSuperview.layoutIfNeeded()
    }
    
    func handleNoFactories(){
        weAcceptSeperator.backgroundColor = self.view.backgroundColor
        walletsSuperview.isHidden = true
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

