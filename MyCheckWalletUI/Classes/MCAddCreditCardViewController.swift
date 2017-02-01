//
//  MCAddCreditCardViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
///A protocol that will allow the owner to dismiss the ViewController
internal protocol MCAddCreditCardViewControllerDelegate : class{
    func recivedError(_ controller: MCAddCreditCardViewController , error:NSError)
    func addedNewPaymentMethod(_ controller: MCAddCreditCardViewController ,token:String)
    func canceled()
}

open class MCAddCreditCardViewController: MCViewController {
    @IBOutlet weak var errorHeight: NSLayoutConstraint!
    
 internal weak var containerHeight: NSLayoutConstraint?
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!

    @IBOutlet internal weak var applyButton: UIButton!
    @IBOutlet internal var typeImage: UIImageView!
    @IBOutlet internal var creditCardNumberField: UITextField!
    @IBOutlet internal var dateField: UITextField!
    @IBOutlet internal var cvvField: UITextField!
    @IBOutlet internal var zipField: UITextField!
    @IBOutlet weak var cancelBut: UIButton!
    
    @IBOutlet internal var creditCardUnderline: UIView!
    @IBOutlet internal var dateUnderline: UIView!
    @IBOutlet internal var cvvUnderline: UIView!
    @IBOutlet internal var zipUnderline: UIView!
    @IBOutlet internal weak var errorLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    internal var underlineForField : [UITextField : UIView]?
    internal var activityView : UIActivityIndicatorView!
    
    weak  var delegate : MCAddCreditCardViewControllerDelegate?
    //MARK: - life cycle functions
    
    override  open func viewDidLoad() {
        super.viewDidLoad()
        underlineForField = [creditCardNumberField : creditCardUnderline , dateField : dateUnderline , cvvField : cvvUnderline , zipField : zipUnderline]
        
        addNextButtonOnKeyboard(creditCardNumberField, action: #selector(nextPressed(_: )))
        addNextButtonOnKeyboard(dateField, action: #selector(nextPressed(_: )))
        addNextButtonOnKeyboard(cvvField, action: #selector(nextPressed(_: )))
        
        //setting up UI and updating it if the user logges in... just incase
        setupUI()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MCAddCreditCardViewController.setupUI), name: NSNotification.Name(rawValue: MyCheckWallet.loggedInNotification), object: nil)
        
    }
    internal static func instantiate(_ delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController{
        
        let storyboard = MCViewController.getStoryboard(  Bundle(for: self.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: "MCAddCreditCardViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        
        return controller
    }
    
    
    
    
    //MARK: - actions
    @IBAction func checkboxPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
    }
    @IBAction func ApplyPressed(_ sender: AnyObject) {
        
        if updateAndCheckValid(){
            self.showActivityIndicator(true)
            let (type ,_,_,_) = CreditCardValidator.checkCardNumber(creditCardNumberField.text!)
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split(separator: "/").map(String.init)
            applyButton.isEnabled = false
            cancelBut.isEnabled = false
            self.creditCardNumberField.isUserInteractionEnabled = false
            self.dateField.isUserInteractionEnabled = false
            self.cvvField.isUserInteractionEnabled = false
            self.zipField.isUserInteractionEnabled = false
            MyCheckWallet.manager.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: type, isSingleUse: checkbox.isSelected, success: {  token in
                self.showActivityIndicator(false)
                if let delegate = self.delegate{
                    
                    delegate.addedNewPaymentMethod(self, token:"")
                    self.applyButton.isEnabled = true
                    self.cancelBut.isEnabled = true
                    self.creditCardNumberField.isUserInteractionEnabled = true
                    self.dateField.isUserInteractionEnabled = true
                    self.cvvField.isUserInteractionEnabled = true
                    self.zipField.isUserInteractionEnabled = true
                }
            }, fail: { error in
                self.showActivityIndicator(false)
                if let delegate = self.delegate{
                    self.showError(errorStr: error.localizedDescription)
                    delegate.recivedError(self, error:error)
                    self.applyButton.isEnabled = true
                    self.cancelBut.isEnabled = true
                    self.creditCardNumberField.isUserInteractionEnabled = true
                    self.dateField.isUserInteractionEnabled = true
                    self.cvvField.isUserInteractionEnabled = true
                    self.zipField.isUserInteractionEnabled = true
                }
            })
        }
    }
    @IBAction func cancelPressed(_ sender: AnyObject) {
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        if self.isMember(of: MCCheckoutViewController.self) {
            typeImage.image = UIImage(named: "no_type_card_1" , in: bundle, compatibleWith: nil)
        }else{
            typeImage.image = UIImage(named: "no_type_card" , in: bundle, compatibleWith: nil)
        }
        if let delegate = self.delegate{
            delegate.canceled()
        }
    }
    func nextPressed(_ sender: UIBarButtonItem){
        if creditCardNumberField.isFirstResponder{
            dateField.becomeFirstResponder()
        } else if dateField.isFirstResponder{
            cvvField.becomeFirstResponder()
        } else if cvvField.isFirstResponder{
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
        checkbox.isSelected = false
        setImageForType(.Unknown)
        self.resignFirstResponder()
    }
    //MARK: - overides
    override open func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        creditCardNumberField.resignFirstResponder()
        dateField.resignFirstResponder()
        cvvField.resignFirstResponder()
        zipField.resignFirstResponder()
        return true
    }
    override open func becomeFirstResponder() -> Bool {
        if creditCardNumberField.isFirstResponder ||
            dateField.isFirstResponder ||
            cvvField.isFirstResponder ||
            zipField.isFirstResponder {
            return true
        }
        creditCardNumberField.becomeFirstResponder()
        return true
    }
    
    //MARK: - private functions
    internal func setupUI(){
        self.creditCardNumberField.placeholder = LocalData.manager.getString("addCreditcardNumPlaceHoldar")
        self.cvvField.placeholder = LocalData.manager.getString("addCreditcvvPlaceholder" , fallback: self.cvvField.placeholder)
        self.dateField.placeholder = LocalData.manager.getString("addCreditcardDatePlaceHoldar" , fallback: self.dateField.placeholder)
        self.zipField.placeholder = LocalData.manager.getString("addCreditzipPlaceHolder" , fallback: self.zipField.placeholder)
        applyButton.setTitle( LocalData.manager.getString("addCreditapplyAddingCardButton" , fallback: self.applyButton.title(for: UIControlState())) , for: UIControlState())
        applyButton.setTitle( LocalData.manager.getString("addCreditapplyAddingCardButton" , fallback: self.applyButton.title(for: UIControlState())) , for: .highlighted)
        
        cancelBut.setTitle( LocalData.manager.getString("addCreditcancelAddingCardButton" , fallback: self.cancelBut.title(for: UIControlState())) , for: UIControlState())
        cancelBut.setTitle( LocalData.manager.getString("addCreditcancelAddingCardButton" , fallback: self.cancelBut.title(for: UIControlState())) , for: .highlighted)
        
        //setting colors
        navBar.barTintColor = LocalData.manager.getColor("managePaymentMethodsColorsheaderBackground", fallback: navBar.backgroundColor!)
        
        errorLabel.textColor = LocalData.manager.getColor("addCreditColorsinputError", fallback: errorLabel.textColor!)
        applyButton.backgroundColor = LocalData.manager.getColor("addCreditColorsapplyBackgroundColor", fallback: UIColor.white)
        applyButton.layer.cornerRadius = 8
        applyButton.setTitleColor(LocalData.manager.getColor("addCreditColorsapplyButtonText", fallback: UIColor.white), for: UIControlState())
        cancelBut.layer.cornerRadius = 8
        
        cancelBut.backgroundColor = LocalData.manager.getColor("addCreditColorscancelColor", fallback: UIColor.white)
        cancelBut.setTitleColor(LocalData.manager.getColor("addCreditColorscancelButtonText", fallback: UIColor.white), for: UIControlState())
        
        
        for (key , value) in underlineForField!{
            key.textColor = LocalData.manager.getColor("addCreditColorsfieldText", fallback: key.textColor!)
            key.placeholderColor(LocalData.manager.getColor("addCreditColorshintTextColor" , fallback: UIColor.lightGray))
            value.backgroundColor = LocalData.manager.getColor("addCreditColorsinputError", fallback: value.backgroundColor!)
        }
    }
    internal func setImageForType( _ type: CreditCardType){
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        
        if type == .Unknown {
            if self.isMember(of: MCCheckoutViewController.self) {
                typeImage.image = UIImage(named: "no_type_card_1" , in: bundle, compatibleWith: nil)
            }else{
                typeImage.image = UIImage(named: "no_type_card" , in: bundle, compatibleWith: nil)
            }
        }else{
            
            typeImage.kf.setImage(with:imageURL(type))}
    }
    
    internal func imageURL( _ type: CreditCardType) -> URL?{
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        switch type {
        case .MasterCard:
            return URL(string:  LocalData.manager.getString("addCreditImagesmastercard"))!
        case .Visa:
            return URL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        case .Diners:
            return URL(string:  LocalData.manager.getString("addCreditImagesdinersclub"))!
        case .Discover:
            return URL(string:  LocalData.manager.getString("addCreditImagesdiscover"))!
        case .Amex:
            return URL(string:  LocalData.manager.getString("addCreditImagesamex"))!
        case .JCB:
            return URL(string:  LocalData.manager.getString("addCreditImagesJCB"))!
        case .Maestro:
            return URL(string:  LocalData.manager.getString("addCreditImagesmaestro"))!
            
        default:
            return URL(string:  LocalData.manager.getString("addCreditImagesvisa"))!
        }
    }
    
    
    //sets the UI to show the field has an invalid value or not
    internal func setFieldInvalid(_ field: UITextField , invalid: Bool){
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
        
        
        let  txtToCheck = (zipField.text?.replacingOccurrences(of: " ", with: ""))! // check without space
        let alphaNumeric = txtToCheck.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
        let zipValid = txtToCheck.characters.count >= 3 && txtToCheck.characters.count <= 8 && alphaNumeric
        setFieldInvalid(zipField , invalid: !zipValid)
        
        
        return valid && dateValid && cvvValid && zipValid
    }
}

extension MCAddCreditCardViewController : UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate: NSString = textField.text! as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        setFieldInvalid(textField,invalid: false)
        
        switch textField {
            
        case creditCardNumberField:
            //if the string is valid and we just want to go to next field then dont add new char and go to date
            let ( _ , _ , wasValid , wasValidLength) =  CreditCardValidator.checkCardNumber(  textField.text!)
            
            //            if wasValidLength && wasValid && string != ""{
            //                return false
            //            }
            if string == ""  && txtAfterUpdate.hasSuffix(" "){// if backspace and white spaces is last remove it
                textField.text = txtAfterUpdate.substring(to: txtAfterUpdate.length-1)
                return false
            }
            
            
            let ( type , formated , valid , validLength) =  CreditCardValidator.checkCardNumber(txtAfterUpdate as String)
            let maxLength = CreditCardValidator.maxLengthForType(type)
            setImageForType(type) // setting correct icon image
            if !valid && txtAfterUpdate.replacingOccurrences(of: " ", with: "").characters.count >= maxLength{//dont allow typing more if invalid
                return false
            }
            
            if valid && validLength{//if done move to next field
                textField.text = formated
                return false
            }
            textField.text = formated
            return false
            
        case dateField:
            if txtAfterUpdate == "00" {
                return false
            }
            if txtAfterUpdate.length == 1 && string != "" && (txtAfterUpdate != "0" && txtAfterUpdate != "1"){// adding 0 to month if its not 1 or 2
                txtAfterUpdate = ("0" + (txtAfterUpdate as String)) as NSString
            }
            if txtAfterUpdate.length == 2 && string != "" && (txtAfterUpdate.intValue > 12 ){// adding 0 to month if its not > 12
                txtAfterUpdate = "0" + (txtAfterUpdate.substring(to: 1) as String) + "/" + (txtAfterUpdate.substring(from: 1) as String) as NSString
            }
            
            let valid = CreditCardValidator.isValidDate(txtAfterUpdate as String)
            let month = txtAfterUpdate.components(separatedBy: "/")[0] as String
            if month.characters.count > 2 {
                return false
            }
            
            if month.characters.count > 0 {
                let firstChar = month[month.startIndex]
                
                if firstChar != "1" && firstChar != "0"{
                    return false
                }
            }
            
            if valid {
                textField.text = txtAfterUpdate as String
                return false
            }
            if txtAfterUpdate.length >= 8 { // and its not valid...
                //                setFieldInvalid(textField, invalid: true)
                return false
            }
            
            
            //            if txtAfterUpdate.length == 2 && !(string == "0" || string == "1" || string == "2" || string == ""){
            //                setFieldInvalid(textField, invalid: true)
            //                return false
            //            }
            if string == ""  && textField.text!.hasSuffix("/"){
                
                textField.text = txtAfterUpdate.substring(to: 1)
                
                return false
            }else if txtAfterUpdate.length == 2 && string != ""{  // adding the slash
                txtAfterUpdate = ((txtAfterUpdate as String) + "/") as NSString
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
    
    fileprivate func addNextButtonOnKeyboard(_ field: UITextField , action: Selector)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: action)
        
        let items = [flexSpace , done]
        
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        field.inputAccessoryView = doneToolbar
        
    }
    
    //this asumes the field passed validation
    internal func formatedString(_ field: UITextField) -> String{
        switch field {
        case creditCardNumberField:
            return (creditCardNumberField.text?.replacingOccurrences(of: " ", with: ""))!
        case dateField:
            if dateField.text?.characters.count == 5 {
                let split = dateField.text?.characters.split(separator: "/").map(String.init)
                let year = "20" + split![1]
                return split![0] + "/" + year
            }
            return dateField.text!
        case cvvField:
            return cvvField.text!
        case zipField:
            return (zipField.text?.replacingOccurrences(of: " ", with: ""))!
        default:
            return ""
        }
    }
    
    fileprivate func showError(errorStr: String){
        self.errorLabel.text = errorStr
        if errorStr.characters.count == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.errorHeight.constant = 0
                self.view.layoutIfNeeded()
                if let containerHeight =  self.containerHeight{
                containerHeight.constant = 250.0
                }
                if let parent = self.parent {
                parent.view.layoutIfNeeded()
                }

            })
            return;
        }
        self.errorLabel.alpha = 0.0
        //animating the error view in ... showing the error for a few seconds and removing again
        
        UIView.animate(withDuration: 0.3, animations:  {
            self.errorHeight.constant = 25.0
            if let containerHeight =  self.containerHeight{
             containerHeight.constant = 275.0
            }
             self.errorLabel.alpha = 1.0
            self.parent?.view.layoutIfNeeded()
            
            self.view.layoutIfNeeded()
            
            delay(0.3 + LocalData.manager.getDouble("ValueserrorTime", fallback: 7.0)){
                UIView.animate(withDuration: 0.3, animations: {
                    self.errorHeight.constant = 0
                    if let containerHeight =  self.containerHeight{
                    containerHeight.constant = 250.0
                    }
                     self.errorLabel.alpha = 0.0
                    self.view.layoutIfNeeded()
                    if let parent = self.parent {

                    parent.view.layoutIfNeeded()
                    }
                } , completion: { finished in
                    self.errorLabel.text  = ""

                })
            }
        }, completion: { finished in
        
        })
    }
    
    func showActivityIndicator(_ show: Bool) {
        if activityView == nil {
            activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            
            activityView.center=CGPoint(x: self.view.center.x, y: self.view.center.y + 104)
            activityView.startAnimating()
            self.view.addSubview(activityView)
            
        }
        activityView.isHidden = !show
    }
    
}
