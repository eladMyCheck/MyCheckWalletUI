//
//  GiftCardPaymentMethod.swift
//  MyCheckWalletUI
//
//  Created by MSApps on 22/07/2018.
//

import UIKit
import MyCheckCore

public class GiftCardPaymentMethod: CreditCardPaymentMethod {
    
    fileprivate var active : Bool?
    
    fileprivate var balance : NSNumber?
    
    fileprivate var provider : String?
    
    fileprivate  var  expireDay : String?
    
    fileprivate var originalJSON : NSDictionary?
    
    public required init?(JSON: NSDictionary) {
        
        let json = NSMutableDictionary(dictionary: JSON)
        
        json["source"] = "GIFTCARD"
        json["last_4_digits"] = "GIFTCARD"
        
        if let stringId = JSON["id"] as? String , let id = Int(stringId){
            json["id"] = NSNumber(value: id)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        
        guard let str = JSON["expiration_date"] as? String, let date = dateFormatter.date(from: str) else{
            print("Debug - GiftCard missing Necessary Property/Necessary Property value is not correct")
            return nil
        }
        
        if date.timeIntervalSinceNow.sign == .minus{
            print("Debug - GiftCard filter - out of date")
            return nil
        }
        
        let calendar = Calendar.current
        
        json["exp_month"] = NSNumber(value:calendar.component(.month, from: date))
        json["exp_year4"] = NSNumber(value:calendar.component(.year, from: date))
        
        super.init(JSON: json)
        
        self.expireDay = String(calendar.component(.day, from: date))
        
        if let number = JSON["balance"] as? NSNumber{
            if number.doubleValue <= 0.0{
                print("Debug - GiftCard filter - balance below is 0")
                return nil
            }
            self.balance = number
            
            let ORIGINALJSON = NSMutableDictionary(dictionary: JSON)
            ORIGINALJSON["balance"] = Double(round(1000*number.doubleValue)/1000)
            
            self.originalJSON = ORIGINALJSON
            
        }else{
            print("Debug - GiftCard missing Necessary Property/Necessary Property value is not correct")
            return nil
        }
        
        if let number = JSON["active"] as? NSNumber{
            if !number.boolValue {
                print("Debug - GiftCard filter - giftCard is not active")
                return nil
                }
            self.active = number.boolValue
        }else{
            print("Debug - GiftCard missing Necessary Property/Necessary Property value is not correct")
            return nil
        }
        
        if let str = JSON["provider"] as? String{
            self.provider = str
        }
        
    }
    
    public override func generatePaymentParams(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: @escaping ([String : Any]) -> Void, fail: @escaping (NSError) -> Void) {
        let params : [String : Any] = ["giftCardId" : self.ID]
        
        success(params)
    }
    
    public override func generateJSON() -> [String: Any]{
        
        
        guard let JSON = self.originalJSON else{
            return [:]
        }
        
        return JSON as! [String : Any]
        
    }
    
    
}
