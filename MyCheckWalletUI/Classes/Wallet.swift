//
//  MyCheckWallet.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation
import MyCheckCore
import Alamofire



// The suffixes for the various API calls. they will be added to the end of the 'Domain' received from the server in the configure call.
internal struct URIs{
    
    static let paymentMethods = "/wallet/api/v1/wallet"
    static let addCreditCard = "/PaymentManager/api/v1/paymentMethods/addCreditcard"
    static let setMethodAsDefault = "/wallet/api/v1/wallet/default"
    static let deletePaymentMethod = "/wallet/api/v1/wallet/deletePaymentMethod"
}

///MyCheckWallet is a singleton that will give you access to all of the MyCheck functionality. It has all the calls needed to manage a user's payment methods.
open class Wallet{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"
    internal static let loggedInNotification = "com.mycheck.loggedInNotification"
    
    //used for the add credit card API call.
    internal var PCIDomain: String?
    
    //loaded all the languages in the config file
    fileprivate var loadedLanguages = false
    
    init() {
        self.configureWallet(success: nil, fail: nil)
    }
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
    
    internal var token: String?
    open var methods:  [PaymentMethod] = []
    
    
    ///This property points to the singlton object. It should be used for calling all the functions in the class.
    open static let shared = Wallet()
    
    //Sets up the SDK to work on the desired environment with the prefrences specified for the publishable key passed.
    internal func configureWallet(success: (() -> Void)? , fail:((_ error: NSError) -> Void)?){
        
        Networking.shared.configure(success: {JSON in
            
            guard var walletJSON = JSON["wallet"] as? [String: Any] else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            guard let walletUIJSON = walletJSON["walletUI"] as? [String: Any] else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            walletJSON.removeValue(forKey: "walletUI")
            self.PCIDomain = walletJSON["PCI"] as? String
            LocalData.manager.addStrings(nil, dictionary: walletJSON as NSDictionary)
            LocalData.manager.addStrings(nil, dictionary: walletUIJSON as NSDictionary)
            
            guard  let langObj = walletUIJSON["lang"] as? NSDictionary ,  let textsURL = langObj["en"] as? String else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            Networking.shared.request(textsURL, method: .get, success: { strings in
                LocalData.manager.addStrings(nil , dictionary: walletUIJSON as NSDictionary)
                self.loadedLanguages = true

                if let success = success{
                    success()
                }
            }, fail: fail)
            
        }, fail: nil)
        
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
        self.callPaymentMethods( success: {
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
        var params : [String: Any] = [  "rawNumber" : rawNumber , "expireMonth" : expireMonth , "expireYear" : expireYear , "postalCode" : postalCode , "cvc" : cvc , "cardType" : type.rawValue , "is_single_use" : String(describing: NSNumber(value: isSingleUse))]
        
        
        if let env = Networking.shared.environment?.rawValue{
            params["env"] = env
        }
        self.request(PCIDomain! + URIs.addCreditCard,
                                  method: .post,
                                  parameters: params ,
                                  encoding: JSONEncoding.default,
                                  addedHeaders: ["Content-Type":"application/json"]
            , success: { JSON in
                
                let methodJSON = JSON["pm"] as? NSDictionary
                if let methodJSON = methodJSON{
                    success(PaymentMethod(JSON: methodJSON )!)
                }else{
                    if let fail = fail{
                        if let errormessage = JSON["message"] as? String{
                            let errorWithMessage = NSError(domain: "error", code: 3 , userInfo: [NSLocalizedDescriptionKey : errormessage])
                            fail(errorWithMessage)
                        }
                    }
                }
                
        }, fail: fail)
        
    }
    
    /// Adds a new credit card to the MyCheck Wallet
    ///
    ///    - parameter method: The method of payment that should become the default payment method
    ///    - parameter success: A block that is called if the user is logged in succesfully
    ///    - parameter fail: Called when the function fails for any reason
    
    internal func setPaymentMethodAsDefault( _ method: PaymentMethod,  success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ){
        
        let params = [  "ID": method.Id]
        
        let urlStr = Networking.shared.domain! + URIs.setMethodAsDefault
        
        self.request(urlStr,  method: .post, parameters: params , success: { JSON in
            success()
            
        }, fail: fail)
        
    }
    /// Adds a new credit card to the MyCheck Wallet
    ///   - parameter method: The method of payment that should be deleted.
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    
    
    internal func deletePaymentMethod( _ method: PaymentMethod , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        let params = [  "ID": method.Id]
        let urlStr = Networking.shared.domain! + URIs.deletePaymentMethod
        
        self.request(urlStr, method: .post , parameters:  params , success: { JSON in
            success()
            
        }, fail: fail)
        
        
    }
    
    
    //private classes
    
    
    fileprivate func refreshPaymentMethodsAndPostNotification(){
        Wallet.shared.getPaymentMethods({ (array) in
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: Wallet.refreshPaymentMethodsNotification),object: nil)
            
            
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
        if let factory = Wallet.shared.getFactory(method.type){
            return factory.getPaymentMethod(method)
        }
        return method
    }
    
}

//We should use this for API calls apart from when calling configure!
extension Wallet {
    internal func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding = URLEncoding.default , addedHeaders: HTTPHeaders? = nil, success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? ) {
       
        //if the languages where not loaded it means the configuration didnt fully succeed otherwise it did.
        if !loadedLanguages{
            Wallet.shared.configureWallet(success: {
                self.loadedLanguages = true
                Networking.shared.request(url, method: method, parameters: parameters, encoding: encoding, addedHeaders:addedHeaders, success: success, fail: fail)

            }, fail: fail)
        }else{
            Networking.shared.request(url, method: method, parameters: parameters, encoding: encoding, addedHeaders:addedHeaders, success: success, fail: fail)
        }

    }
}

   

internal func printIfDebug(_ items: Any...){
    if Session.logDebugData {
        print (items )
    }
}
