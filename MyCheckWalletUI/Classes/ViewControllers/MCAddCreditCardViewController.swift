//
//  MCAddCreditCardViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
import MyCheckCore

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
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navbar: UIView!
    internal var underlineForField : [UITextField : UIView]?
    internal var activityView : UIActivityIndicatorView!
    
    @IBOutlet weak var doNotStoreSuperview: UIView!
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
        nc.addObserver(self, selector: #selector(MCAddCreditCardViewController.setupUI), name: NSNotification.Name(rawValue: Wallet.loggedInNotification), object: nil)
        
    }
    internal static func instantiate(_ delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController{
        
        let storyboard = MCViewController.getStoryboard(  Bundle(for: self.classForCoder()))
        let controller = storyboard.instantiateViewController(withIdentifier: "MCAddCreditCardViewController") as! MCPaymentMethodsViewController
        
        controller.delegate = delegate
        
        return controller
    }
    
    
//    @IBAction func backPressed(_ sender: Any) {
//        self.delegate?.backPressed()
//
//    }
    
    
    //MARK: - actions
    @IBAction func checkboxPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
    }
    @IBAction func ApplyPressed(_ sender: AnyObject) {
        let validator = updateAndCheckValid()
        if validator.CreditDetailsValid{
            self.showActivityIndicator(true)
            
            let dateStr = formatedString(dateField)
            let split = dateStr.characters.split(separator: "/").map(String.init)
            applyButton.isEnabled = false
            cancelBut.isEnabled = false
            self.creditCardNumberField.isUserInteractionEnabled = false
            self.dateField.isUserInteractionEnabled = false
            self.cvvField.isUserInteractionEnabled = false
            self.zipField.isUserInteractionEnabled = false
            Wallet.shared.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: validator.cardType, isSingleUse: checkbox.isSelected, success: {  token in
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
        setImageForType(type: .Unknown)
        self.resignFirstResponder()
    }
    //MARK: - overides
  @discardableResult
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
//        if let backBut = backButton{
//        backBut.kf.setImage(with: LocalData.manager.getBackButtonImageURL(), for: .normal , options:[.scaleFactor(3.0)])
//        }
        
        //setting colors
        if let navbar = navbar{
          navbar.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorsheaderBackground", fallback: navbar.backgroundColor!)
        }
        errorLabel.textColor = LocalData.manager.getColor("addCreditColorsinputError", fallback: errorLabel.textColor!)
        applyButton.backgroundColor = LocalData.manager.getColor("addCreditColorsapplyBackgroundColor", fallback: UIColor.white)
        applyButton.layer.cornerRadius = 8
        applyButton.setTitleColor(LocalData.manager.getColor("addCreditColorsapplyButtonText", fallback: UIColor.white), for: UIControlState())
        cancelBut.layer.cornerRadius = 8
        
        cancelBut.backgroundColor = LocalData.manager.getColor("addCreditColorscancelColor", fallback: UIColor.white)
        cancelBut.setTitleColor(LocalData.manager.getColor("addCreditColorscancelButtonText", fallback: UIColor.white), for: UIControlState())
        
        
        for (field , underline) in underlineForField!{
            field.textColor = LocalData.manager.getColor("addCreditColorsfieldText", fallback: field.textColor!)
            field.placeholderColor(LocalData.manager.getColor("addCreditColorshintTextColor" , fallback: UIColor.lightGray))
            
            underline.backgroundColor = UIColor.fieldUnderline()
            //value.backgroundColor = LocalData.manager.getColor("addCreditColorsinputError", fallback: value.backgroundColor!)
        }
        
        doNotStoreSuperview.isHidden = !LocalData.manager.doNotStoreEnabled()
        
    }
   
    
   
    
    
    //sets the UI to show the field has an invalid value or not
    internal func setFieldInvalid(_ field: UITextField , invalid: Bool){
        let underline = underlineForField![field]
        underline?.backgroundColor = invalid ? UIColor.fieldUnderlineInvalid() : UIColor.fieldUnderline()
        field.textColor = invalid ? UIColor.fieldTextInvalid() : UIColor.fieldTextValid()
    }
    
    func updateAndCheckValid() -> CreditCardValidator{
let validator = CreditCardValidator(cardNumber: creditCardNumberField.text, DOB: dateField.text, CVV: cvvField.text, ZIP: zipField.text)
        setFieldInvalid(creditCardNumberField , invalid: !validator.numberIsCompleteAndValid)
        setFieldInvalid(dateField , invalid: !validator.DOBIsValid)
        setFieldInvalid(cvvField , invalid: !validator.CVVIsValid)
        setFieldInvalid(zipField , invalid: !validator.ZIPIsValid)
        
        
        return validator
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
           
            if string == ""  && txtAfterUpdate.hasSuffix(" "){// if backspace and white spaces is last remove it
                textField.text = txtAfterUpdate.substring(to: txtAfterUpdate.length-1)
                return false
            }
            
            
            let validator =  CreditCardValidator(cardNumber: txtAfterUpdate as String)
            
            setImageForType(type: validator.cardType)
            if !validator.numberHasvalidFormat && validator.reachedMaxCardLength{//dont allow typing more if invalid
                return false
            }
            
            if validator.numberIsCompleteAndValid{//if done move to next field
                textField.text = validator.formattedCardNumber
                return false
            }
            textField.text = validator.formattedCardNumber
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
            
            let valid = CreditCardValidator(DOB:txtAfterUpdate as String).DOBIsValid
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
  //sets the image to the correct credit card type
  internal func setImageForType(type: CreditCardType){
    guard let url = type.smallImageURL() else{
      let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))

      if self.isMember(of: MCCheckoutViewController.self) {
        typeImage.image = UIImage(named: "no_type_card_1" , in: bundle, compatibleWith: nil)
      }else{
        typeImage.image = UIImage(named: "no_type_card" , in: bundle, compatibleWith: nil)
      }
      return
    }
    

    typeImage.kf.setImage(with: url)

  }
}

fileprivate extension CreditCardType{
  fileprivate func smallImageURL() -> URL?{
    // let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    switch self {
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
      
      return nil
    }
  }

}

