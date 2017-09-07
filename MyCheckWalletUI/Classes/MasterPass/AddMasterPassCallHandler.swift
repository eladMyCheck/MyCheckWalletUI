
//
//  NativeCallHandler.swift
//  Pods
//
//  Created by elad schiller on 8/7/17.
//
//

import Foundation
import WebKit
import MyCheckCore


class AddMasterPassCallHandler: NSObject, WKScriptMessageHandler {
    
    var interactor: AddMasterPassBusinessLogic
    
    init(interactor: AddMasterPassBusinessLogic) {
        self.interactor = interactor
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       
        
      

        guard let jsonString: String = message.body as? String,
           let jsonData = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as!NSDictionary,
            let action = jsonDictionary["action"] as? String else{
                return
        }
        
        switch action{
       
        case "getMasterpassToken":
            if let callback = jsonDictionary["callback"] as? String{
            let request = AddMasterPass.GetMasterpassToken.Request(callback: callback)
            interactor.getMasterpassToken(request: request)
            }
        case "addMasterpass":
            guard let body = jsonDictionary["body"] as? [String:Any] else{
                
                return
            }
            let errorCode: Int? = body["errorCode"] as? Int
            let errorMessage: String? = body["errorMessage"] as? String
            let payload = body["payload"] as? String
            
          
            guard let complitionStatusStr = body["completionStatus"] as? String,
                let complitionStatus = AddMasterPassViewControllerCompletitionReason(reason: complitionStatusStr ,
                                                                                     payload: payload,
                                                                                   errorCode:errorCode,
                                                                                   errorMessage: errorMessage) else{
            return
            }
            let request = AddMasterPass.AddMasterpass.Request( complitionStatus: complitionStatus)
            interactor.addMasterpass(request: request)
                
           
            
            
        default: break
            
        }
        
    }
    
    
}


