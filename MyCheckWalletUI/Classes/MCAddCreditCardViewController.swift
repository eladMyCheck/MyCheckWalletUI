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
}

internal class MCAddCreditCardViewController: MCViewController {
    
    @IBOutlet var typeImage: UIImageView!
    @IBOutlet var creditCardNumberField: UITextField!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var cvvField: UITextField!
    @IBOutlet var zipField: UITextField!
    
    @IBOutlet var creditCardUnderline: UIView!
    @IBOutlet var dateUnderline: UIView!
    @IBOutlet var cvvUnderline: UIView!
    @IBOutlet var zipUnderline: UIView!
    var underlineForField : [UITextField : UIView]?
    //MARK: - life cycle functions
    
    override func viewDidLoad() {
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
            
        }
    }
    @IBAction func cancelPressed(sender: AnyObject) {
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
    //MARK: - private functions
    
    func setImageForType( type: CardType){
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
            
            
        default:
            typeImage.image = UIImage(named: "no_type_card" , inBundle: bundle, compatibleWithTraitCollection: nil)
        }
    }
    
    //sets the UI to show the field has an invalid value or not
    private func setFieldInvalid(field: UITextField , invalid: Bool){
        let underline = underlineForField![field]
        underline?.backgroundColor = invalid ? UIColor.fieldUnderlineInvalid() : UIColor.fieldUnderline()
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor.fieldTextValid()
    }
    
    func updateAndCheckValid() -> Bool{
        let ( type , formated , ccValid , validLength) = CreditCardValidator.checkCardNumber(creditCardNumberField.text!)
        
        var valid = ccValid && validLength
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate: NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        setFieldInvalid(textField,invalid: false)
        
        switch textField {
            
        case creditCardNumberField:
            //if the string is valid and we just want to go to next field then dont add new char and go to date
            let ( _ , _ , wasValid , wasValidLength) =  CreditCardValidator.checkCardNumber(  textField.text!)
            
            if wasValidLength && wasValid && string != ""{
                
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
            if valid {
                textField.text = txtAfterUpdate as String
                return false
            }
            if txtAfterUpdate.length >= 7 { // and its not valid...
                //                setFieldInvalid(textField, invalid: true)
                return false
            }
            if txtAfterUpdate.length == 1 && string != "" && (txtAfterUpdate != "0" && txtAfterUpdate != "1"){// adding 0 to month if its not 1 or 2
                txtAfterUpdate = "0" + (txtAfterUpdate as String)
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
        var doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: action)
        
        var items = [flexSpace , done]
        
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
        
    }
}
