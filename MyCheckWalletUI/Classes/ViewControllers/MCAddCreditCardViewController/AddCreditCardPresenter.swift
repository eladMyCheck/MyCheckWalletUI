//
//  AddCreditCardPresenter.swift
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

protocol AddCreditCardPresentationLogic
{
  func presentSubmitFormResponse(response: AddCreditCard.SubmitForm.Response)
  
  func presentTextChangeResponse(response: AddCreditCard.TextChanged.Response)
  
  func stateChanged(response: AddCreditCard.StateChange.Response)
  
  
}

class AddCreditCardPresenter: AddCreditCardPresentationLogic
{
  weak var viewController: AddCreditCardDisplayLogic?
  
  // MARK: Do something
  
  func presentSubmitFormResponse(response: AddCreditCard.SubmitForm.Response)
  {
    //    let viewModel = AddCreditCard.Something.ViewModel()
    //    viewController?.displaySomething(viewModel: viewModel)
  }
  
  func stateChanged(response: AddCreditCard.StateChange.Response){
    
  }
  
  func presentTextChangeResponse(response: AddCreditCard.TextChanged.Response){
    
  }
  
}
