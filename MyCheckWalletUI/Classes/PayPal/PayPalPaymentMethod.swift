  //
//  PayPalPaymentMethod.swift
//  Pods
//
//  Created by elad schiller on 04/12/2016.
//
//

import UIKit
import Braintree
class PayPalPaymentMethod: PaymentMethod {
  public override var token : String{
    get{
    return createFinalToken()
    }
    set{
    super.token = newValue
    }
  }
  
  private static  let REFRESH_DEVICE_DATA_INTERVAL : NSTimeInterval = 13 * 60 // 12 minutes
  private var deviceData : String?

  internal convenience init?(other:PaymentMethod){
      self.init(JSON: other.JSON)
    refreshDeviceData()
    delay(PayPalPaymentMethod.REFRESH_DEVICE_DATA_INTERVAL, closure: {
      self.refreshDeviceData()
    
    })
      }
  
  
  func refreshDeviceData() {
    
    MyCheckWallet.manager.getBraintreeToken({token in
      
      if let btApiClient = BTAPIClient(authorization: token){
        var dataCollector = BTDataCollector(APIClient: btApiClient)
        dataCollector.collectFraudData({data in
          self.deviceData = data
        })
      }
      }, fail: nil)
  }
  
  private func createFinalToken() -> String{
    if let deviceData = deviceData{
    let tokenContent =  "token=\(super.token)&device-data=\(deviceData)"
      if let encoded = tokenContent.toBase64(){
        return "mcpp" + encoded
      }
    }
    return super.token
  }
}
