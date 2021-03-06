//
//  AddCreditCardModels.swift
//  Pods
//
//  Created by elad schiller on 7/23/17.
//  Copyright (c) 2017 __MyCompanyName__. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit



enum AddCreditCard
{
  
  
  //MARK: State and form info
  enum State {
    case inputingDetails
    
    case callingServer
  }
  
    enum FieldType {
        case number
        case date
        case cvv
        case zip
    }
    
    //The model of the interactor
  struct FormData {
    let number: String
    let date: String
    let cvv: String
    let zip: String?
    let singleUse: Bool
    /// Returns a new Form Data with the specified fields changed
    ///
    /// - Parameter fields: the fields you would like to change
    /// - Returns: the new updated form data
    func FormDataWithUpdatedFields(fields:[(type: AddCreditCard.FieldType , newValue:String)], singleUse:Bool? = nil ) -> FormData{
      var number = self.number
      var date = self.date
      var cvv = self.cvv
      var zip = self.zip
      for (type , value) in fields{
        switch type {
        case .number:
          number = value
        case .date:
          date = value
        case .cvv:
          cvv = value
        case .zip:
          zip = value
        }
      }
         let single = singleUse ?? self.singleUse
    

        return FormData(number: number, date: date, cvv: cvv, zip: zip, singleUse: single)
      }
    
    
    /// Returns a validator on the form data
    ///
    /// - Returns: Returns a validator on the form data
    func getValidatorForForm() -> CreditCardValidator{
    return CreditCardValidator(cardNumber: number, DOB: date, CVV: cvv, ZIP: zip)
    }
  }
    
    
    
    
    
    
    
  // MARK: Use cases
  
  enum SubmitForm
  {
    
    
    struct Request
    {
      let number: String
      let date: String
      let cvv: String
      let zip: String?
        let singleUse: Bool
    }
    
    
    enum Response
    {
        struct FailedResponse {
            var inputValid: Bool { get{return fieldValidity.reduce(true){ $0 && $1.1}}}

            let fieldValidity: [(FieldType , Bool)]
          
            let serverErrorMessage: String?
        }
        
        
        case addedCreditCard
        
        
        case failedToAddCard(failedResponse: FailedResponse)
      
 
    }
    
    
    enum ViewModel
    {
        struct FieldPresentation{
            let FieldType: FieldType
            let textColor: UIColor
            let underlineColor: UIColor
        }
      
        
        struct failResponse {
        let fieldPresentations: [FieldPresentation]
        let errorMessage: String
        
      }
      
      
        
        case success
        
        
        case fail(failResponse)
      
      
        
    }
  }
  
  
  enum TextChanged
  {
   
    
    struct Request
    {
      let type: FieldType
      let string: String
    }
    
    
    struct Response
    {
      let type: FieldType
      let text: String
      let prefixOfValidValue: Bool
      let cardType: CreditCardType
    }
    
    
    struct ViewModel
    {
      enum CardTypeUpdate {
        
        case updateCardTypeImage(URL)
       
        case showPlaceholder
        
        
        static public func ==(lhs: CardTypeUpdate, rhs: CardTypeUpdate) -> Bool {
            switch (lhs, rhs) {
            case let (.updateCardTypeImage(a),   .updateCardTypeImage(b)):
                    return a == b
            case (.showPlaceholder , .showPlaceholder):
                return true
            default:
                return false
            }
        }
      }

        
        let type: FieldType
        
        let text: String
        
        let cardTypeIconUpdate: CardTypeUpdate
        
        let textColor: UIColor
        
        let underlineColor: UIColor
        

      
    }
    
  }
  
  
  enum StateChange
  {
    
    
    struct Response
    {
      let state: State
    }
    
    
    struct ViewModel
    {
 
        let showLoadingView: Bool
  
    }
    
  }
}
