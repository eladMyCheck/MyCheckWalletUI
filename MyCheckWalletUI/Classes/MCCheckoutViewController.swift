//
//  MCCheckoutViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit

///The parent of the MCCheckoutViewController must adopt this protocol and implement its methods in order to be able to resize the view when needed. The View will not automatically resize since it might be used in a few different ways (e.g constraints might be broken), so it is your responsibility to respond to the delegate and resize the view appropriately.
public protocol CheckoutDelegate{
    
    ///Called when the height is changed
    ///   - parameter newHight: The new height of the CheckoutView/CheckoutTableViewCell
    ///   - parameter animationDuration: The duration the animation will take. The animation will start directly after this call is pressed. You should resize the view imidiatly and use the same animation duration in order for the animation to look good
    func checkoutViewShouldResizeHeight(newHeight : Float , animationDuration: Double)
    
}
///A view controller that provides the ability to add a credit card and or select a payment method. The view controller is meant to be used as part of a parent view controller using a container view.
public class MCCheckoutViewController: MCAddCreditCardViewController {
    //variables
    
    /// This variable will always have the currant payment method selected by the user. In the case where the user doesn't have a payment method the variable will be nil.
    public var selectedMethod : PaymentMethod?
    
    ///The delegate that will be updated with MCCheckoutViewController height changes
    public var checkoutDelegate : CheckoutDelegate?
    
    //Outlets
    @IBOutlet weak private  var paymentSelectorView: UIView!
    @IBOutlet weak  private  var acceptedCreditCardsViewTopToCreditCardFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptedCreditCardsViewTopToCollapsableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var checkbox: UIButton!
    @IBOutlet weak private var paymentMethodSelectorTextField: UITextField!
    @IBOutlet weak private var colapsableContainer: UIView!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet private var textFieldsBorderViews: [UIView]!
    @IBOutlet weak private var managePaymentMethodsButton: UIButton!
    var paymentMethodSelector : UIPickerView = UIPickerView()
    private var paymentMethods: Array<PaymentMethod>! = []
    
    @IBOutlet weak private var visaImageView: UIImageView!
    @IBOutlet weak private var mastercardImageView: UIImageView!
    @IBOutlet weak private var dinersImageView: UIImageView!
    @IBOutlet weak private var amexImageView: UIImageView!
    @IBOutlet weak private var discoverImageView: UIImageView!
    @IBOutlet weak private var checkBoxLabel: UILabel!
    @IBOutlet weak private var creditCardBorderView: UIView!
    @IBOutlet weak private var dateFieldBorderView: UIView!
    @IBOutlet weak private var cvvBorderView: UIView!
    @IBOutlet weak private var zipFieldBorderView: UIView!
    
    @IBOutlet weak private var header: UILabel!
    @IBOutlet weak private var dropdownHeader: UILabel!
    @IBOutlet weak private var footerLabel: UILabel!
    
    @IBOutlet weak var headerLineBG: UIView!
    @IBOutlet weak var pickerDownArrow: UIImageView!
    
    //3rd party wallet payment methods UI elements
    @IBOutlet weak var walletsSuperview: UIView!
    @IBOutlet weak var walletsHeight: NSLayoutConstraint!
    @IBOutlet weak var walletButsContainer: UIView!
    
    
    @IBOutlet weak private var pciLabel: UILabel!
    
    private var walletButtons : [PaymentMethodButton] = []
    internal var borderForField : [UITextField : UIView] = [:]
    
    internal static func createMCCheckoutViewController() -> MCCheckoutViewController{
        return MCCheckoutViewController.init()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(NSBundle(forClass: MCCheckoutViewController.self)))
    }
    
    ///The preferred costructor to be used in order to create the View Controller
    init(){
        super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(NSBundle(forClass: MCCheckoutViewController.self)))
        
    }
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.assignImages()
        if paymentMethods.count > 0 {
            selectedMethod = paymentMethods[0]
        }
        borderForField = [creditCardNumberField : creditCardBorderView, dateField : dateFieldBorderView, cvvField : cvvBorderView, zipField : zipFieldBorderView]
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(MCCheckoutViewController.refreshPaymentMethods), name: MyCheckWallet.refreshPaymentMethodsNotification, object: nil)
        
        //setting up UI and updating it if the user logges in... just incase
        setupUI()
        nc.addObserver(self, selector: #selector(MCCheckoutViewController.setupUI), name: MyCheckWallet.loggedInNotification, object: nil)
        
        
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.resetFields()
        MyCheckWallet.manager.factoryDelegate = self
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    private func assignImages(){
        visaImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsvisa" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/VI.png"))))
        mastercardImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsmastercard" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/MC.png"))))
        dinersImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsdinersclub" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DC.png"))))
        discoverImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsdiscover" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DS.png"))))
        amexImageView.kf_setImageWithURL(NSURL(string: (LocalData.manager.getString("acceptedCardsAMEX" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/AX.png"))))
        
    }
    
    private func addDoneButtonOnPicker(field: UITextField , action: Selector){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.Done, target: self, action: action)
        
        let items = [flexSpace , done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
    }
    
    func donePressed(sender: UIBarButtonItem){
        selectedMethod = self.paymentMethods[self.paymentMethodSelector.selectedRowInComponent(0)]
        self.paymentMethodSelectorTextField.text = self.selectedMethod!.name
        self.typeImage.kf_setImageWithURL(self.imageURL(self.getType(selectedMethod!.issuer)))
        
        self.view.endEditing(true)
    }
    
    
    
    
    func configureUI(){
        creditCardNumberField.attributedPlaceholder = NSAttributedString(string:"1234 1234 1234 1234", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        dateField.attributedPlaceholder = NSAttributedString(string:"mm/yy", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        cvvField.attributedPlaceholder = NSAttributedString(string:"CVV", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        zipField.attributedPlaceholder = NSAttributedString(string:"ZIP/Postal", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        for view in textFieldsBorderViews {
            view.layer.borderColor = UIColor(r: 124, g: 114, b: 112, a: 1).CGColor
            view.layer.borderWidth = 1.0
        }
        cancelButton.layer.borderColor = UIColor(r: 126, g: 166, b: 171, a: 1).CGColor
        cancelButton.layer.borderWidth = 1.0
        colapsableContainer.alpha = 0
        if paymentMethods != nil {
            if paymentMethods.count > 0 {
                creditCardNumberField.hidden = true
                self.paymentSelectorView.hidden = false
                self.paymentMethodSelectorTextField.text = self.selectedMethod!.name
                
                self.typeImage.kf_setImageWithURL(self.imageURL(self.getType((self.paymentMethods.first?.issuer)!)))
                
                self.checkbox.hidden = true
                self.checkBoxLabel.hidden = true
            }else{
                let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
                typeImage.image = UIImage(named: "no_type_card_1" , inBundle: bundle, compatibleWithTraitCollection: nil)!
                creditCardNumberField.hidden = false
                self.paymentSelectorView.hidden = true
                self.checkbox.hidden = false
                self.checkBoxLabel.hidden = false
            }
        }
        self.moveAcceptedCreditCardsViewToCreditCardField(true, animated: false)
        paymentMethodSelector = UIPickerView()
        paymentMethodSelector.delegate = self
        paymentMethodSelector.dataSource = self
        paymentMethodSelector.backgroundColor = UIColor.whiteColor()
        paymentMethodSelectorTextField.inputView = paymentMethodSelector
        addDoneButtonOnPicker(paymentMethodSelectorTextField, action: #selector(donePressed(_: )))
    }
    
    
    internal func imageURL( type: CreditCardType) -> NSURL?{
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .masterCard:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesmastercard"))!
        case .visa:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        case .diners:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesdinersclub"))!
        case .discover:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesdiscover"))!
        case .amex:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesamex"))!
        case .JCB:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesJCB"))!
        case .maestro:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesmaestro"))!
            
        default:
            return NSURL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        }
    }
    
    internal func getType(type : String) -> CreditCardType {
        switch type {
        case "visa":
            return CreditCardType.visa
        case "mastercard":
            return CreditCardType.masterCard
        case "discover":
            return CreditCardType.discover
        case "amex":
            return CreditCardType.amex
        case "jcb":
            return CreditCardType.JCB
        case "dinersclub":
            return CreditCardType.diners
        case "maestro":
            return CreditCardType.maestro
            
        default:
            return CreditCardType.unknown
        }
    }
    @objc private func refreshPaymentMethods(){
        MyCheckWallet.manager.getPaymentMethods({ (methods) in
            self.paymentMethods = methods
            if methods.count == 0 {
                self.selectedMethod = nil
            }else{
                self.selectedMethod = methods.first
                
            }
            self.configureUI()
        }) { (error) in
            
        }
    }
    @IBAction func managePaymentMethodsButtonPressed(_ sender: UIButton) {
        let controller : MCPaymentMethodsViewController
        //        if self.paymentMethods.count > 0 && self.paymentMethods.first?.isSingleUse == true {
        //            controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
        //        }else{
        controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
        //  }
        
        self.presentViewController(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    override internal func setFieldInvalid(field: UITextField , invalid: Bool){
        let badColor = LocalData.manager.getColor("checkoutPageColorserrorInput", fallback: UIColor.redColor())
        let goodColor = LocalData.manager.getColor("checkoutPageColorsfieldBorder", fallback: creditCardNumberField.textColor!)

        let border = borderForField[field]
        border?.layer.borderColor = invalid ? badColor.CGColor :goodColor.CGColor
        field.textColor = invalid ? badColor : UIColor(r: 255, g: 255, b: 255, a: 1)
    }
    
    internal func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField {
        case creditCardNumberField:
            UIView.animateWithDuration(0.4, animations: {
                self.moveAcceptedCreditCardsViewToCreditCardField(false, animated: true)
            })
            break
        case paymentMethodSelectorTextField:
            break
        default:
            return true
        }
        
        return true
    }
    
    @IBAction func checkboxPressed(_ sender: UIButton) {
        self.checkbox.selected = !self.checkbox.selected
    }
    
    @IBAction func cancelButPressed(_ sender: AnyObject) {
        super.cancelPressed(sender)
        self.resetFields()
        self.view.endEditing(true)
        UIView.animateWithDuration(0.4, animations: {
            self.moveAcceptedCreditCardsViewToCreditCardField(true , animated: true)
        })
    }
    @IBAction func applyButPressed(_ sender: AnyObject) {
        if updateAndCheckValid(){
            self.view.endEditing(true)
            let type = super.getType()
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split("/").map(String.init)
            self.startActivityIndicator()
            self.applyButton.enabled = false
            self.cancelButton.enabled = false
            
            self.creditCardNumberField.userInteractionEnabled = false
            self.dateField.userInteractionEnabled = false
            self.cvvField.userInteractionEnabled = false
            self.zipField.userInteractionEnabled = false
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: self.checkbox.selected, success: {  method in
                self.resetFields()
                self.selectedMethod = method
                
                if method.isSingleUse == true{
                    self.paymentMethods = [method]
                    self.paymentMethodSelector.reloadAllComponents()
                    self.paymentMethodSelectorTextField.text = self.selectedMethod!.name
                    self.typeImage.kf_setImageWithURL(self.imageURL(self.getType((self.selectedMethod!.issuer))))
                    self.creditCardNumberField.hidden = true
                    self.paymentSelectorView.hidden = false
                    self.checkbox.hidden = true
                    self.checkBoxLabel.hidden = true
                    self.moveAcceptedCreditCardsViewToCreditCardField(true, animated: false)
                }else{
                    self.newPaymenteMethodAdded()
                }
                self.creditCardNumberField.userInteractionEnabled = true
                self.dateField.userInteractionEnabled = true
                self.cvvField.userInteractionEnabled = true
                self.zipField.userInteractionEnabled = true
                self.applyButton.enabled = true
                self.cancelButton.enabled = true
                self.activityView.stopAnimating()
                }, fail: { error in
                    self.applyButton.enabled = true
                    self.cancelButton.enabled = true
                    self.creditCardNumberField.userInteractionEnabled = true
                    self.dateField.userInteractionEnabled = true
                    self.cvvField.userInteractionEnabled = true
                    self.zipField.userInteractionEnabled = true
                    self.activityView.stopAnimating()
                    if let delegate = self.delegate{
                        self.errorLabel.text = error.localizedDescription
                        delegate.recivedError(self, error:error)
                    }
            })
        }
        
    }
    
    override func startActivityIndicator() {
        activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .White)
        
        activityView.center=CGPointMake(self.view.center.x, self.view.center.y)
        activityView.startAnimating()
        self.view.addSubview(activityView)
    }
    
    func newPaymenteMethodAdded(){
        MyCheckWallet.manager.getPaymentMethods({ (methods) in
            self.paymentMethods = methods
            self.configureUI()
        }) { (error) in
            
        }
    }
    
    func moveAcceptedCreditCardsViewToCreditCardField(move : Bool , animated: Bool){
        let animationLength = animated ? 0.2 : 0
        let baseHeight = 272.0 as Float
        self.acceptedCreditCardsViewTopToCreditCardFieldConstraint.priority = move ? 999 : 1
        self.acceptedCreditCardsViewTopToCollapsableViewConstraint.priority = move ? 1 : 999
        
        var delta = move ? baseHeight : baseHeight + 111.0
        if MyCheckWallet.manager.factories.count > 0 { // if we have factories we need to allow more room for the wallet buttons
            delta += 110
        }
        self.colapsableContainer.alpha = move ? 0 : 1
        if let del = checkoutDelegate{
            del.checkoutViewShouldResizeHeight(delta, animationDuration: animationLength)
        }
    }
    
    private func resetFields(){
        self.creditCardNumberField.text = ""
        self.dateField.text = ""
        self.cvvField.text = ""
        self.zipField.text = ""
        self.setFieldInvalid(self.creditCardNumberField, invalid: false)
        self.setFieldInvalid(self.dateField, invalid: false)
        self.setFieldInvalid(self.cvvField, invalid: false)
        self.setFieldInvalid(self.zipField, invalid: false)
    }
    
    @objc internal override func setupUI(){
        header.text = LocalData.manager.getString("checkoutPagecheckoutSubHeader" , fallback: header.text)
                dropdownHeader.text = LocalData.manager.getString("checkoutPagecardDropDownHeader" , fallback:dropdownHeader.text)
        managePaymentMethodsButton.setTitle( LocalData.manager.getString("checkoutPagemanagePMButton" , fallback:managePaymentMethodsButton.titleForState(.Normal)) , forState: .Normal)
        managePaymentMethodsButton.setTitle( LocalData.manager.getString("checkoutPagemanagePMButton" , fallback:managePaymentMethodsButton.titleForState(.Normal)) , forState: .Highlighted)
        
        checkBoxLabel.text = LocalData.manager.getString("checkoutPagenotStoreCard" , fallback:checkBoxLabel.text)
        footerLabel.text = LocalData.manager.getString("checkoutPagecardAccepted" , fallback:footerLabel.text)
        pciLabel.text = LocalData.manager.getString("checkoutPagepciNotice1" , fallback:pciLabel.text)
        
        //setting up colors
        header.textColor = LocalData.manager.getColor("checkoutPageColorsheaderTextColor", fallback: header.textColor!)
        headerLineBG.backgroundColor = LocalData.manager.getColor("checkoutPageColorsheaderBackground", fallback: headerLineBG.backgroundColor!)
        
        applyButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorsapplyButtonText", fallback: applyButton.titleColorForState(.Normal)!), forState: .Normal)
        applyButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorsapplyButtonText", fallback: applyButton.titleColorForState(.Normal)!), forState: .Highlighted)
        applyButton.backgroundColor = LocalData.manager.getColor("checkoutPageColorsapplyBut", fallback: applyButton.backgroundColor!)
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsapplyButBorder", fallback:  UIColor.clearColor()).CGColor
        cancelButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorscancelButtonText", fallback: cancelButton.titleColorForState(.Normal)!), forState: .Normal)
        cancelButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorscancelButtonText", fallback: cancelButton.titleColorForState(.Normal)!), forState: .Highlighted)
        cancelButton.backgroundColor = LocalData.manager.getColor("checkoutPageColorscancelBut", fallback: UIColor.clearColor())
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsapplyButBorder", fallback:  UIColor.clearColor()).CGColor
        pciLabel.textColor = LocalData.manager.getColor("checkoutPageColorspciNotice", fallback: header.textColor!)
        
        pickerDownArrow.image = pickerDownArrow.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        pickerDownArrow.tintColor = LocalData.manager.getColor("checkoutPageColorspickerArrowColor", fallback: UIColor.clearColor())
        footerLabel.textColor = LocalData.manager.getColor("checkoutPageColorscardAccepted", fallback: footerLabel.textColor!)
        view.backgroundColor = LocalData.manager.getColor("checkoutPageColorsbackground", fallback: UIColor.clearColor())
        for (key , view) in borderForField {
        view.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsfieldBorder", fallback: view.backgroundColor!).CGColor
        view.layer.borderWidth = 1
        }
        checkBoxLabel.textColor = LocalData.manager.getColor("checkoutPageColorsnotStoreCard", fallback: checkBoxLabel.textColor!)
        managePaymentMethodsButton.setTitleColor( LocalData.manager.getColor("checkoutPageColorsmanagePMButton", fallback: managePaymentMethodsButton.titleColorForState(.Normal)!), forState: .Normal)
       managePaymentMethodsButton.setTitleColor( LocalData.manager.getColor("checkoutPageColorsmanagePMButton", fallback: managePaymentMethodsButton.titleColorForState(.Highlighted)!), forState: .Highlighted)
        dropdownHeader.textColor =  LocalData.manager.getColor("checkoutPageColorscardDropDownHeader", fallback: dropdownHeader.textColor!)
        let fieldColor = LocalData.manager.getColor("checkoutPageColorstextField", fallback: creditCardNumberField.textColor!)
        creditCardNumberField.textColor = fieldColor
        dateField.textColor = fieldColor
        cvvField.textColor = fieldColor
        zipField.textColor = fieldColor
        errorLabel.textColor = LocalData.manager.getColor("checkoutPageColorserrorInput", fallback: creditCardNumberField.textColor!)

        //setting up wallets UI
        if (walletButtons.count == 0 && MyCheckWallet.manager.isLoggedIn()) {
            switch MyCheckWallet.manager.factories.count {
            case 0:
                walletsHeight.constant = 0
                walletsSuperview.hidden = true
            case 1:
                //adding button to center of container
                let factory = MyCheckWallet.manager.factories[0]
                let but = factory.getSmallAddMethodButton()
                self.walletButsContainer.addSubview(but)
                but.translatesAutoresizingMaskIntoConstraints = false
                
                let horizontalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: walletButsContainer, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                walletsSuperview.addConstraint(horizontalConstraint)
                
                let verticalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: walletButsContainer, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                walletButsContainer.addConstraint(verticalConstraint)
                walletButtons.append(but)
                but.enabled = true
                but.userInteractionEnabled = true
                print( but.bounds , "    " , but.frame)
            default:// multiple wallets
                for factory in MyCheckWallet.manager.factories{
                    //TO-DO implement adding multiple wallets
                }
            }
        }
        
    }
}

extension MCCheckoutViewController : MCPaymentMethodsViewControllerDelegate{
    
    
    public func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController){
        controller.dismissViewControllerAnimated(true, completion: nil)
        refreshPaymentMethods()
        
    }
}

extension MCCheckoutViewController : UIPickerViewDelegate , UIPickerViewDataSource {
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.paymentMethods.count
        
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.paymentMethods[row].name
    }
}


extension MCCheckoutViewController : PaymentMethodFactoryDelegate{
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
        refreshPaymentMethods()
    }
    func displayViewController(controller: UIViewController ){
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func dismissViewController(controller: UIViewController ){
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
