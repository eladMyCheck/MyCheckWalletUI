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
    case Production
    /// Sandbox environment. mimics the behaviour of the production environment but allows the use of test payment methods and user accounts.
    case Sandbox
    /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
    case Test
}




internal enum Const {
    static let clientErrorDomain = "MyCheck SDK client error domain"
    static let serverErrorDomain = "MyCheck server error domain"
    
}


///MyCheckWallet is a singleton that will give you access to all of the MyCheck functionality. It has all the calls needed to manage a user's payment methods.
open class MyCheckWallet{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"
    internal static let loggedInNotification = "com.mycheck.loggedInNotification"
    
    
    ///If set to true the SDK will print to the log otherwise it will not
    open static var logDebugData = false
    
    
    //the publishable key that reprisents the app using the SDK
    fileprivate var publishableKey: String?
    
    //the delegate that should be updated with sub wallet changes
    internal var factoryDelegate: PaymentMethodFactoryDelegate? {
        set{
            for factory in factories{
                factory.delegate = newValue
            }
        }
        get{
            if factories.count > 0{
                let factory = factories[0]
                return factory.delegate
            }
            return nil
            
        }
    }
    func getFactory(_ type: PaymentMethodType) -> PaymentMethodFactory?{
        for factory in factories{
            if factory.type == type {
                return factory
            }
        }
        return nil
    }
    func hasFactory(_ type: PaymentMethodType) -> Bool{
        if type == .creditCard{
        return true
        }
        return getFactory(type) != nil
    }
    // the user token
    internal var factories: [PaymentMethodFactory] = []
    
    //remembers the braintree token
    var braintreeToken : String? = nil
    
    //the enviorment configured
    internal var environment : Environment?
    
    internal var token: String?
    open var methods:  [PaymentMethod] = []
    
    
    ///This property points to the singlton object. It should be used for calling all the functions in the class.
    open static let manager = MyCheckWallet()
    
    ///Sets up the SDK to work on the desired environment with the prefrences specified for the publishable key passed.
    ///
    ///   - parameter publishableKey: The publishable key created for your app.
    ///   - parameter environment: The environment you want to work with (production , sandbox or test).
    open func configureWallet(_ publishableKey: String , environment: Environment ){
        
        self.publishableKey = publishableKey
        self.configureWallet(publishableKey, environment: environment, success: nil, fail: nil)
        self.environment = environment
    }
    
    fileprivate func configureWallet(_ publishableKey: String , environment: Environment , success: (() -> Void)? , fail:((_ error: NSError) -> Void)?){
        Networking.manager.configureWallet(publishableKey , environment: environment, success: { domain , pci , JSON , stringsJSON in
            
            //the 3rd party we are supporting.
            
            LocalData.manager.addStrings(nil, dictionary: JSON)
            LocalData.manager.addStrings(nil , dictionary: stringsJSON)
            
            if let success = success{
                success()
                
            }
            }, fail: {error in
                if let fail = fail {
                    fail(error)
                }
        })
        
    }
    
    
    /// Login a user and get an access_token that can be used for getting and setting data on the user.
    ///
    ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///   - parameter publishableKey: The publishable key used for the refresh token
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    open func login( _ refreshToken: String  , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        
        if let key = publishableKey {
            let loginFunc = {
                let request = Networking.manager.login( refreshToken,  success: {token in
                    self.token = token
                    self.getPaymentMethods({paymentMethods in
                        let nc = NotificationCenter.default
                           nc.post(name: NSNotification.Name(rawValue: MyCheckWallet.refreshPaymentMethodsNotification),object: nil)
                        nc.post(name: NSNotification.Name(rawValue: MyCheckWallet.loggedInNotification), object: nil)
                        success()
                        
                        //configuring sub wallets
                        for factory in self.factories{
                            factory.configureAfterLogin()
                        }
                        
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
    
    open func isLoggedIn() -> Bool {
        return token != nil
    }
  
  
  open  func handleOpenURL(_ url: URL, sourceApplication: String?) -> Bool{
    var handle = false
    for factory in factories{
    handle = factory.handleOpenURL(url, sourceApplication:sourceApplication)
      if handle{
      break
      }
    }
    return handle
  }

    /// Gets a list of all the payment methods the user has saved in the MyCheck server
    ///
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    internal func getPaymentMethods( _ success: @escaping (( [PaymentMethod] ) -> Void) , fail: ((NSError) -> Void)? ) {
        if let token = token{
            let request = Networking.manager.getPaymentMethods(token, success: {
                methods in
                var mutableMethods = methods
                for (i,method) in mutableMethods.enumerated().reversed() {
                    if !self.hasFactory(method.type){
                        mutableMethods.remove(at: i)
                    }else{
                      //if it is of the factorys type replace it with the subclass otherwise do nothing
                      if let newMethod = self.createPaymentMethodSubclass(method) {
                      mutableMethods[i] = newMethod
                  }
                  }
                }
                self.methods = mutableMethods
                success(mutableMethods)
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
    internal func addCreditCard(_ rawNumber: String ,
                                expireMonth: String ,
                                expireYear: String ,
                                postalCode: String ,
                                cvc: String ,
                                type: CreditCardType ,
                                isSingleUse: Bool ,
                                success: @escaping (( PaymentMethod ) -> Void) ,
                                fail: ((NSError) -> Void)? ){
        if let token = token , let environment = environment{
            let request = Networking.manager.addCreditCard(rawNumber, expireMonth: expireMonth, expireYear: expireYear, postalCode: postalCode, cvc: cvc, type: type, isSingleUse: isSingleUse,accessToken: token, environment: environment , success: { token in
                
                
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
    
    internal func setPaymentMethodAsDefault( _ method: PaymentMethod,  success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ){
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
    
    
    internal func deletePaymentMethod( _ method: PaymentMethod , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
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
    internal static func notLoggedInError() -> NSError{
        let locMsg = "user not logged in"
        let error = NSError(domain:Const.clientErrorDomain , code: ErrorCodes.notLoggedIn, userInfo: [NSLocalizedDescriptionKey : locMsg])
        return error
    }
    
    fileprivate func refreshPaymentMethodsAndPostNotification(){
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: MyCheckWallet.refreshPaymentMethodsNotification),object: nil)
            
            
            }, fail: { error in
                
        })
    }
    //returns true if and only if the latest list of methods received from the server contains a payment method of the 'type'
    internal func hasPaymentMethodOfType(_ type: PaymentMethodType) -> Bool{
        for method in methods {
            if method.type == type{
             return true
            }
            
        }
        return false
    }
  internal func createPaymentMethodSubclass(_ method: PaymentMethod) -> PaymentMethod?{
      if let factory = MyCheckWallet.manager.getFactory(method.type){
       return factory.getPaymentMethod(method)
      }
      return method
  }
  
}



//MARK: - general scope functions

internal func printIfDebug(_ items: Any...){
    if MyCheckWallet.logDebugData {
        print (items )
    }
}
