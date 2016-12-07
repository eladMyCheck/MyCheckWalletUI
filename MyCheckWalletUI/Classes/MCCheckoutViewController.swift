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
    func checkoutViewShouldResizeHeight(_ newHeight : Float , animationDuration: Double)
    
}
///A view controller that provides the ability to add a credit card and or select a payment method. The view controller is meant to be used as part of a parent view controller using a container view.
open class MCCheckoutViewController: MCAddCreditCardViewController {
    //variables
    
    /// This variable will always have the currant payment method selected by the user. In the case where the user doesn't have a payment method the variable will be nil.
    open var selectedMethod : PaymentMethod?
    
    ///The delegate that will be updated with MCCheckoutViewController height changes
    open var checkoutDelegate : CheckoutDelegate?
    
    //Outlets
    @IBOutlet weak fileprivate  var paymentSelectorView: UIView!
    @IBOutlet weak  fileprivate  var acceptedCreditCardsViewTopToCreditCardFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptedCreditCardsViewTopToCollapsableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var checkbox: UIButton!
    @IBOutlet weak fileprivate var paymentMethodSelectorTextField: UITextField!
    @IBOutlet weak fileprivate var colapsableContainer: UIView!
    @IBOutlet weak fileprivate var cancelButton: UIButton!
    @IBOutlet fileprivate var textFieldsBorderViews: [UIView]!
    @IBOutlet weak fileprivate var managePaymentMethodsButton: UIButton!
    var paymentMethodSelector : UIPickerView = UIPickerView()
    fileprivate var paymentMethods: Array<PaymentMethod>! = []
    
    @IBOutlet weak fileprivate var visaImageView: UIImageView!
    @IBOutlet weak fileprivate var mastercardImageView: UIImageView!
    @IBOutlet weak fileprivate var dinersImageView: UIImageView!
    @IBOutlet weak fileprivate var amexImageView: UIImageView!
    @IBOutlet weak fileprivate var discoverImageView: UIImageView!
    @IBOutlet weak fileprivate var checkBoxLabel: UILabel!
    @IBOutlet weak fileprivate var creditCardBorderView: UIView!
    @IBOutlet weak fileprivate var dateFieldBorderView: UIView!
    @IBOutlet weak fileprivate var cvvBorderView: UIView!
    @IBOutlet weak fileprivate var zipFieldBorderView: UIView!
    
    @IBOutlet weak fileprivate var header: UILabel!
    @IBOutlet weak fileprivate var dropdownHeader: UILabel!
    @IBOutlet weak fileprivate var footerLabel: UILabel!
    
    @IBOutlet weak var headerLineBG: UIView!
    @IBOutlet weak var pickerDownArrow: UIImageView!
    
    //3rd party wallet payment methods UI elements
    @IBOutlet weak var walletsSuperview: UIView!
    @IBOutlet weak var walletsHeight: NSLayoutConstraint!
    @IBOutlet weak var walletButsContainer: UIView!
    
    
    @IBOutlet weak fileprivate var pciLabel: UILabel!
    
    fileprivate var walletButtons : [PaymentMethodButton] = []
    internal var borderForField : [UITextField : UIView] = [:]
    
    internal static func createMCCheckoutViewController() -> MCCheckoutViewController{
        return MCCheckoutViewController.init()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(Bundle(for: MCCheckoutViewController.self)))
    }
    
    ///The preferred costructor to be used in order to create the View Controller
    init(){
        super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(Bundle(for: MCCheckoutViewController.self)))
        
    }
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.assignImages()
        if paymentMethods.count > 0 {
            selectedMethod = paymentMethods[0]
        }
        borderForField = [creditCardNumberField : creditCardBorderView, dateField : dateFieldBorderView, cvvField : cvvBorderView, zipField : zipFieldBorderView]
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MCCheckoutViewController.refreshPaymentMethods), name: NSNotification.Name(rawValue: MyCheckWallet.refreshPaymentMethodsNotification), object: nil)
        
        //setting up UI and updating it if the user logges in... just incase
        setupUI()
        nc.addObserver(self, selector: #selector(MCCheckoutViewController.setupUI), name: NSNotification.Name(rawValue: MyCheckWallet.loggedInNotification), object: nil)
        
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetFields()
        MyCheckWallet.manager.factoryDelegate = self
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    fileprivate func assignImages(){
      visaImageView.kf.setImage(with: URL(string: (LocalData.manager.getString("acceptedCardsvisa" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/VI.png"))))
        mastercardImageView.kf.setImage(with: URL(string: (LocalData.manager.getString("acceptedCardsmastercard" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/MC.png"))))
        dinersImageView.kf.setImage(with: URL(string: (LocalData.manager.getString("acceptedCardsdinersclub" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DC.png"))))
        discoverImageView.kf.setImage(with: URL(string: (LocalData.manager.getString("acceptedCardsdiscover" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/DS.png"))))
        amexImageView.kf.setImage(with: URL(string: (LocalData.manager.getString("acceptedCardsAMEX" , fallback: "https://s3-eu-west-1.amazonaws.com/mywallet-sdk-sandbox/img/AX.png"))))
        
    }
    
    fileprivate func addDoneButtonOnPicker(_ field: UITextField , action: Selector){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.done, target: self, action: action)
        
        let items = [flexSpace , done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
    }
    
    func donePressed(_ sender: UIBarButtonItem){
        selectedMethod = self.paymentMethods[self.paymentMethodSelector.selectedRow(inComponent: 0)]
        self.paymentMethodSelectorTextField.text = self.selectedMethod!.checkoutName
        if let selectedMethod = selectedMethod {
            self.typeImage.kf.setImage(with: self.imageURLForDropdown(selectedMethod))
        }
        self.view.endEditing(true)
    }
    
    
    
    
    func configureUI(){
        creditCardNumberField.attributedPlaceholder = NSAttributedString(string:"1234 1234 1234 1234", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        dateField.attributedPlaceholder = NSAttributedString(string:"mm/yy", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        cvvField.attributedPlaceholder = NSAttributedString(string:"CVV", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        zipField.attributedPlaceholder = NSAttributedString(string:"ZIP/Postal", attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
        for view in textFieldsBorderViews {
            view.layer.borderColor = UIColor(r: 124, g: 114, b: 112, a: 1).cgColor
            view.layer.borderWidth = 1.0
        }
        cancelButton.layer.borderColor = UIColor(r: 126, g: 166, b: 171, a: 1).cgColor
        cancelButton.layer.borderWidth = 1.0
        colapsableContainer.alpha = 0
        if paymentMethods != nil {
            if paymentMethods.count > 0 {
                creditCardNumberField.isHidden = true
                self.paymentSelectorView.isHidden = false
                self.paymentMethodSelectorTextField.text = self.selectedMethod!.checkoutName
                
                self.typeImage.kf.setImage(with:self.imageURLForDropdown(self.paymentMethods.first!))
                
                self.checkbox.isHidden = true
                self.checkBoxLabel.isHidden = true
            }else{
                let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
                typeImage.image = UIImage(named: "no_type_card_1" , in: bundle, compatibleWith: nil)!
                creditCardNumberField.isHidden = false
                self.paymentSelectorView.isHidden = true
                self.checkbox.isHidden = false
                self.checkBoxLabel.isHidden = false
            }
        }
        self.moveAcceptedCreditCardsViewToCreditCardField(true, animated: false)
        paymentMethodSelector = UIPickerView()
        paymentMethodSelector.delegate = self
        paymentMethodSelector.dataSource = self
        paymentMethodSelector.backgroundColor = UIColor.white
        paymentMethodSelectorTextField.inputView = paymentMethodSelector
        addDoneButtonOnPicker(paymentMethodSelectorTextField, action: #selector(donePressed(_: )))
        self.errorLabel.text = "" //empty label in case it is displaying past errors
    }
    internal  func imageURLForDropdown( _ type: CreditCardType) -> URL?{
        switch type {
        case .MasterCard:
            return URL(string:  LocalData.manager.getString("cardsDropDownmastercard"))!
        case .Visa:
            return URL(string:  LocalData.manager.getString("cardsDropDownvisa"))!
        case .Diners:
            return URL(string:  LocalData.manager.getString("cardsDropDowndinersclub"))!
        case .Discover:
            return URL(string:  LocalData.manager.getString("cardsDropDowndiscover"))!
        case .Amex:
            return URL(string:  LocalData.manager.getString("cardsDropDownamex"))!
        case .JCB:
            return URL(string:  LocalData.manager.getString("cardsDropDownJCB"))!
        case .Maestro:
            return URL(string:  LocalData.manager.getString("cardsDropDownmaestro"))!
            
        default:
            return nil
        }

    }
    
    internal func imageURLForDropdown( _ method: PaymentMethod) -> URL?{
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        let type = method.type
        if type == .creditCard {
        return imageURLForDropdown(method.issuer)
        }
        if method.type == .payPal{
            return URL(string:  LocalData.manager.getString("cardsDropDownpaypal"))!

        }
    return nil
    }
    
    internal func getType(_ type : String) -> CreditCardType {
        switch type {
        case "visa":
            return CreditCardType.Visa
        case "mastercard":
            return CreditCardType.MasterCard
        case "discover":
            return CreditCardType.Discover
        case "amex":
            return CreditCardType.Amex
        case "jcb":
            return CreditCardType.JCB
        case "dinersclub":
            return CreditCardType.Diners
        case "maestro":
            return CreditCardType.Maestro
            
        default:
            return CreditCardType.Unknown
        }
    }
    @objc fileprivate func refreshPaymentMethods(){
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
        
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    override internal func setFieldInvalid(_ field: UITextField , invalid: Bool){
        let badColor = LocalData.manager.getColor("checkoutPageColorserrorInput", fallback: UIColor.red)
        let goodColor = LocalData.manager.getColor("checkoutPageColorsfieldBorder", fallback: creditCardNumberField.textColor!)

        let border = borderForField[field]
        border?.layer.borderColor = invalid ? badColor.cgColor :goodColor.cgColor
        field.textColor = invalid ? badColor : UIColor(r: 255, g: 255, b: 255, a: 1)
    }
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case creditCardNumberField:
            UIView.animate(withDuration: 0.4, animations: {
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
        self.checkbox.isSelected = !self.checkbox.isSelected
    }
    
    @IBAction func cancelButPressed(_ sender: AnyObject) {
        super.cancelPressed(sender)
        self.resetFields()
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.moveAcceptedCreditCardsViewToCreditCardField(true , animated: true)
        })
    }
    @IBAction func applyButPressed(_ sender: AnyObject) {
        if updateAndCheckValid(){
            self.view.endEditing(true)
            
            //getting type
            let (type ,_,_,_) = CreditCardValidator.checkCardNumber(creditCardNumberField.text!)
            
            
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split(separator: "/").map(String.init)
            self.showActivityIndicator( true)
            self.applyButton.isEnabled = false
            self.cancelButton.isEnabled = false
            
            self.creditCardNumberField.isUserInteractionEnabled = false
            self.dateField.isUserInteractionEnabled = false
            self.cvvField.isUserInteractionEnabled = false
            self.zipField.isUserInteractionEnabled = false
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: self.checkbox.isSelected, success: {  method in
                self.resetFields()
                // self.selectedMethod = method
                
                if method.isSingleUse == true{
                    
                  
                    self.checkbox.isHidden = true
                    self.checkBoxLabel.isHidden = true
                    self.moveAcceptedCreditCardsViewToCreditCardField(true, animated: false)
                    
                }
                    self.newPaymenteMethodAdded()
                
                self.creditCardNumberField.isUserInteractionEnabled = true
                self.dateField.isUserInteractionEnabled = true
                self.cvvField.isUserInteractionEnabled = true
                self.zipField.isUserInteractionEnabled = true
                self.applyButton.isEnabled = true
                self.cancelButton.isEnabled = true
                self.showActivityIndicator(false)
                }, fail: { error in
                    self.applyButton.isEnabled = true
                    self.cancelButton.isEnabled = true
                    self.creditCardNumberField.isUserInteractionEnabled = true
                    self.dateField.isUserInteractionEnabled = true
                    self.cvvField.isUserInteractionEnabled = true
                    self.zipField.isUserInteractionEnabled = true
                    self.showActivityIndicator(false)
                    self.errorLabel.text = error.localizedDescription
                    if let delegate = self.delegate{
                        self.errorLabel.text = error.localizedDescription
                        delegate.recivedError(self, error:error)
                    }
            })
        }
        
    }
    
  override func showActivityIndicator(_ show: Bool) {
      if activityView == nil{
        activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        
        activityView.center=CGPoint(x: self.view.center.x, y: self.view.center.y)
        activityView.startAnimating()
      activityView.hidesWhenStopped = true
        self.view.addSubview(activityView)
      }
    show ? activityView.startAnimating() : activityView.stopAnimating()
    }
    
    func newPaymenteMethodAdded(){
        MyCheckWallet.manager.getPaymentMethods({ (methods) in
            self.paymentMethods = methods
            if methods.count > 0 {
            self.selectedMethod = methods[0]
            }
            self.configureUI()
        }) { (error) in
            
        }
    }
    
    func moveAcceptedCreditCardsViewToCreditCardField(_ move : Bool , animated: Bool){
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
    
    fileprivate func resetFields(){
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
        managePaymentMethodsButton.setTitle( LocalData.manager.getString("checkoutPagemanagePMButton" , fallback:managePaymentMethodsButton.title(for: UIControlState())) , for: UIControlState())
        managePaymentMethodsButton.setTitle( LocalData.manager.getString("checkoutPagemanagePMButton" , fallback:managePaymentMethodsButton.title(for: UIControlState())) , for: .highlighted)
        
        checkBoxLabel.text = LocalData.manager.getString("checkoutPagenotStoreCard" , fallback:checkBoxLabel.text)
        footerLabel.text = LocalData.manager.getString("checkoutPagecardAccepted" , fallback:footerLabel.text)
        pciLabel.text = LocalData.manager.getString("checkoutPagepciNotice1" , fallback:pciLabel.text)
        
        //setting up colors
        header.textColor = LocalData.manager.getColor("checkoutPageColorsheaderTextColor", fallback: header.textColor!)
        headerLineBG.backgroundColor = LocalData.manager.getColor("checkoutPageColorsheaderBackground", fallback: headerLineBG.backgroundColor!)
        
        applyButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorsapplyButtonText", fallback: applyButton.titleColor(for: UIControlState())!), for: UIControlState())
        applyButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorsapplyButtonText", fallback: applyButton.titleColor(for: UIControlState())!), for: .highlighted)
        applyButton.backgroundColor = LocalData.manager.getColor("checkoutPageColorsapplyBut", fallback: applyButton.backgroundColor!)
        applyButton.layer.borderWidth = 1
        applyButton.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsapplyButBorder", fallback:  UIColor.clear).cgColor
        cancelButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorscancelButtonText", fallback: cancelButton.titleColor(for: UIControlState())!), for: UIControlState())
        cancelButton.setTitleColor(LocalData.manager.getColor("checkoutPageColorscancelButtonText", fallback: cancelButton.titleColor(for: UIControlState())!), for: .highlighted)
        cancelButton.backgroundColor = LocalData.manager.getColor("checkoutPageColorscancelBut", fallback: UIColor.clear)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsapplyButBorder", fallback:  UIColor.clear).cgColor
        pciLabel.textColor = LocalData.manager.getColor("checkoutPageColorspciNotice", fallback: header.textColor!)
        
        pickerDownArrow.image = pickerDownArrow.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pickerDownArrow.tintColor = LocalData.manager.getColor("checkoutPageColorspickerArrowColor", fallback: UIColor.clear)
        footerLabel.textColor = LocalData.manager.getColor("checkoutPageColorscardAccepted", fallback: footerLabel.textColor!)
        view.backgroundColor = LocalData.manager.getColor("checkoutPageColorsbackground", fallback: UIColor.clear)
        for (key , view) in borderForField {
        view.layer.borderColor = LocalData.manager.getColor("checkoutPageColorsfieldBorder", fallback: view.backgroundColor!).cgColor
        view.layer.borderWidth = 1
        }
        checkBoxLabel.textColor = LocalData.manager.getColor("checkoutPageColorsnotStoreCard", fallback: checkBoxLabel.textColor!)
        managePaymentMethodsButton.setTitleColor( LocalData.manager.getColor("checkoutPageColorsmanagePMButton", fallback: managePaymentMethodsButton.titleColor(for: UIControlState())!), for: UIControlState())
       managePaymentMethodsButton.setTitleColor( LocalData.manager.getColor("checkoutPageColorsmanagePMButton", fallback: managePaymentMethodsButton.titleColor(for: .highlighted)!), for: .highlighted)
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
                walletsSuperview.isHidden = true
            case 1:
                //adding button to center of container
                let factory = MyCheckWallet.manager.factories[0]
                let but = factory.getSmallAddMethodButton()
                self.walletButsContainer.addSubview(but)
                but.translatesAutoresizingMaskIntoConstraints = false
                
                let horizontalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: walletButsContainer, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
                walletsSuperview.addConstraint(horizontalConstraint)
                
                let verticalConstraint = NSLayoutConstraint(item: but, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: walletButsContainer, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
                walletButsContainer.addConstraint(verticalConstraint)
                walletButtons.append(but)
                but.isEnabled = true
                but.isUserInteractionEnabled = true
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
    
    
    public func dismissedMCPaymentMethodsViewController(_ controller: MCPaymentMethodsViewController){
        controller.dismiss(animated: true, completion: nil)
        refreshPaymentMethods()
        
    }
}

extension MCCheckoutViewController : UIPickerViewDelegate , UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.paymentMethods.count
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.paymentMethods[row].checkoutName
    }
}


extension MCCheckoutViewController : PaymentMethodFactoryDelegate{
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
        refreshPaymentMethods()
    }
    func displayViewController(_ controller: UIViewController ){
        self.present(controller, animated: true, completion: nil)
    }
    
    func dismissViewController(_ controller: UIViewController ){
        controller.dismiss(animated: true, completion: nil)
    }
  func showLoadingIndicator(_ controller: PaymentMethodFactory, show: Bool) {
    self.showActivityIndicator( show)

  }
}
