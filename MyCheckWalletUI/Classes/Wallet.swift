//
//  MyCheckWallet.swift
//  Pods
//
//  Created by elad schiller on 18/09/2016.
//
//

import Foundation
import Alamofire
import MyCheckCore



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
    
    ///will answer and update applepay specific logic. This object is used by other MyCheck SDKs that need to support Apple Pay.
    public var applePayController: ApplePayController = NoApplePayState()
    
    //loaded all the languages in the config file
    fileprivate var loadedLanguages = false
    
    internal var factories: [PaymentMethodFactory] = []
    
    internal var factoriesDic: [PaymentMethodType : PaymentMethodFactory] {get{
        var dic: [PaymentMethodType : PaymentMethodFactory] = [:]
        for factory in factories {
        dic[factory.type] = factory
        }
        return dic
        }}

    //remembers the braintree token
    internal var braintreeToken : String? = nil
    
    internal var token: String?
    
    internal var methods:  [PaymentMethodInterface]?
    
    
    ///This property points to the singlton object. It should be used for calling all the functions in the class.
    open static let shared = Wallet()
    
    
    init() {
        self.configureWallet(success: nil, fail: nil)
    }
    
    /// Adds a new kind of payment method factory to the wallet. This will enable the use if the kind of payment method added.
    ///
    /// - Parameter factory: The factory you wish to add to the wallet.
    private func addFactory(factory: PaymentMethodFactory?){
        
        guard let factory = factory else{ return}
        
        factories.append(factory)
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
    internal func getPaymentMethods( success: @escaping (( [PaymentMethodInterface] ) -> Void) , fail: ((NSError) -> Void)? ) {
        self.callPaymentMethods( success: {
            methods in
            var mutableMethods = methods
            
            
            
            //Apple pay logic is handled localy.
            if  let applePayMethod = Wallet.shared.applePayController.getApplePayPaymentMethod(){
                
                //if we dont have any other method we will set apple pay as default
                if mutableMethods.count == 0 {
                    Wallet.shared.applePayController.changeApplePayDefault(to: true)
                }
                if applePayMethod.isDefault{
                    //making all other methods to not be default
                    mutableMethods = mutableMethods.map({method in
                        var value = method
                        value.isDefault = false
                        return value
                    })
                    mutableMethods.insert(applePayMethod, at: 0)
                }else{
                    mutableMethods.append(applePayMethod)
                }
                
            }
            
            
            self.methods = mutableMethods
            success(mutableMethods)
        }, fail: fail)
        
    }
    
    /// Get the default payment method.
    ///
    ///   - parameter success: Will return the default payment method
    ///   - parameter fail: Will return an error if the call failed or no payment method is available.
  
    public func getDefaultPaymentMehthod(success: @escaping (( PaymentMethodInterface ) -> Void) , fail: ((NSError) -> Void)? ) {
        if let methods = self.methods  {
            if let found = methods.first(where: { $0.isDefault }) {
                success( found)
            }else{
                if let fail = fail {
                fail(ErrorCodes.noPaymentMethods.getError())
                }
            }
            return
        }
        
        getPaymentMethods( success:{methods in
            if let found = methods.first(where: { $0.isDefault }) {
                success( found )
            }else{
                if let fail = fail {
                    fail(ErrorCodes.noPaymentMethods.getError())
                }
            }

        }, fail:fail)
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
                                success: @escaping (( PaymentMethodInterface ) -> Void) ,
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
                    //apple pay should stop being default
                    Wallet.shared.applePayController.changeApplePayDefault(to: false)
                    
                    
                    success(CreditCardPaymentMethod(JSON: methodJSON )!)
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
    
    internal func setPaymentMethodAsDefault( _ method: PaymentMethodInterface,  success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ){
        
        //apple pay is handled localy
        if  method.type == .applePay{
            Wallet.shared.applePayController.changeApplePayDefault(to: true)
            success()
        }
        
        
        let params = [  "ID": method.ID]
        
        let urlStr = Networking.shared.domain! + URIs.setMethodAsDefault
        
        self.request(urlStr,  method: .post, parameters: params , success: { JSON in
            //apple pay should stop being default
            if  method.type == .applePay{
                Wallet.shared.applePayController.changeApplePayDefault(to: false)
            }
            success()
            
        }, fail: fail)
    }
    
    
    /// Adds a new credit card to the MyCheck Wallet
    ///   - parameter method: The method of payment that should be deleted.
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    
    internal func deletePaymentMethod( _ method: PaymentMethodInterface , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        let params = [  "ID": method.ID]
        let urlStr = Networking.shared.domain! + URIs.deletePaymentMethod
        
        self.request(urlStr, method: .post , parameters:  params , success: { JSON in
            success()
            
        }, fail: fail)
        
        
    }
    
    
    //should be called by the various factorys when a method is set as defauult in order to update apple pay
    internal func addedAPaymentMethod(){
        Wallet.shared.applePayController.changeApplePayDefault(to: false)
        
        
    }
    
    
    //returns true if and only if the latest list of methods received from the server contains a payment method of the 'type'
    internal func hasPaymentMethodOfType(_ type: PaymentMethodType) -> Bool{
        guard let methods = methods else{
        return false
        }
        for method in methods {
            if method.type == type{
                return true
            }
            
        }
        return false
    }
    
    //private classes
    
    
    fileprivate func refreshPaymentMethodsAndPostNotification(){
        Wallet.shared.getPaymentMethods(success:{ (array) in
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: Wallet.refreshPaymentMethodsNotification),object: nil)
            
            
        }, fail: { error in
            
        })
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
