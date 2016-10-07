//
//  AddAndSelectCreditCardViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit

internal class AddAndSelectCreditCardViewController: MCAddCreditCardViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var paymentSelectorView: UIView!
    @IBOutlet weak var acceptedCreditCardsViewTopToCreditCardFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptedCreditCardsViewTopToCollapsableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var paymentMethodSelectorTextField: UITextField!
    @IBOutlet weak var colapsableContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var textFieldsBorderViews: [UIView]!
    @IBOutlet weak var managePaymentMethodsButton: UIButton!
    var paymentMethodSelector : UIPickerView = UIPickerView()
    internal var paymentMethods: Array<PaymentMethod>!
    
    @IBOutlet weak var visaImageView: UIImageView!
    @IBOutlet weak var mastercardImageView: UIImageView!
    @IBOutlet weak var dinersImageView: UIImageView!
    @IBOutlet weak var amexImageView: UIImageView!
    @IBOutlet weak var discoverImageView: UIImageView!
    @IBOutlet weak var checkBoxLabel: UILabel!
    
    internal static func createAddAndSelectCreditCardViewController(withPaymentMethods : Array<PaymentMethod>!) -> AddAndSelectCreditCardViewController{
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("AddAndSelectCreditCardViewController") as! AddAndSelectCreditCardViewController
        controller.paymentMethods = withPaymentMethods
        
        return controller
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.assignImages()
    }
    
    internal override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func assignImages(){
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
        let selectedMethod = self.paymentMethods[self.paymentMethodSelector.selectedRowInComponent(0)]
        self.paymentMethodSelectorTextField.text = selectedMethod.lastFourDigits
        typeImage.image = self.setImageForType(self.getType((selectedMethod.issuer)))
        MyCheckWallet.manager.setPaymentMethodAsDefault(selectedMethod, success: {
            print("payment set as default")
            }) { (error) in
                print("did not set payment as default")
        }
        self.view.endEditing(true)
    }

    
    internal func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.paymentMethods != nil {
            return self.paymentMethods.count
        }else{
            return 0
        }
    }
    
    internal func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
        colapsableContainer.hidden = true
        if (self.paymentMethods != nil) {
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
        self.moveAcceptedCreditCardsViewToCreditCardField(true)
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

    @IBAction func managePaymentMethodsButtonPressed(_ sender: UIButton) {
        let controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: self.paymentMethods)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    override internal func setFieldInvalid(field: UITextField , invalid: Bool){
        let underline = underlineForField![field]
        underline?.backgroundColor = invalid ? UIColor.fieldUnderlineInvalid() : UIColor(r: 124, g: 114, b: 112, a: 1)
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor(r: 124, g: 114, b: 112, a: 1)
    }

    internal func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField {
        case creditCardNumberField:
            UIView.animateWithDuration(0.4, animations: {
                self.colapsableContainer.hidden = false
                self.moveAcceptedCreditCardsViewToCreditCardField(false)
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
    override func cancelPressed(sender: AnyObject) {
        super.cancelPressed(sender)
        self.view.endEditing(true)
        UIView.animateWithDuration(0.4, animations: {
            self.colapsableContainer.hidden = true
            self.moveAcceptedCreditCardsViewToCreditCardField(true)
        })
    }
    
    override func ApplyPressed(sender: AnyObject) {
        if updateAndCheckValid(){
            self.view.endEditing(true)
            let type = super.getType()
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split("/").map(String.init)
            self.startActivityIndicator()
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: self.checkbox.selected, success: {  token in
                    self.newPaymenteMethodAdded()
                self.creditCardNumberField.text = ""
                self.dateField.text = ""
                self.cvvField.text = ""
                self.zipField.text = ""
                self.activityView.stopAnimating()
                }, fail: { error in
                    self.activityView.stopAnimating()
                    if let delegate = self.delegate{
                        self.errorLabel.text = error.localizedDescription
                        delegate.recivedError(self, error:error)
                    }
            })
        }
    }
    
    func newPaymenteMethodAdded(){
        MyCheckWallet.manager.getPaymentMethods({ (methods) in
            self.paymentMethods = methods
            self.configureUI()
            }) { (error) in
                
        }
    }
    
    func moveAcceptedCreditCardsViewToCreditCardField(move : Bool){
        self.acceptedCreditCardsViewTopToCreditCardFieldConstraint.priority = move ? 999 : 1
        self.acceptedCreditCardsViewTopToCollapsableViewConstraint.priority = move ? 1 : 999
    }
}

extension AddAndSelectCreditCardViewController : MCPaymentMethodsViewControllerDelegate{
    internal func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    }
    
    func dissmissedVC(){
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
