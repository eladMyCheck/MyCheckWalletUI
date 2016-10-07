//
//  MCAddCreditCardViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
///A protocol that will allow the owner to dismiss the ViewController
internal protocol MCAddCreditCardViewControllerDelegate {
    func recivedError(controller: MCAddCreditCardViewController , error:NSError)
    func addedNewPaymentMethod(controller: MCAddCreditCardViewController ,token:String)
    func canceled()
}

internal class MCAddCreditCardViewController: MCViewController {
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet var typeImage: UIImageView!
    @IBOutlet var creditCardNumberField: UITextField!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var cvvField: UITextField!
    @IBOutlet var zipField: UITextField!
    
    @IBOutlet var creditCardUnderline: UIView!
    @IBOutlet var dateUnderline: UIView!
    @IBOutlet var cvvUnderline: UIView!
    @IBOutlet var zipUnderline: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    var underlineForField : [UITextField : UIView]?
    
    var delegate : MCAddCreditCardViewControllerDelegate?
    //MARK: - life cycle functions
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        underlineForField = [creditCardNumberField : creditCardUnderline , dateField : dateUnderline , cvvField : cvvUnderline , zipField : zipUnderline]

        addNextButtonOnKeyboard(creditCardNumberField, action: #selector(nextPressed(_: )))
        addNextButtonOnKeyboard(dateField, action: #selector(nextPressed(_: )))
        addNextButtonOnKeyboard(cvvField, action: #selector(nextPressed(_: )))
        
    }
    internal static func instantiate(delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("MCAddCreditCardViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        
        return controller
    }
    
    
    
    
    //MARK: - actions
    @IBAction func ApplyPressed(sender: AnyObject) {
        
        if updateAndCheckValid(){
            let type = getType()
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split("/").map(String.init)
            applyButton.enabled = false
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: false, success: {  token in
                if let delegate = self.delegate{
                    
                    delegate.addedNewPaymentMethod(self, token:token)
                    self.applyButton.enabled = true
                }
                }, fail: { error in
                    if let delegate = self.delegate{
                        self.errorLabel.text = error.localizedDescription
                        delegate.recivedError(self, error:error)
                        self.applyButton.enabled = true
                    }
            })
        }
    }
    @IBAction func cancelPressed(sender: AnyObject) {
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        if self.isMemberOfClass(AddAndSelectCreditCardViewController) {
            typeImage.image = UIImage(named: "no_type_card_1" , inBundle: bundle, compatibleWithTraitCollection: nil)
        }else{
            typeImage.image = UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)
        }
        if let delegate = self.delegate{
            delegate.canceled()
        }
    }
    func nextPressed(sender: UIBarButtonItem){
        if creditCardNumberField.isFirstResponder(){
            dateField.becomeFirstResponder()
        } else if dateField.isFirstResponder(){
            cvvField.becomeFirstResponder()
        } else if cvvField.isFirstResponder(){
            zipField.becomeFirstResponder()
        }
    }
    internal func resetView(){
        creditCardNumberField.text = ""
        dateField.text = ""
        cvvField.text = ""
        zipField.text = ""
        
        setFieldInvalid(creditCardNumberField , invalid: false)
        setFieldInvalid(dateField , invalid: false)
        setFieldInvalid(cvvField , invalid: false)
        setFieldInvalid(zipField , invalid: false)
        errorLabel.text = ""
        setImageForType(.Unknown)
        self.resignFirstResponder()
    }
    //MARK: - overides
    override internal func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        creditCardNumberField.resignFirstResponder()
        dateField.resignFirstResponder()
        cvvField.resignFirstResponder()
        zipField.resignFirstResponder()
        return true
    }
    override internal func becomeFirstResponder() -> Bool {
        if creditCardNumberField.isFirstResponder() ||
            dateField.isFirstResponder() ||
            cvvField.isFirstResponder() ||
            zipField.isFirstResponder() {
            return true
        }
        creditCardNumberField.becomeFirstResponder()
        return true
    }
    
    //MARK: - private functions

    internal func setImageForType( type: CardType){
        let bundle =  MCViewController.getBundle( NSBundle(forClass: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .MasterCard:
            typeImage.image = UIImage(named: "master_small", inBundle: bundle, compatibleWithTraitCollection: nil)
            
        case .Visa:
            typeImage.image = UIImage(named: "visa_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Diners:
            typeImage.image = UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Discover:
            typeImage.image = UIImage(named: "discover_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Amex:
            typeImage.image = UIImage(named: "amex_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Diners:
            typeImage.image = UIImage(named: "diners_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .JCB:
            typeImage.image = UIImage(named: "jcb_small", inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Maestro:
            typeImage.image = UIImage(named: "maestro_small", inBundle: bundle, compatibleWithTraitCollection: nil)
            
            
        default:
            if self.isMemberOfClass(AddAndSelectCreditCardViewController) {
                typeImage.image = UIImage(named: "no_type_card_1" , inBundle: bundle, compatibleWithTraitCollection: nil)
            }else{
                typeImage.image = UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)
            }
        }
    }
    
    //sets the UI to show the field has an invalid value or not
    internal func setFieldInvalid(field: UITextField , invalid: Bool){
        let underline = underlineForField![field]
        underline?.backgroundColor = invalid ? UIColor.fieldUnderlineInvalid() : UIColor.fieldUnderline()
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor.fieldTextValid()
    }
    
    func updateAndCheckValid() -> Bool{
        let ( type , formated , ccValid , validLength) = CreditCardValidator.checkCardNumber(creditCardNumberField.text!)
        
        let valid = ccValid && validLength
        setFieldInvalid(creditCardNumberField , invalid: !valid)
        let dateValid = CreditCardValidator.isValidDate(dateField.text!)
        setFieldInvalid(dateField , invalid: !dateValid)
        let cvvValid = cvvField.text?.characters.count == 4 || cvvField.text?.characters.count == 3
        setFieldInvalid(cvvField , invalid: !cvvValid)
        
        
        let  txtToCheck = (zipField.text?.stringByReplacingOccurrencesOfString(" ", withString: ""))! // check without space
        let alphaNumeric = txtToCheck.rangeOfString("^[a-zA-Z0-9]+$", options: .RegularExpressionSearch) != nil
        let zipValid = txtToCheck.characters.count >= 3 && txtToCheck.characters.count <= 8 && alphaNumeric
        setFieldInvalid(zipField , invalid: !zipValid)
        
        
        return valid && dateValid && cvvValid && zipValid
    }
}

extension MCAddCreditCardViewController : UITextFieldDelegate{
    
    internal func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case creditCardNumberField:
            dateField.becomeFirstResponder()
        case dateField:
            cvvField.becomeFirstResponder()
            
        case cvvField:
            zipField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true;
    }
    
    internal func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate: NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        setFieldInvalid(textField,invalid: false)
        
        switch textField {
            
        case creditCardNumberField:
            //if the string is valid and we just want to go to next field then dont add new char and go to date
            let ( _ , _ , wasValid , wasValidLength) =  CreditCardValidator.checkCardNumber(  textField.text!)
            
            if wasValidLength && wasValid && string != ""{
                setFieldInvalid(textField, invalid: true)
                return false
            }
            if string == ""  && txtAfterUpdate.hasSuffix(" "){// if backspace and white spaces is last remove it
                textField.text = txtAfterUpdate.substringToIndex(txtAfterUpdate.length-1)
                return false
            }
            
            
            let ( type , formated , valid , validLength) =  CreditCardValidator.checkCardNumber(txtAfterUpdate as String)
            let maxLength = CreditCardValidator.maxLengthForType(type)
            setImageForType(type) // setting correct icon image
            if !valid && txtAfterUpdate.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count >= maxLength{//dont allow typing more if invalid
                return false
            }
            
            if valid && validLength{//if done move to next field
                textField.text = formated
                return false
            }
            textField.text = formated
            return false
            
        case dateField:
            
            
            let valid = CreditCardValidator.isValidDate(txtAfterUpdate as String)
            let month = txtAfterUpdate.componentsSeparatedByString("/")[0] as String
            if month.characters.count > 2 {
                return false
            }
            
            let firstChar = month[month.startIndex]
            
            if firstChar != "1" && firstChar != "0"{
                return false
            }
            if valid {
                textField.text = txtAfterUpdate as String
                return false
            }
            if txtAfterUpdate.length >= 8 { // and its not valid...
                //                setFieldInvalid(textField, invalid: true)
                return false
            }
            if txtAfterUpdate.length == 1 && string != "" && (txtAfterUpdate != "0" && txtAfterUpdate != "1"){// adding 0 to month if its not 1 or 2
                txtAfterUpdate = "0" + (txtAfterUpdate as String)
            }
            
            if txtAfterUpdate.length == 2 && !(string == "0" || string == "1" || string == "2" || string == ""){
                setFieldInvalid(textField, invalid: true)
                return false
            }
            if string == ""  && textField.text!.hasSuffix("/"){
                
                textField.text = txtAfterUpdate.substringToIndex(1)
                
                return false
            }else if txtAfterUpdate.length == 2 && string != ""{  // adding the slash
                txtAfterUpdate = (txtAfterUpdate as String) + "/"
            }
            textField.text = txtAfterUpdate as String
            return false
            
        case cvvField:
            let ( type , formated , valid , fullLength) =  CreditCardValidator.checkCardNumber(txtAfterUpdate as String)
            
            let maxLength =  4
            
            if textField.text?.characters.count == maxLength && string != ""{ // if we are just moving to next field
                
                return false
            }
            
            
            if txtAfterUpdate.length > maxLength{
                return false
            }
            if txtAfterUpdate.length == maxLength{
                textField.text = txtAfterUpdate as String
                return false
            }
            return true
            
        case zipField:
            
            
            if txtAfterUpdate.length > 8{
                return false
            }
            return true
        default:
            return true
        }
    }
    
    private func addNextButtonOnKeyboard(field: UITextField , action: Selector)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: action)
        
        let items = [flexSpace , done]
        
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
        
    }
    
    //this asumes the field passed validation
    internal func formatedString(field: UITextField) -> String{
        switch field {
        case creditCardNumberField:
            return (creditCardNumberField.text?.stringByReplacingOccurrencesOfString(" ", withString: ""))!
        case dateField:
            if dateField.text?.characters.count == 5 {
                let split = dateField.text?.characters.split("/").map(String.init)
                let year = "20" + split![1]
                return split![0] + "/" + year
            }
            return dateField.text!
        case cvvField:
            return cvvField.text!
        case zipField:
            return (zipField.text?.stringByReplacingOccurrencesOfString(" ", withString: ""))!
        default:
            return ""
        }
    }
    
    //this asumes the field passed validation
    internal func getType() -> CreditCardType {
        let ( type ,_ ,_,_) = CreditCardValidator.checkCardNumber(creditCardNumberField.text!)
        switch type {
        case .Visa:
            return CreditCardType.visa
        case .MasterCard:
            return CreditCardType.masterCard
        case .Discover:
            return CreditCardType.discover
        case .Amex:
            return CreditCardType.amex
        case .JCB:
            return CreditCardType.JCB
        case .Diners:
            return CreditCardType.diners
        case .Maestro:
            return CreditCardType.maestro

        default:
            return CreditCardType.unknown
        }
    }
   
    
    
}
