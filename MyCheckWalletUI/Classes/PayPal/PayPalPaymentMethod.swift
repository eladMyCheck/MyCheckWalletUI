  //
//  PayPalPaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 04/12/2016.
//
//

import UIKit
import Braintree
import MyCheckCore
  
public class PayPalPaymentMethod: CreditCardPaymentMethod {
    
    fileprivate static let REFRESH_DEVICE_DATA_INTERVAL : TimeInterval = 13 * 60 // 12 minutes
    fileprivate var deviceData : String?
    
    public required init?(JSON: NSDictionary) {
        super.init(JSON: JSON)
        
        refreshDeviceData()
        delay(PayPalPaymentMethod.REFRESH_DEVICE_DATA_INTERVAL, closure: {
            self.refreshDeviceData()
        })
    }
    
    public override func generatePaymentParams(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: @escaping ([String : Any]) -> Void, fail: @escaping (NSError) -> Void) {
        var params : [String : Any] = ["ccToken" : getToken()]
        
        if let deviceD = deviceData {
            params.append(other: ["device-data" : deviceD])
        }
        
        success(params)
    }

    func refreshDeviceData() {

    Wallet.shared.getBraintreeToken({token in

      if let btApiClient = BTAPIClient(authorization: token){
        let dataCollector = BTDataCollector(apiClient: btApiClient)
        dataCollector.collectFraudData({data in
            self.deviceData = data
        })
      }
      }, fail: nil)
  }
}
