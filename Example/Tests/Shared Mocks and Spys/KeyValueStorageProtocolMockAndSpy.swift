//
//  KeyValueStorageMockAndSpy.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 7/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
@testable import MyCheckWalletUI
class KeyValueStorageProtocolMockAndSpy: KeyValueStorageProtocol{
    
    
    let returnValue: Any
    
    var key: String?
    init(toReturn: Any) {
        returnValue = toReturn
    }
    func getString(_ key: String , fallback: String?) -> String{
        self.key = key
        return returnValue as! String
    }
    
    func getColor(_ key: String , fallback: UIColor) -> UIColor{
        self.key = key
        return returnValue as! UIColor
        
    }
    
    func getDouble(_ key: String , fallback: Double) -> Double{
        self.key = key
        return returnValue as! Double
        
    }
    
    func getArray(_ key: String ) -> Array<String>{
        self.key = key
        return returnValue as! Array<String>
        
    }
}
