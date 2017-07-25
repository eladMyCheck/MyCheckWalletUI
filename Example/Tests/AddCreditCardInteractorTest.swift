//
//  AddCreditCardInteractorTest.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 25/07/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import MyCheckCore
@testable import MyCheckWalletUI


class AddCreditCardOutputSpy: AddCreditCardPresentationLogic{
  var stateChnages: [AddCreditCard.State] = []
  var submitFormResponse:  AddCreditCard.SubmitForm.Response?
  var textChangeResponse: AddCreditCard.TextChanged.Response?
  
  func presentSubmitFormResponse(response: AddCreditCard.SubmitForm.Response){
    submitFormResponse = response
  }
  
  func stateChanged(response: AddCreditCard.StateChange.Response){
    stateChnages.append(response.state)
  }
  
  func presentTextChangeResponse(response: AddCreditCard.TextChanged.Response){
    textChangeResponse = response
  }
  
}




class AddCreditCardInteractorTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  
  
  
  func testChangeTextInFieldShouldCallPresenterWithValidNumber() {
    let interactor = AddCreditCardInteractor()
    let spy = AddCreditCardOutputSpy()
    interactor.presenter = spy
    //Given
    let text = "1"
    let req = AddCreditCard.TextChanged.Request(type: .number, string: text)
    
    //When
    interactor.changeTextInField(request: req);
    
    //Then
    XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
    XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.type == .number, "invalid field type returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should not know the type yet")
    XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "the legth should be valid")

     XCTAssert(spy.stateChnages.count == 0, "state should not change")
  }
  
  
  func testChangeTextInFieldShouldCallPresenterWithInValidNumberLength() {
    let interactor = AddCreditCardInteractor()
    let spy = AddCreditCardOutputSpy()
    interactor.presenter = spy
    //Given
    let text = "111111111111111111111111111111111"
    interactor.model = AddCreditCard.FormData(number: "411111111", date: "", cvv: "", zip: "")
    let req = AddCreditCard.TextChanged.Request(type: .number, string: text)
    
    //When
    interactor.changeTextInField(request: req);
    
    //Then
    XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
    XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.type == .number, "invalid field type returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
    XCTAssert(spy.stateChnages.count == 0, "state should not change")
    XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Visa, "should use the type before the text change request")

  }
  
  func testChangeTextInFieldShouldCallPresenterWithValidDateLength() {
    let interactor = AddCreditCardInteractor()
    let spy = AddCreditCardOutputSpy()
    interactor.presenter = spy
    //Given
    let text = "1"
    interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "")
    let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
    
    //When
    interactor.changeTextInField(request: req);
    
    //Then
    XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
    XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
    XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
    XCTAssert(spy.stateChnages.count == 0, "state should not change")
    XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
    
  }
  
  
  
}


