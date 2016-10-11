//
//  MCCheckoutViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit

///The delegate of a CheckoutView or CheckoutTableViewCell object must adopt this protocol and implement at least some of its methods in order to be able to resize the view when needed. The View will not automaticly resize since it might be used in a few diffrant ways (e.g contraints might be broken)
@objc public protocol CheckoutDelegate{
    ///Called by the CheckoutView/CheckoutTableViewCell when the height is changed
    ///   - parameter newHight: The new height of the CheckoutView/CheckoutTableViewCell
    ///   - parameter animationDuration: The duration the animation will take. The animation will start directly after this call is pressed. You should resize the view imidiatly and use the same animation duration in order for the animation to look good
    
   func checkoutViewShouldResizeHeight(newHeight : Float , animationDuration: NSTimeInterval) -> Void
       
}
public class MCCheckoutViewController: MCAddCreditCardViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //variables
    /// This variable will always have the currant payment method selected by the user. In the case where the user doesn't have a payment method the variable will be nil.
     public var selectedMethod : PaymentMethod?
    weak public var checkoutDelegate : CheckoutDelegate?
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
    
    @IBOutlet weak var visaImageView: UIImageView!
    @IBOutlet weak var mastercardImageView: UIImageView!
    @IBOutlet weak var dinersImageView: UIImageView!
    @IBOutlet weak var amexImageView: UIImageView!
    @IBOutlet weak var discoverImageView: UIImageView!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var creditCardBorderView: UIView!
    @IBOutlet weak var dateFieldBorderView: UIView!
    @IBOutlet weak var cvvBorderView: UIView!
    @IBOutlet weak var zipFieldBorderView: UIView!
    internal var borderForField : [UITextField : UIView]?
    
    internal static func createMCCheckoutViewController() -> MCCheckoutViewController{
       return MCCheckoutViewController.init()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(NSBundle(forClass: MCCheckoutViewController.self)))
    }
    
    ///The prefred costructor to use in ordder to create the View Controller
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
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        self.paymentMethodSelectorTextField.text = selectedMethod!.lastFourDigits
        typeImage.image = self.setImageForType(self.getType((selectedMethod!.issuer)))
        self.view.endEditing(true)
    }
    
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.paymentMethods.count
        
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.paymentMethods[row].lastFourDigits
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
                self.paymentMethodSelectorTextField.text = self.paymentMethods.first?.lastFourDigits
                typeImage.image = self.setImageForType(self.getType((self.paymentMethods.first?.issuer)!))
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
    
    internal func setImageForType( type: CreditCardType) -> UIImage{
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .masterCard:
            return UIImage(named: "master_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .visa:
            return UIImage(named: "visa_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .diners:
            return UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .discover:
            return UIImage(named: "discover_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .amex:
            return UIImage(named: "amex_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .diners:
            return UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .JCB:
            return UIImage(named: "jcb_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
        case .maestro:
            return UIImage(named: "maestro_small", inBundle: bundle, compatibleWithTraitCollection: nil)!
            
        default:
            return UIImage(named: "no_type_card_1" , inBundle: bundle, compatibleWithTraitCollection: nil)!
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
        if self.paymentMethods.count > 0 && self.paymentMethods.first?.isSingleUse == true {
            controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: nil)
        }else{
            controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: self.paymentMethods)
        }
        
        self.presentViewController(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    override internal func setFieldInvalid(field: UITextField , invalid: Bool){
        let border = borderForField![field]
        border?.layer.borderColor = invalid ? UIColor.redColor().CGColor : UIColor(r: 124, g: 114, b: 112, a: 1).CGColor
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor(r: 255, g: 255, b: 255, a: 1)
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
                self.creditCardNumberField.text = ""
                self.dateField.text = ""
                self.cvvField.text = ""
                self.zipField.text = ""
              self.selectedMethod = method

                if method.isSingleUse == true{
                    self.paymentMethods = [method]
                    self.paymentMethodSelector.reloadAllComponents()
                    self.paymentMethodSelectorTextField.text = self.selectedMethod!.lastFourDigits
                    self.typeImage.image = self.setImageForType(self.getType((self.selectedMethod!.issuer)))
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
        let baseHeight = 270.0 as Float
        self.acceptedCreditCardsViewTopToCreditCardFieldConstraint.priority = move ? 999 : 1
        self.acceptedCreditCardsViewTopToCollapsableViewConstraint.priority = move ? 1 : 999
        
        let delta = move ? baseHeight : baseHeight + 118.0
        self.colapsableContainer.alpha = move ? 0 : 1
        if let del = checkoutDelegate{
            del.checkoutViewShouldResizeHeight(delta, animationDuration: animationLength)
        }
    }
}

extension MCCheckoutViewController : MCPaymentMethodsViewControllerDelegate{
    
    
    public func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController){
      controller.dismissViewControllerAnimated(true, completion: nil)

        MyCheckWallet.manager.getPaymentMethods({ (array) in
            if array.count > 0{
                self.paymentMethods = array
            }else{
                self.paymentMethods = nil
                
            }
            self.configureUI()
            }, fail: { error in
                
        })
        
    }
}
