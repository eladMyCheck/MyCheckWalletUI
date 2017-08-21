//
//  MCCheckoutViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/3/16.
//
//

import UIKit
import MyCheckCore
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
  public var selectedMethod : PaymentMethodInterface?
  
  ///The delegate that will be updated with MCCheckoutViewController height changes
  open var checkoutDelegate : CheckoutDelegate?
  
  //Outlets
  @IBOutlet weak fileprivate  var paymentSelectorView: UIView!
  
  @IBOutlet weak  fileprivate  var acceptedCreditCardsViewTopToCreditCardFieldConstraint: NSLayoutConstraint!
  @IBOutlet weak var acceptedCreditCardsViewTopToCollapsableViewConstraint: NSLayoutConstraint!
  @IBOutlet weak fileprivate var paymentMethodSelectorTextField: UITextField!
  @IBOutlet weak fileprivate var colapsableContainer: UIView!
  @IBOutlet weak fileprivate var cancelButton: UIButton!
  @IBOutlet fileprivate var textFieldsBorderViews: [UIView]!
  @IBOutlet weak fileprivate var managePaymentMethodsButton: UIButton!
  fileprivate var paymentMethodSelector : UIPickerView = UIPickerView()
  fileprivate var paymentMethods: Array<PaymentMethodInterface>! = []
  
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
  
  @IBOutlet weak var acceptedCardSuperview: UIView!
  @IBOutlet weak fileprivate var header: UILabel!
  @IBOutlet weak fileprivate var dropdownHeader: UILabel!
  @IBOutlet weak fileprivate var footerLabel: UILabel!
  
  @IBOutlet weak fileprivate var headerLineBG: UIView!
  @IBOutlet weak fileprivate var pickerDownArrow: UIImageView!
  
  //3rd party wallet payment methods UI elements
  @IBOutlet weak fileprivate var walletsSuperview: UIView!
  @IBOutlet weak fileprivate var walletsHeight: NSLayoutConstraint!
  
  @IBOutlet weak fileprivate var deleteBut: UIButton!
  
  @IBOutlet weak fileprivate var firstLineWalletButs: UIStackView!
  @IBOutlet weak fileprivate var pciLabel: UILabel!
  
  fileprivate var walletButtons : [PaymentMethodButtonRapper] = []
  internal var borderForField : [UITextField : UIView] = [:]
  
  internal static func createMCCheckoutViewController() -> MCCheckoutViewController{
    return MCCheckoutViewController.init()
  }
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(Bundle(for: MCCheckoutViewController.self)))
  }
  
  //MARK - Initiaters
  
  ///The preferred costructor to be used in order to create the View Controller
  init(){
    super.init(nibName: "CheckoutViewController", bundle: MCViewController.getBundle(Bundle(for: MCCheckoutViewController.self)))
    
  }
  required convenience public init?(coder aDecoder: NSCoder) {
    self.init()
  }
  
  //MARK - Lifecycle functions
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    self.configureUI()
    self.assignImages()
    if paymentMethods.count > 0 {
      selectedMethod = paymentMethods[0]
    }
    borderForField = [creditCardNumberField : creditCardBorderView, dateField : dateFieldBorderView, cvvField : cvvBorderView, zipField : zipFieldBorderView]
    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(MCCheckoutViewController.receivedPaymentMethodsUpdateNotification), name: NSNotification.Name(rawValue: Wallet.refreshPaymentMethodsNotification), object: nil)
    
    //setting up UI and updating it if the user logges in... just incase
    Wallet.shared.configureWallet(success: {
      self.setupUI()
      self.refreshPaymentMethods()
      
    }, fail: nil)
    
    nc.addObserver(self, selector: #selector(MCCheckoutViewController.setupUI), name: NSNotification.Name(rawValue: Wallet.loggedInNotification), object: nil)
    nc.addObserver(self, selector:#selector(MCCheckoutViewController.assignImages), name:NSNotification.Name(rawValue: "acceptedCardsCheckoutSet"), object: nil)
    
    
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.resetFields()
    Wallet.shared.factoryDelegate = self
    checkbox.isSelected = false
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
  }
  
  //MARK: - private methods
  
  @objc fileprivate func assignImages(){
    let cardsImages = LocalData.manager.getArray("acceptedCardsCheckout")
    let wrapper = UIView()
    wrapper.translatesAutoresizingMaskIntoConstraints = false
    acceptedCardSuperview.addSubview(wrapper)
    
    let horizontalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: acceptedCardSuperview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
    let verticalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: acceptedCardSuperview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 32)
    let heightConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 26)
    let width = cardsImages.count*48
    let widthConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(width))
    acceptedCardSuperview.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
    
    for card in cardsImages {
      let index = cardsImages.index(of: card)
      let iv = UIImageView(frame: CGRect(x: 48*index!+5, y: 0, width: 38, height: 24))
      iv.kf.setImage(with: URL(string: card))
      wrapper.addSubview(iv)
    }
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
    self.paymentMethodSelectorTextField.text = self.selectedMethod!.description
    if let selectedMethod = selectedMethod {
      selectedMethod.setupMethodImage(for: self.typeImage)
      showDeleteBut(show: selectedMethod.isSingleUse)
      
    }
    self.view.endEditing(true)
  }
  
  
  
  
  func configureUI(){
    
    creditCardNumberField.attributedPlaceholder = NSAttributedString(string:LocalData.manager.getString("addCreditcardNumPlaceHoldar" ,fallback: "1234 1234 1234 1234"), attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
    dateField.attributedPlaceholder = NSAttributedString(string:LocalData.manager.getString("addCreditcardDatePlaceHoldar" ,fallback: dateField.placeholder), attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
    cvvField.attributedPlaceholder = NSAttributedString(string:LocalData.manager.getString("addCreditcvvPlaceholder" , fallback: self.cvvField.placeholder), attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
    zipField.attributedPlaceholder = NSAttributedString(string:LocalData.manager.getString("addCreditzipPlaceHolder" , fallback: self.zipField.placeholder), attributes:[NSForegroundColorAttributeName: UIColor(r: 255, g: 255, b: 255, a: 0.33)])
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
        self.paymentMethodSelectorTextField.text = self.selectedMethod!.description
        
        self.paymentMethods.first!.setupMethodImage(for: self.typeImage)
        showDeleteBut(show: self.paymentMethods.first!.isSingleUse)
        
        
      }else{
        let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        typeImage.image = UIImage(named: "no_type_card_1" , in: bundle, compatibleWith: nil)!
        creditCardNumberField.isHidden = false
        self.paymentSelectorView.isHidden = true
        
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
  
  @objc fileprivate func receivedPaymentMethodsUpdateNotification(notification: NSNotification){
    refreshPaymentMethods()
  }
  fileprivate func refreshPaymentMethods(defaultMethod: PaymentMethodInterface? = nil ){
    Wallet.shared.getPaymentMethods(success: { (methods) in
      self.paymentMethods = methods
      if methods.count == 0 {
        self.selectedMethod = nil
      }else if let defaultMethod = defaultMethod {
        for method in methods{
          if method.ID == defaultMethod.ID{
            self.selectedMethod = method
            break;
          }
        }
        //will be reached only if the token is not found
        self.selectedMethod = methods.first
        
        
      }else {
        self.selectedMethod = methods.first
        
      }
      self.configureUI()
    }) { (error) in
      
    }
  }
  
  @IBAction func deletePressed(_ sender: UIButton) {
    if let method = self.selectedMethod{
      Wallet.shared.deletePaymentMethod(method, success: {
        self.refreshPaymentMethods()
      }, fail: { (error) in
        printIfDebug("did not delete payment")
        self.showError(errorStr: error.localizedDescription)
        
      })
    }
  }
  @IBAction func managePaymentMethodsButtonPressed(_ sender: UIButton) {
    
    guard let controller =   MCPaymentMethodsViewController.createPaymentMethodsViewController(self) else{
      printIfDebug("cannot display VC since user is not logged in")
      
      return
    }
    
    self.present(controller, animated: true, completion: nil)
    controller.delegate = self
    
  }
  
//  override internal func setFieldInvalid(_ field: UITextField , invalid: Bool){
//    let badColor = LocalData.manager.getColor("checkoutPageColorserrorInput", fallback: UIColor.red)
//    let goodColor = LocalData.manager.getColor("checkoutPageColorsfieldBorder", fallback: creditCardNumberField.textColor!)
//    
//    let border = borderForField[field]
//    border?.layer.borderColor = invalid ? badColor.cgColor :goodColor.cgColor
//    field.textColor = invalid ? badColor : UIColor(r: 255, g: 255, b: 255, a: 1)
//  }
//  
//  internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//    switch textField {
//    case creditCardNumberField:
//      UIView.animate(withDuration: 0.4, animations: {
//        self.moveAcceptedCreditCardsViewToCreditCardField(false, animated: true)
//      })
//      break
//    case paymentMethodSelectorTextField:
//      break
//    default:
//      return true
//    }
//    
//    return true
//  }
//  
//  @IBAction override func checkboxPressed(_ sender: UIButton) {
//    self.checkbox.isSelected = !self.checkbox.isSelected
//  }
//  
//  @IBAction func cancelButPressed(_ sender: AnyObject) {
//    super.cancelPressed(sender)
//    self.resetFields()
//    self.view.endEditing(true)
//    UIView.animate(withDuration: 0.4, animations: {
//      self.moveAcceptedCreditCardsViewToCreditCardField(true , animated: true)
//    })
//  }
//  @IBAction func applyButPressed(_ sender: AnyObject) {
//    let validator = updateAndCheckValid()
//    if validator.numberIsCompleteAndValid{
//      self.view.endEditing(true)
//      
//      
//      
//      let dateStr = formatedString(dateField)
//      let split = dateStr.characters.split(separator: "/").map(String.init)
//      self.showActivityIndicator( true)
//      self.applyButton.isEnabled = false
//      self.cancelButton.isEnabled = false
//      
//      self.creditCardNumberField.isUserInteractionEnabled = false
//      self.dateField.isUserInteractionEnabled = false
//      self.cvvField.isUserInteractionEnabled = false
//      self.zipField.isUserInteractionEnabled = false
//      Wallet.shared.addCreditCard(formatedString(creditCardNumberField), expireMonth: split[0], expireYear: split[1], postalCode: formatedString(zipField), cvc: formatedString(cvvField), type: validator.cardType, isSingleUse: self.checkbox.isSelected, success: {  method in
//        self.resetFields()
//        // self.selectedMethod = method
//        
//        if method.isSingleUse == true{
//          
//          
//          self.moveAcceptedCreditCardsViewToCreditCardField(true, animated: false)
//          
//        }
//        self.newPaymenteMethodAdded()
//        
//        self.creditCardNumberField.isUserInteractionEnabled = true
//        self.dateField.isUserInteractionEnabled = true
//        self.cvvField.isUserInteractionEnabled = true
//        self.zipField.isUserInteractionEnabled = true
//        self.applyButton.isEnabled = true
//        self.cancelButton.isEnabled = true
//        self.showActivityIndicator(false)
//      }, fail: { error in
//        self.applyButton.isEnabled = true
//        self.cancelButton.isEnabled = true
//        self.creditCardNumberField.isUserInteractionEnabled = true
//        self.dateField.isUserInteractionEnabled = true
//        self.cvvField.isUserInteractionEnabled = true
//        self.zipField.isUserInteractionEnabled = true
//        self.showActivityIndicator(false)
//        //   self.errorLabel.text = error.localizedDescription
//        self.showError(errorStr: error.localizedDescription)
//        if let delegate = self.delegate{
//          delegate.recivedError(self, error:error)
//        }
//      })
//    }
//    
//  }
//  
//  override func showActivityIndicator(_ show: Bool) {
//    if activityView == nil{
//      activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
//      
//      activityView.center=CGPoint(x: self.view.center.x, y: self.view.center.y)
//      activityView.startAnimating()
//      activityView.hidesWhenStopped = true
//      self.view.addSubview(activityView)
//    }
//    show ? activityView.startAnimating() : activityView.stopAnimating()
//  }
  
  func newPaymenteMethodAdded(){
    Wallet.shared.getPaymentMethods(success: { (methods) in
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
    let baseHeight = 296.0 as Float
    self.acceptedCreditCardsViewTopToCreditCardFieldConstraint.priority = move ? 999 : 1
    self.acceptedCreditCardsViewTopToCollapsableViewConstraint.priority = move ? 1 : 999
    
    var delta = move ? baseHeight : baseHeight + 111.0
    if Wallet.shared.factories.count > 0 { // if we have factories we need to allow more room for the wallet buttons
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
//    self.setFieldInvalid(self.creditCardNumberField, invalid: false)
//    self.setFieldInvalid(self.dateField, invalid: false)
//    self.setFieldInvalid(self.cvvField, invalid: false)
//    self.setFieldInvalid(self.zipField, invalid: false)
  }
  fileprivate func showDeleteBut(show: Bool){
    deleteBut.isHidden = !show // button should be displayed only for single use methods
    pickerDownArrow.isHidden = show
  }
  @objc internal override func setupUI(){
    deleteBut.setTitleColor(LocalData.manager.getColor("checkoutPageColorsdeleteButton" , fallback: deleteBut.titleColor(for: .normal)!), for: .normal )
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
    for (_ , view) in borderForField {
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
    if (walletButtons.count == 0 && Session.shared.isLoggedIn()) {
      switch Wallet.shared.factories.count {
      case 0:
        walletsHeight.constant = 30
        walletsSuperview.isHidden = true
        // case 1:
        //   //adding button to center of container
        //  let factory = Wallet.shared.factories[0]
        //  let but = factory.getSmallAddMethodButton()
        //  self.firstLineWalletButs.addArrangedSubview(but)
        //   but.translatesAutoresizingMaskIntoConstraints = false
        
        
      case 1,2:
        
        for factory in Wallet.shared.factories{
          
          let  butRap = factory.getSmallAddMethodButton()
          butRap.button.translatesAutoresizingMaskIntoConstraints = true
          
          
          //I am assuming their are 2 views in the stack view (one left most and one right most)they add padding to insure the size is correct and the items are centered.
          self.firstLineWalletButs.insertArrangedSubview(butRap.button, at: self.firstLineWalletButs.arrangedSubviews.count - 1)
          
          walletButtons.append(butRap)
          
          butRap.button.isEnabled = true
          butRap.button.isUserInteractionEnabled = true
          print( butRap.button.bounds , "    " , butRap.button.frame)
          
        }
        
        
        
        
        
      default:break// multiple wallets
//        for factory in Wallet.shared.factories{
//          //TO-DO implement adding multiple wallets
//        }
      }
    }
    
  }
  fileprivate func showError(errorStr: String){
    self.errorLabel.text = errorStr
    if errorStr.characters.count == 0 {
      return;
    }
    self.errorLabel.alpha = 0.0
    //animating the error view in ... showing the error for a few seconds and removing again
    
    UIView.animate(withDuration: 0.3, animations:  {
      self.errorLabel.alpha = 1.0
      
      
      delay(0.3 + LocalData.manager.getDouble("ValueserrorTime", fallback: 7.0)){
        UIView.animate(withDuration: 0.3, animations: {
          self.errorLabel.alpha = 0.0
          
        } , completion: { finished in
          self.errorLabel.text  = ""
          
        })
      }
    }, completion: { finished in
      
    })
  }}

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
    return self.paymentMethods[row].description
  }
}


extension MCCheckoutViewController : PaymentMethodFactoryDelegate{
  internal func shouldBeSingleUse(_ controller: PaymentMethodFactory) -> Bool {
    return checkbox.isSelected
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
  
  func addedPaymentMethod(_ controller: PaymentMethodFactory ,method:PaymentMethodInterface){
    
    refreshPaymentMethods(defaultMethod:  method)
  }
  func displayViewController(_ controller: UIViewController ){
    self.present(controller, animated: true, completion: nil)
  }
  
  func dismissViewController(_ controller: UIViewController ){
    controller.dismiss(animated: true, completion: nil)
  }
  func showLoadingIndicator(_ controller: PaymentMethodFactory, show: Bool) {
    //self.showActivityIndicator( show)
    self.view.isUserInteractionEnabled = !show
    
  }
}






