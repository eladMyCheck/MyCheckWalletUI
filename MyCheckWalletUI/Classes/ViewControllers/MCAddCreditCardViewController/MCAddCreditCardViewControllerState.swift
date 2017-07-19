//
//  MCAddCreditCardViewControllerState.swift
//  Pods
//
//  Created by elad schiller on 19/07/2017.
//
//

import Foundation
extension MCAddCreditCardViewController{
  
  enum InputFields {
    case number
    case date
    case  cvv
    case zip
    
    static func ==(_ lhs: MCAddCreditCardViewController.State, _ rhs: MCAddCreditCardViewController.State) -> Bool {
      switch (lhs, rhs) {
      case (.inputingDetails, .inputingDetails):
        return true
        
      case  (.callingServer, .callingServer):
        return true
        
      case let (.displayingError(leftMsg), .displayingError(rightMsg)):
        return leftMsg == rightMsg
        
      default:
        return false
      }
  }
  
  enum State : Equatable{
    
    struct errorDetails :Equatable {
      
      let message: String
      
      let invalidFields: [InputFields]
      
    }
    case inputingDetails
    
    case callingServer
   
    case displayingError(message: String)
    
    
    static func ==(_ lhs: MCAddCreditCardViewController.State, _ rhs: MCAddCreditCardViewController.State) -> Bool {
      switch (lhs, rhs) {
      case (.inputingDetails, .inputingDetails):
        return true
        
      case  (.callingServer, .callingServer):
        return true
        
      case let (.displayingError(leftMsg), .displayingError(rightMsg)):
        return leftMsg == rightMsg
        
      default:
        return false
      }
      
    }
  }
}
