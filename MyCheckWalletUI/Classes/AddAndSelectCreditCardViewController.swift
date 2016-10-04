//
//  AddAndSelectCreditCardViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit

public class AddAndSelectCreditCardViewController: MCAddCreditCardViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var paymentMethodSelectorTextField: UITextField!
    @IBOutlet weak var colapsableContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var textFieldsBorderViews: [UIView]!
    @IBOutlet weak var managePaymentMethodsButton: UIButton!
    var paymentMethodSelector : UIPickerView = UIPickerView()
    public var paymentMethods: Array<PaymentMethod>!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        paymentMethodSelector = UIPickerView()
        paymentMethodSelector.delegate = self
        paymentMethodSelector.dataSource = self
        paymentMethodSelector.backgroundColor = UIColor.whiteColor()
        paymentMethodSelectorTextField.inputView = paymentMethodSelector
        addDoneButtonOnPicker(paymentMethodSelectorTextField, action: #selector(donePressed(_: )))
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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

    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.paymentMethods != nil {
            return self.paymentMethods.count
        }else{
            return 0
        }
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.paymentMethods[row].lastFourDigits
    }
    
    func configureUI(){
        creditCardNumberField.attributedPlaceholder = NSAttributedString(string:"1234 1234 1234 1234", attributes:[NSForegroundColorAttributeName: UIColor(r: 124, g: 114, b: 112, a: 1)])
        dateField.attributedPlaceholder = NSAttributedString(string:"mm/yy", attributes:[NSForegroundColorAttributeName: UIColor(r: 124, g: 114, b: 112, a: 1)])
        cvvField.attributedPlaceholder = NSAttributedString(string:"CVV", attributes:[NSForegroundColorAttributeName: UIColor(r: 124, g: 114, b: 112, a: 1)])
        zipField.attributedPlaceholder = NSAttributedString(string:"ZIP/Postal", attributes:[NSForegroundColorAttributeName: UIColor(r: 124, g: 114, b: 112, a: 1)])
        for view in textFieldsBorderViews {
            view.layer.borderColor = UIColor(r: 124, g: 114, b: 112, a: 1).CGColor
            view.layer.borderWidth = 1.0
        }
        cancelButton.layer.borderColor = UIColor(r: 126, g: 166, b: 171, a: 1).CGColor
        cancelButton.layer.borderWidth = 1.0
        colapsableContainer.hidden = true
        if (self.paymentMethods != nil) {
            self.paymentMethodSelectorTextField.text = self.paymentMethods.first?.lastFourDigits
            self.paymentMethodSelectorTextField.hidden = false
            creditCardNumberField.hidden = true
            typeImage.image = self.setImageForType(self.getType((self.paymentMethods.first?.issuer)!))
        }else{
            creditCardNumberField.hidden = false
            self.paymentMethodSelectorTextField.hidden = true
        }
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
            return UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)!
        }
    }
    
    internal func getType(type : String) -> CreditCardType {
        switch type {
        case "Visa":
            return CreditCardType.visa
        case "MasterCard":
            return CreditCardType.masterCard
        case "Discover":
            return CreditCardType.discover
        case "Amex":
            return CreditCardType.amex
        case "JCB":
            return CreditCardType.JCB
        case "Diners":
            return CreditCardType.diners
        case "Maestro":
            return CreditCardType.maestro
            
        default:
            return CreditCardType.unknown
        }
    }

    @IBAction func managePaymentMethodsButtonPressed(_ sender: UIButton) {
        let controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self, withPaymentMethods: self.paymentMethods)
        self.presentViewController(controller, animated: true, completion: nil)
    }

    public static func createAddAndSelectCreditCardViewController(withPaymentMethods : Array<PaymentMethod>!) -> AddAndSelectCreditCardViewController{
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("AddAndSelectCreditCardViewController") as! AddAndSelectCreditCardViewController
        controller.paymentMethods = withPaymentMethods
        //controller.delegate = delegate
        
        return controller
    }
    
    override public func setFieldInvalid(field: UITextField , invalid: Bool){
        let underline = underlineForField![field]
        underline?.backgroundColor = invalid ? UIColor.fieldUnderlineInvalid() : UIColor(r: 124, g: 114, b: 112, a: 1)
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor(r: 124, g: 114, b: 112, a: 1)
    }

    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField {
        case creditCardNumberField:
            UIView.animateWithDuration(0.4, animations: {
                self.colapsableContainer.hidden = false
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
        self.view.endEditing(true)
        UIView.animateWithDuration(0.4, animations: {
            self.colapsableContainer.hidden = true
        })
    }
    
    override func ApplyPressed(sender: AnyObject) {
        if updateAndCheckValid(){
            let type = getType(creditCardNumberField.text!)
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split("/").map(String.init)
            
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: self.checkbox.selected, success: {  token in
                if let delegate = self.delegate{
                    
                    delegate.addedNewPaymentMethod(self, token:token)
                }
                }, fail: { error in
                    if let delegate = self.delegate{
                        self.errorLabel.text = error.localizedDescription
                        delegate.recivedError(self, error:error)
                    }
            })
        }
    }
}

extension AddAndSelectCreditCardViewController : MCPaymentMethodsViewControllerDelegate{
    public func userDismissed(  controller: MCPaymentMethodsViewControllerDelegate)
    {
    }
}
