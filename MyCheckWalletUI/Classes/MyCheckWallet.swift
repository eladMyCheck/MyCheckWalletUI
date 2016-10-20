//
//  MyCheckWallet.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation

///The diffrant enviormants you can work with. Used when configuring the SDK and determined the server to query.
public enum Environment {
    /// Production enviormant.
    case production
    /// Sandbox environment. mimics the behaviour of the production environment but allows the use of test payment methods and user accounts.
    case sandbox
    /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
    case test
}
internal enum Const {
    static let clientErrorDomain = "MyCheck SDK client error domain"
    static let serverErrorDomain = "MyCheck server error domain"
    
}
///MyCheckWallet is a singleton that will give you access to all of the MyCheck functionality. It has all the calls needed to manage a user's payment methods.
public class MyCheckWallet{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"
    internal static let loggedInNotification = "com.mycheck.loggedInNotification"

    //the publishable key that reprisents the app using the SDK
    private var publishableKey: String?
    
    
    // the user token
    private var token: String?
    public var methods:  [PaymentMethod] = []
    ///This property points to the singlton object. It should be used for calling all the functions in the class.
    public static let manager = MyCheckWallet()
    
    ///Sets up the SDK to work on the desired environment with the prefrences specified for the publishable key passed.
    ///
    ///   - parameter publishableKey: The publishable key created for your app.
    ///   - parameter environment: The environment you want to work with (production , sandbox or test).
    public func configureWallet(publishableKey: String , environment: Environment ){
    self.publishableKey = publishableKey
        self.configureWallet(publishableKey, environment: environment, success: nil, fail: nil)
    }
    
    private func configureWallet(publishableKey: String , environment: Environment , success: (() -> Void)? , fail:((error: NSError) -> Void)?){
        Networking.manager.configureWallet(environment, success: { domain , pci , JSON , stringsJSON in
            
            StringData.manager.addStrings(nil, dictionary: JSON)
            StringData.manager.addStrings(nil , dictionary: stringsJSON)
            if let success = success{
            success()
            }
            }, fail: {error in
                if let fail = fail {
                fail(error: error)
                }
        })
    
    }

    
    /// Login a user and get an access_token that can be used for getting and setting data on the user.
    ///
    ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///   - parameter publishableKey: The publishable key used for the refresh token
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    public func login( refreshToken: String  , success: (() -> Void) , fail: ((NSError) -> Void)? ) {
     
        if let key = publishableKey {
            let loginFunc = {
                let request = Networking.manager.login( refreshToken, publishableKey: key , success: {token in
                self.token = token
                self.getPaymentMethods({paymentMethods in
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName(MyCheckWallet.refreshPaymentMethodsNotification,object: nil)
                    nc.postNotificationName(MyCheckWallet.loggedInNotification, object: nil)
                    success()
                    
                    }, fail: fail)
                
                }, fail: fail)
                
            }
            
            
            if Networking.manager.domain != nil {
                
                loginFunc()
            
            }else {//Networking.manager.domain == nil ,in this case config was called but didnt complete
                configureWallet(key, environment: Networking.manager.environment, success: {
                    loginFunc()

                    }, fail: fail)
            }
        }else{
            let error = NSError(
                domain: Const.clientErrorDomain,
                code: ErrorCodes.MissingPublishableKey,
                userInfo: [
                    NSLocalizedDescriptionKey: "you must first call the configure function of the MyCheckWallet singlton"]
            )
            
        }
    }
    /// Check if a user is logged in or not
    ///
    ///    - Returns: True if the user is logged in and false otherwise.
    
    public func isLoggedIn() -> Bool {
        return token != nil
    }
    
    /// Gets a list of all the payment methods the user has saved in the MyCheck server
    ///
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    internal func getPaymentMethods( success: (( [PaymentMethod] ) -> Void) , fail: ((NSError) -> Void)? ) {
        if let token = token{
            let request = Networking.manager.getPaymentMethods(token, success: {
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
    internal func addCreditCard(rawNumber: String ,
                                expireMonth: String ,
                                expireYear: String ,
                                postalCode: String ,
                                cvc: String ,
                                type: CreditCardType ,
                                isSingleUse: Bool ,
                                success: (( PaymentMethod ) -> Void) ,
                                fail: ((NSError) -> Void)? ){
        if let token = token{
            let request = Networking.manager.addCreditCard(rawNumber, expireMonth: expireMonth, expireYear: expireYear, postalCode: postalCode, cvc: cvc, type: type, isSingleUse: isSingleUse,accessToken: token, success: { token in
                if token.isSingleUse == false{
                    self.refreshPaymentMethodsAndPostNotification()
                }
                
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
    
    internal func setPaymentMethodAsDefault( method: PaymentMethod,  success: (() -> Void) , fail: ((NSError) -> Void)? ){
        if let token = token{
            
            let request = Networking.manager.setPaymentMethodAsDefault(token, methodId: method.Id, success: {
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
    
    
    internal func deletePaymentMethod( method: PaymentMethod , success: (() -> Void) , fail: ((NSError) -> Void)? ) {
        if let token = token{
            
            let request = Networking.manager.deletePaymentMethod(token, methodId: method.Id, success: {
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
        let error = NSError(domain:Const.clientErrorDomain , code: ErrorCodes.notLoggedIn, userInfo: [NSLocalizedDescriptionKey : locMsg])
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
