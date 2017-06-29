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
  class ApplePayPaymentMethod: PaymentMethodInterface  {
    
    var ID: String{get{return "Apple Pay"}}

   
    
    
  

    private let name = "Apple Pay"
    var description: String{get{return name}}

    var isSingleUse: Bool{get{return true}}

  
  
    ///Is the payment method the default payment method or not
    var  isDefault : Bool
    
    ///The type of the payment method
    var  type : PaymentMethodType{ get{return .applePay} }
    
    //used to display extra data abou the method , for example the email or the last 4 digits
    var extaDescription: String{get{ return "" }}
    //used to display extra data abou the method , for example the expiration date
    var extraSecondaryDescription: String{get{ return ""}}
    
       ///Init function we are always returning nil since we want this type of payment method to only be created localy
    ///
    ///    - JSON: A JSON that comes from the wallet endpoint
    ///    - Returns: A payment method object or nil if the JSON is invalid or missing non optional parameters.
    required init?(JSON: NSDictionary){
    return nil
    }
   
    
  internal  init( methodIsDefault:Bool){
    
    
    isDefault = methodIsDefault
    
  }
  

  
  
    func generatePaymentToken(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: (String) -> Void, fail: (NSError) -> Void) {
      <#code#>
    }

    
    func setupMethodImage(for imageview: UIImageView){
      imageview.kf.setImage(with: self.type.imageURLForDropdown())
      
    }
}

  fileprivate extension PKPaymentRequest{
   convenience init?(paymentDetails: PaymentDetailsProtocol? = nil){
    var request=PKPaymentRequest();
//    request.requiredBillingAddressFields = PKAddressField.PKAddressFieldNone
//    [request setRequiredBillingAddressFields:PKAddressFieldNone];
    request.merchantIdentifier="TO-DO";
    request.countryCode="TO-DO";
    request.currencyCode="TO-DO";
    request.applicationData=[@"MyCheck" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    request.supportedNetworks=[MCApplePay applePaySupporetedMethodsList];
    request.merchantCapabilities =  PKMerchantCapability3DS;
    request.requiredShippingAddressFields = PKAddressFieldNone;
    return request;
    }
    
  }
