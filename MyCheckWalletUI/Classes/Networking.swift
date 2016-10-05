
import Foundation
import UIKit
import Alamofire
import CoreData


internal class Networking {
    private enum Const {
        static let URLPrefix = "https://the.mycheckapp.com/"
        static let localErrorDomain = "MyCheck SDK error domain"
        static let serverErrorDomain = "MyCheck server error domain"
        
    }
    enum ErrorCodes {
        static let badJSON = 971
        static let notLoggedIn = 972
    }
    
    /// Login a user and get an access_token that can be used for getting and setting data on the user
    ///    - parameters:
    ///    - refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///    - publishableKey: The publishable key used for the refresh token
    ///    - success: A block that is called if the user is logged in succesfully
    ///    - fail: Called when the function fails for any reason
    ///
    static func login( refreshToken: String , publishableKey: String , success: ((String) -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request{
        let params = [ "refreshToken": refreshToken , "publishableKey": publishableKey]
        
        let urlStr = Const.URLPrefix + "users/api/v1/login"
        
        return  request(urlStr, method: .GET, parameters: params , success: { JSON in
            if let token = JSON["accessToken"] as? String{
                success(token)
            }else{
                if let fail = fail{
                    fail(badJSONError())
                }
            }
            
            }, fail: fail)
    }
    
    static func getPaymentMethods( accessToken: String , success: (( [PaymentMethod] ) -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request{
        let params = [ "accessToken": accessToken]
        
        let urlStr = Const.URLPrefix + "wallet/api/v1/wallet"
        
        return  request(urlStr , method: .GET, parameters: params , success: { JSON in
            var returnArray : [PaymentMethod] = []
            
            if  let methodsJSON = JSON["PaymentMethods"] as? NSArray{
                
                for dic in methodsJSON as! [NSDictionary]{
                    if let method = PaymentMethod(JSON: dic){
                        returnArray.append(method)
                    }
                }
                success(returnArray)
            }else{
                if let fail = fail{
                    fail(badJSONError())
                }
            }
            
            // success()
            
            }, fail: fail)
    }
    
    static func addCreditCard(rawNumber: String ,
                              expireMonth: String ,
                              expireYear: String ,
                              postalCode: String ,
                              cvc: String ,
                              type: CreditCardType ,
                              isSingleUse: Bool ,
                              accessToken: String ,
                              success: (( String ) -> Void) ,
                              fail: ((NSError) -> Void)? ) -> Alamofire.Request{
        let params = [ "accessToken" : accessToken , "rawNumber" : rawNumber , "expireMonth" : expireMonth , "expireYear" : expireYear , "postalCode" : postalCode , "cvc" : cvc , "type" : type.rawValue , "is_single_use" : NSNumber(bool: isSingleUse)]
        
        
        
        return  request("https://devpm.mycheckapp.com:8443/PaymentManager/api/v1/paymentMethods/addCreditcard", method: .POST, parameters: params , success: { JSON in
            
                let methodJSON = JSON["pm"]
                if let methodJSON = methodJSON{
                success((methodJSON["token"] as? String)!)
                }else{
                    if let fail = fail{
                        if let errormessage = JSON["message"] as? String{
                            let errorWithMessage = NSError(domain: "error", code: 3 , userInfo: [NSLocalizedDescriptionKey : errormessage])
                            fail(errorWithMessage)
                        }
                    }
            }
                
            
            
            }, fail: fail , encoding: .JSON)
    }
    
    static func setPaymentMethodAsDefault( accessToken: String , methodId: String , success: (() -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request{
        let params = [ "accessToken": accessToken , "ID": methodId]
        
        let urlStr = Const.URLPrefix + "wallet/api/v1/wallet/default"
        
        return  request(urlStr,  method: .POST, parameters: params , success: { JSON in
            success()
            
            }, fail: fail)
    }
    
    static func deletePaymentMethod( accessToken: String , methodId: String, success: (() -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request{
        let params = [ "accessToken": accessToken , "ID": methodId]
        let urlStr = Const.URLPrefix + "wallet/api/v1/wallet/deletePaymentMethod"
        
        return  request(urlStr, method: .POST , parameters:  params , success: { JSON in
            success()
            
            }, fail: fail)
    }
    
    //MARK: - private functions
    private static func request(url: String , method: Alamofire.Method , parameters: [String: AnyObject]? = nil , success: (( object: NSDictionary  ) -> Void)? , fail: ((NSError) -> Void)? , encoding: ParameterEncoding = .URL) -> Alamofire.Request {
        
        
        
        let request = Alamofire.request(method, url, parameters:parameters , encoding:  encoding)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseString{ response in
                print(response)
            }.responseJSON { response in
                
                switch response.result {
                case .Success(let JSON):
                    
//                    let responseJSON = JSON as! NSDictionary
//                    
//                    let status = responseJSON["status"] as? String
//                    if status != nil && status! == "ERROR"{
//                        do{
//                            let msg =  JSON["message"] as! String
//                            let code = JSON["code"] as! Int
//                            let error = NSError(domain: "sdffg", code: 3, userInfo: nil)
//                            let errorWithMessage = NSError(domain: error.domain, code: code , userInfo: [NSLocalizedDescriptionKey : msg])
//                            
//                            fail(errorWithMessage)
//                        } catch{
//                            fail(error as NSError)
//                        }
//
//                    }
                    if let success = success {
                        success(object: JSON as! NSDictionary)
                    }
                    
                    
                    
                    
                case .Failure(let error):
                    
                    
                    
                    
                    if let fail = fail {
                        if let data = response.data {
                            
                            let jsonDic = Networking.convertDataToDictionary(data)
                            
                            if let JSON = jsonDic {
                                
                                let msg =  JSON["message"] as? String
                                let code = JSON["code"] as? Int
                                    if let code = code , let msg = msg {
                                let errorWithMessage = NSError(domain: error.domain, code: code , userInfo: [NSLocalizedDescriptionKey : msg])
                                
                                fail(errorWithMessage)
                                } else{
                                fail(error as NSError)
                                }
                            }else{
                                fail(error)
                            }
                        }
                    }
                    
                }
        }
        return request
    }
    
    static func badJSONError() -> NSError{
        let locMsg = "bad format"
        let error = NSError(domain: Const.localErrorDomain, code: ErrorCodes.badJSON, userInfo: [NSLocalizedDescriptionKey : locMsg])
        return error
    }
    
    
    private static func convertDataToDictionary(data: NSData) -> [String:AnyObject]? {
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
        
        return nil
    }
}

