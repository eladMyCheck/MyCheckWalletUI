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
    var stateChanges: [AddCreditCard.State] = []
    var submitFormResponse:  AddCreditCard.SubmitForm.Response?
    var textChangeResponse: AddCreditCard.TextChanged.Response?
    
    func presentSubmitFormResponse(response: AddCreditCard.SubmitForm.Response){
        submitFormResponse = response
    }
    
    func stateChanged(response: AddCreditCard.StateChange.Response){
        stateChanges.append(response.state)
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
    
    
    //MARK - Text Change tests
    
    
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
        
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
    }
    
    func testChangeTextInFieldShouldCallPresenterWithEmptyNumber() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = ""
        let req = AddCreditCard.TextChanged.Request(type: .number, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .number, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should not know the type yet")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "the legth should be valid")
        
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
    }
    
    
    func testChangeTextInFieldShouldCallPresenterWithInValidNumberLength() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "111111111111111111111111111111111"
        interactor.model = AddCreditCard.FormData(number: "411111111", date: "", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .number, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .number, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithValidDateLength() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "1"
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithEmptyDateLength() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = ""
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    /// If month was entered it should return the string with the slash before adding the year
    func testChangeTextInFieldShouldCallPresenterWithValidDateAndAddSlashWhen2CharsLength() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12"
        interactor.model = AddCreditCard.FormData(number: "", date: "1", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == "12/", "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithValidDateAndRemoveSlashAndExtraCharWhen3CharLength() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12/"
        interactor.model = AddCreditCard.FormData(number: "", date: "12/1", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == "1", "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithValidDateWithYear2Digits() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12/21"
        interactor.model = AddCreditCard.FormData(number: "", date: "12/2", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithValidDateWithYear3Digits() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12/202"
        interactor.model = AddCreditCard.FormData(number: "", date: "12/2", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldCallPresenterWithValidDateWithYear4Digits() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12/2021"
        interactor.model = AddCreditCard.FormData(number: "", date: "12/2", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        XCTAssertNil(spy.submitFormResponse, "submitFormResponse should not have been called")
        XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.type == .date, "invalid field type returned to presenter when changeTextInField called")
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
        XCTAssert(spy.stateChanges.count == 0, "state should not change")
        XCTAssert(spy.textChangeResponse?.cardType == CreditCardType.Unknown, "should use the type before the text change request")
        
    }
    
    func testChangeTextInFieldShouldNotCallPresneterWith5digitYear() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "12/20211"
        interactor.model = AddCreditCard.FormData(number: "", date: "12/2", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
        
        
    }
    
    func testChangeTextInFieldShouldNotCallPresneterWithNonNumericValue() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        var text = "a"
        while text.characters.count <= 7{
            
            interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
            let req = AddCreditCard.TextChanged.Request(type: .date, string: text)
            
            //When
            interactor.changeTextInField(request: req);
            
            //Then
            
            XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
            text = text + "a"
        }
    }
    
    func testChangeTextInFieldShouldSucceedOnCVVEnter() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        var text = ""
        while text.characters.count <= 4{
            interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
            let req = AddCreditCard.TextChanged.Request(type: .cvv, string: text)
            
            //When
            interactor.changeTextInField(request: req);
            
            //Then
            
            XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
            
            XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
            
            //setting up next iteration
            text = text + "1"
        }
    }
    
    func testChangeTextInFieldShouldFailOnCVVWithletters() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "a"
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .cvv, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
        
    }
    
    func testChangeTextInFieldShouldSucceedOnZipEnter() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        var text = ""
        while text.characters.count <= 8{
            interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
            let req = AddCreditCard.TextChanged.Request(type: .zip, string: text)
            
            //When
            interactor.changeTextInField(request: req);
            
            //Then
            
            XCTAssert(spy.textChangeResponse?.prefixOfValidValue == true, "should not return valid")
            
            XCTAssert(spy.textChangeResponse?.text == text, "invalid value returned to presenter when changeTextInField called")
            
            //setting up next iteration
            text = text + "1"
        }
    }
    
    func testChangeTextInFieldShouldFailOnEnterNonAlphaNumericChar() {
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        let text = "^"
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        let req = AddCreditCard.TextChanged.Request(type: .zip, string: text)
        
        //When
        interactor.changeTextInField(request: req);
        
        //Then
        
        XCTAssert(spy.textChangeResponse?.prefixOfValidValue == false, "should not return valid")
        
        
        
        
    }
    
    //MARK - Submit form tests
    
    func testSubmitFormWithInValidInput(){
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        //When
        let req = AddCreditCard.SubmitForm.Request(number: "411", date: "12/13", cvv: "1", zip: "a", singleUse: false)
        interactor.submitForm(request: req)
        
        //Then
        guard let response = spy.submitFormResponse else{
        XCTFail("no response receieved")
            return
        }
        XCTAssert(spy.stateChanges == []) // invalid input should not change state
        
        switch response {
        case .addedCreditCard:
            XCTFail("should of failed")
        case .failedToAddCard(let failedResponse):
            XCTAssert(failedResponse.inputValid == false , "the input should be invalid")
            XCTAssert(failedResponse.serverErrorMessage == nil , "no server call")
            XCTAssert(failedResponse.fieldValidity.count == 4 , "all fields should be sent")
            XCTAssert(failedResponse.fieldValidity.reduce(false, { $0 || $1.1 }) == false , "all fields should be false")


        }
        

    }
    
    
    func testSubmitFormWithInValidNumberOnly(){
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
        //When
        let req = AddCreditCard.SubmitForm.Request(number: "411", date: "12/19", cvv: "123", zip: "12345", singleUse: false)
        interactor.submitForm(request: req)
        
        //Then
        guard let response = spy.submitFormResponse else{
            XCTFail("no response receieved")
            return
        }
        XCTAssert(spy.stateChanges == []) // invalid input should not change state
        
        switch response {
        case .addedCreditCard:
            XCTFail("should of failed")
        case .failedToAddCard(let failedResponse):
            XCTAssert(failedResponse.inputValid == false , "the input should be invalid")
            XCTAssert(failedResponse.serverErrorMessage == nil , "no server call")
            XCTAssert(failedResponse.fieldValidity.count == 4 , "all fields should be sent")
            XCTAssert(failedResponse.fieldValidity.reduce(0, { $0 +  ($1.1 ? 0 : 1) }) == 1 , "only one field should be invalid")
            
            
        }
        
        
    }
    
    func testSubmitFormWithInValidDataWithDiffrantCompination(){
        let interactor = AddCreditCardInteractor()
        let spy = AddCreditCardOutputSpy()
        interactor.presenter = spy
        //Given
        
        //testing a hole bunch of combos of valid and invalid data
        let invalidData = ["411" , "11/11" , "1" , ""]
        let validData = ["4111111111111111" , "11/19" , "123" , "12345"]
        for  i in 0..<4{
            for  j in i..<4{
                
                var data: [String] = []
                var validField: [Bool] = []
                for k in 0..<4{
                    data.append(( k >= i && k <= j ) ? invalidData[k] : validData[k])
                    validField.append(( k >= i && k <= j ) ? false : true)

                }

                interactor.model = AddCreditCard.FormData(number: "", date: "", cvv: "", zip: "", singleUse:false)
                //When
                let req = AddCreditCard.SubmitForm.Request(number: data[0], date: data[1], cvv: data[2], zip: data[3], singleUse: false)
                interactor.submitForm(request: req)
                
                //Then
                guard let response = spy.submitFormResponse else{
                    XCTFail("no response receieved")
                    return
                }
                XCTAssert(spy.stateChanges == []) // invalid input should not change state
                
                switch response {
                case .addedCreditCard:
                    XCTFail("should of failed")
                case .failedToAddCard(let failedResponse):
                    XCTAssert(failedResponse.inputValid == false , "the input should be invalid")
                    XCTAssert(failedResponse.serverErrorMessage == nil , "no server call")
                    XCTAssert(failedResponse.fieldValidity.reduce(0, { $0 +  ($1.1 ? 1 : 0) }) == 1  , "amount of valid fields is wrong")
                    for  (type , valid) in failedResponse.fieldValidity{
                        switch type {
                        case .number:
                            XCTAssert(valid == validField[0] , "number should validity should be \(validField[0])")
                        case .date:
                            XCTAssert(valid == validField[1] , "date should validity should be \(validField[1])")
                        case .cvv:
                            XCTAssert(valid == validField[2] , "cvv should validity should be \(validField[2])")
                        case .zip:
                            XCTAssert(valid == validField[3] , "zip should validity should be \(validField[3])")

                            
                        }
                    }
                    
            }
        }
       
            
            
        }
        
        
    }


}


