  //
  //  ApplePayPaymentMethod.swift
  //  Pods
  //
  //  Created by elad schiller on 04/12/2016.
  //
  //
  
  import UIKit
  import MyCheckCore
  import PassKit
  
  
  class ApplePayPaymentMethod: NSObject{
    var a :AuthorizationViewControllerDelegateResponder? //TO-DO I added this because of a bad access crash. need to find a better way...

    fileprivate let name = "Apple Pay"
    
    ///Is the payment method the default payment method or not
    var  isDefault : Bool
    
    fileprivate let applePayCredentials: ApplePayCredentials
    
    internal  init(credentials: ApplePayCredentials, methodIsDefault:Bool){
        
        isDefault = methodIsDefault
        
        applePayCredentials = credentials
    }
    
    
    private var applePaySuccess: ((String) -> Void)?
    private var applePayFail: ((NSError) -> Void)?
    
    
    ///we are always returning nil since we want this type of payment method to only be created localy
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    required init?(JSON: NSDictionary){
        return nil
    }
  }
  
  
  
  
  extension ApplePayPaymentMethod: PaymentMethodInterface  {
    
    var ID: String{get{return "Apple Pay"}}
    
    
    
    
    
    
    
    override var description: String{get{return name}}
    
    var isSingleUse: Bool{get{return true}}
    
    
    
    
    ///The type of the payment method
    var  type : PaymentMethodType{ get{return .applePay} }
    
    //used to display extra data abou the method , for example the email or the last 4 digits
    var extaDescription: String{get{ return "" }}
    //used to display extra data abou the method , for example the expiration date
    var extraSecondaryDescription: String{get{ return ""}}
    

    func setupMethodImage(for imageview: UIImageView){
        imageview.kf.setImage(with: self.type.imageURLForDropdown())
        
    }
    
    
    
    
    
    func generatePaymentToken(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: @escaping (String) -> Void, fail: @escaping (NSError) -> Void) {
        guard let displayDelegate = displayDelegate else {
           fail( ErrorCodes.missingDisplayViewControllerDelegate.getError())
        return
        }
        
        //when the user has already added apple pay dont create a new one
      Wallet.shared.hasPendingApplePayToken(success: { hasApplePayToken , token in
        if let token = token , hasApplePayToken {
        success(token)
          return
        }else{//no apple pay token
        self.sendNewApplePayPendingToken(for: details, displayDelegate: displayDelegate, success: success, fail: fail)
        }
      }, fail: fail)
      
      
    }
    
    private func sendNewApplePayPendingToken(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate, success: @escaping (String) -> Void, fail: @escaping (NSError) -> Void) {
    
      //creating the apple pay VC
      let request = PKPaymentRequest(applePayCredentials: applePayCredentials, paymentDetails: details)
      //In reality this returns nil sometimes so we need to do this casting $(^&%#
      let optionalController = PKPaymentAuthorizationViewController(paymentRequest: request) as PKPaymentAuthorizationViewController?
      guard let controller = optionalController else {
        fail(ErrorCodes.applePayFailed.getError())
        return
      }
      var callbackCalled = false

      //resonding to the delegate
      let del = AuthorizationViewControllerDelegateResponder(
        didAuthorize:{payment,controller,completion in
          guard let token = String(data: payment.token.paymentData, encoding: .utf8) , let cardName = payment.token.paymentMethod.network?.rawValue else{
            fail(ErrorCodes.applePayFailed.getError())
            completion(.failure)
            callbackCalled = true
            return
          }
          Wallet.shared.addApplePay(applePayToken: token, cardType: cardName, isPending: true, success: {token in
            success(token)
            completion(.success)
            callbackCalled = true

          }, fail: {error in
            fail(error)
            completion(.failure)
            callbackCalled = true

          })
      }
        ,
        
        didFinish:{ controller in
          displayDelegate.dismiss(viewController: controller)
          if callbackCalled == false{
          fail(ErrorCodes.actionCanceledByUser.getError(message: "User Canceled Apple Pay Payment"))
          }
          
      })
      a = del//TO-DO fix this (bad access error if we take it off)
      //handeling the delegate calls inline
      controller.delegate = del
      displayDelegate.display(viewController: controller)
    }
    }
  
  fileprivate extension PKPaymentRequest{
    convenience init(applePayCredentials: ApplePayCredentials, paymentDetails: PaymentDetailsProtocol? = nil){
        self.init()
        merchantIdentifier = applePayCredentials.merchantIdentifier;
        countryCode = applePayCredentials.countryCode;
        currencyCode = applePayCredentials.currencyCode;
        applicationData = "MyCheck".data(using: .utf8, allowLossyConversion: false)
        supportedNetworks = applePayCredentials.applePayCreditCardTypes
        merchantCapabilities =  .capability3DS;
        requiredShippingAddressFields = [];
        guard let paymentDetails = paymentDetails else{ // If payment details are not passed I assume it is a pending amount
            
            let item = PKPaymentSummaryItem(label: "total", amount: NSDecimalNumber(value: 0.01), type: .pending)
            paymentSummaryItems = [item]
            return
        }
        paymentSummaryItems = paymentDetails.getOrderedBillEntryArray().map { value in PKPaymentSummaryItem(label: value.name, amount: NSDecimalNumber(value: value.amount.rawValue))
        }
    }
    
  }
  

  //Translates the delegate methods to closure functions for ease of use
   class  AuthorizationViewControllerDelegateResponder : NSObject , PKPaymentAuthorizationViewControllerDelegate {
    
     var didAuthorize:( PKPayment,  PKPaymentAuthorizationViewController,  @escaping (PKPaymentAuthorizationStatus) -> Void)->()
     var didFinish: (PKPaymentAuthorizationViewController) -> ()
    
    init(didAuthorize:@escaping ( PKPayment,  PKPaymentAuthorizationViewController, @escaping  (PKPaymentAuthorizationStatus) -> Void)->(),
         didFinish: @escaping (PKPaymentAuthorizationViewController) -> ()) {
        self.didAuthorize = didAuthorize
        self.didFinish = didFinish
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void){
       didAuthorize(payment, controller, completion)
        
     }
     func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController){
        didFinish(controller)
   }
  }
  
         
