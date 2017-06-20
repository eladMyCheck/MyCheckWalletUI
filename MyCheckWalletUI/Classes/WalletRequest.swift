////
////  WalletRequest.swift
////  Pods
////
////  Created by elad schiller on 6/20/17.
////
////
//
//import Foundation
//import MyCheckCore
//import Alamofire
//struct WalletRequest: RequestProtocol {
//    
//    var configured: Bool;
//    var onlyMissingLang: Bool;
//    
//    init(configured: Bool , missingLang: Bool) {
//        self.configured = configured
//        onlyMissingLang = missingLang
//    }
//    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding = URLEncoding.default , addedHeaders: HTTPHeaders? = nil, success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {
//        
//        if onlyMissingLang{
//            Wallet.shared.configureWallet(success: {
//            configured = true
//                
//            }, fail: fail)
//        }else{
//            Networking.shared.request(url, method: method, parameters: parameters, encoding: encoding, addedHeaders:addedHeaders, success: success, fail: fail)
//        }
//        
//        
//    }
//}
