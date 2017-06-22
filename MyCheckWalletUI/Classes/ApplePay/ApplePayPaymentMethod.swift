  //
//  ApplePayPaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 04/12/2016.
//
//

import UIKit
import Braintree
class ApplePayPaymentMethod: PaymentMethod {
  open override var token : String{
    get{
    return createFinalToken()
    }
    set{
    super.token = newValue
    }
  }
    override var checkoutName: String? {get{
        if isSingleUse {
         return "ApplePay " + LocalData.manager.getString("checkoutPagetemporaryCard", fallback: "(Temp card)")
        }
        return "ApplePay"
        }
    }
  fileprivate static  let REFRESH_DEVICE_DATA_INTERVAL : TimeInterval = 13 * 60 // 12 minutes
  fileprivate var deviceData : String?

  internal convenience init?(other:PaymentMethod){
      self.init(JSON: other.JSON)
    refreshDeviceData()
    delay(ApplePayPaymentMethod.REFRESH_DEVICE_DATA_INTERVAL, closure: {
      self.refreshDeviceData()
    
    })
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
  
  fileprivate func createFinalToken() -> String{
    if let deviceData = deviceData{
    let tokenContent =  "token=\(super.token)&device-data=\(deviceData)"
      if let encoded = tokenContent.toBase64(){
        return "mcpp" + encoded
      }
    }
    return super.token
  }
}
