//
//  MyCheckWallet.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation
///MyCheckWallet is a singlton that will give you access to all of the MyCheck functionality. It has all the calls needed to manage a users payment methods.
public class MyCheckWallet{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"

  private var token: String?
    internal var methods:  [PaymentMethod] = []
    ///This property points to the singlton object. It should be used for calling all the functions in the class.
  public static let manager = MyCheckWallet()
  
  
  /// Login a user and get an access_token that can be used for getting and setting data on the user.
  ///
  ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
  ///   - parameter publishableKey: The publishable key used for the refresh token
  ///   - parameter success: A block that is called if the user is logged in succesfully
  ///   - parameter fail: Called when the function fails for any reason
  public func login( refreshToken: String , publishableKey: String , success: (() -> Void) , fail: ((NSError) -> Void)? ) {
    let request = Networking.login(refreshToken, publishableKey: publishableKey, success: {token in
      self.token = token
        self.getPaymentMethods({paymentMethods in
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(MyCheckWallet.refreshPaymentMethodsNotification,object: nil)
            
            success()

            }, fail: fail)
        
      }, fail: fail)
  }
  /// Check if a user is logged in or not
  ///    - Returns: True if the user is logged in and false otherwise.

 public func isLoggedIn() -> Bool {
    return token != nil
  }
  
    /// Gets a list of all the payment methods the user has saved in the MyCheck server
    ///
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
 public func getPaymentMethods( success: (( [PaymentMethod] ) -> Void) , fail: ((NSError) -> Void)? ) {
    if let token = token{
        let request = Networking.getPaymentMethods(token, success: {
            methods in
            self.methods = methods
            success(methods)
            }, fail: fail)
    }else{
      if let fail = fail{
        fail(MyCheckWallet.notLoggedInError())
      }
    }
  }
  
    /// Adds a new credit card to the MyCheck Wallet
    ///
    ///    - parameter expireMonth: The month the card expires
    ///    - parameter expireYear: The year the card expires
    ///    - parameter postalCode: The postal code defined for the Credit Card
    ///    - parameter cvc: The cvc of the Credit Card
    ///    - parameter type: The type of the Credit Card. possinle values:
    ///    - parameter isSingleUse: True if the payment method should be used only once. It will be erased from the database after the first use.
    ///    - parameter success: A block that is called if the user is logged in succesfully
    ///    - parameter fail: Called when the function fails for any reason
 public func addCreditCard(rawNumber: String ,
                     expireMonth: String ,
                     expireYear: String ,
                     postalCode: String ,
                     cvc: String ,
                     type: CreditCardType ,
                     isSingleUse: Bool ,
                     success: (( String ) -> Void) ,
                     fail: ((NSError) -> Void)? ){
    if let token = token{
        let request = Networking.addCreditCard(rawNumber, expireMonth: expireMonth, expireYear: expireYear, postalCode: postalCode, cvc: cvc, type: type, isSingleUse: isSingleUse,accessToken: token, success: { token in
            self.refreshPaymentMethodsAndPostNotification()

            success(token)
            }, fail: fail)
    }else{
      
      if let fail = fail{
        fail(MyCheckWallet.notLoggedInError())
      }
      
    }
  }
  
    /// Adds a new credit card to the MyCheck Wallet
    ///
    ///    - parameter method: The method of payment that should become the default payment method
    ///    - parameter success: A block that is called if the user is logged in succesfully
    ///    - parameter fail: Called when the function fails for any reason

 public func setPaymentMethodAsDefault( method: PaymentMethod,  success: (() -> Void) , fail: ((NSError) -> Void)? ){
    if let token = token{
      
        let request = Networking.setPaymentMethodAsDefault(token, methodId: method.Id, success: {
            self.refreshPaymentMethodsAndPostNotification()

            success()
            }, fail: fail)
    }else{
      
      if let fail = fail{
        fail(MyCheckWallet.notLoggedInError())
      }
      
    }
  }
    /// Adds a new credit card to the MyCheck Wallet
    ///   - parameter method: The method of payment that should be deleted.
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    

 public func deletePaymentMethod( method: PaymentMethod , success: (() -> Void) , fail: ((NSError) -> Void)? ) {
    if let token = token{
      
        let request = Networking.deletePaymentMethod(token, methodId: method.Id, success: {
            success()
            self.refreshPaymentMethodsAndPostNotification()
            }, fail: fail)
    }else{
      
      if let fail = fail{
        fail(MyCheckWallet.notLoggedInError())
      }
      
    }
  }
  
  
  //private classes
  private static func notLoggedInError() -> NSError{
    let locMsg = "user not logged in"
    let error = NSError(domain: "MyCheck SDK error domain", code: Networking.ErrorCodes.notLoggedIn, userInfo: [NSLocalizedDescriptionKey : locMsg])
    return error
  }
    
    private func refreshPaymentMethodsAndPostNotification(){
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(MyCheckWallet.refreshPaymentMethodsNotification,object: nil)
            

            }, fail: { error in
                
        })
          }
}
