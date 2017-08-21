//
//  AddCreditCardPresentorTest.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 7/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import MyCheckCore
@testable import MyCheckWalletUI


class AddCreditCardDisplayLogicSpy: AddCreditCardDisplayLogic{
    var submitVM:AddCreditCard.SubmitForm.ViewModel?
    var textChangeVM: AddCreditCard.TextChanged.ViewModel?
    var stateChangedVM: AddCreditCard.StateChange.ViewModel?
    
    func formSubmitionResponse(viewModel: AddCreditCard.SubmitForm.ViewModel){
    submitVM = viewModel
    }
    
    func updateField(viewModel: AddCreditCard.TextChanged.ViewModel){
    textChangeVM = viewModel
    }
    
    func changeLoadingView(viewModel: AddCreditCard.StateChange.ViewModel){
    stateChangedVM = viewModel
    }
    
}


class AddCreditCardPresenterTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPresentNumberField() {
        
        let presenter = AddCreditCardPresenter()
        let spy = AddCreditCardDisplayLogicSpy()
        presenter.viewController = spy
        //Given
        let response = AddCreditCard.TextChanged.Response(type: .number, text: "1", prefixOfValidValue: true, cardType: .Unknown)
    presenter.presentTextChangeResponse(response: response)
         XCTAssert(spy.stateChangedVM == nil , "should not have been called")
        XCTAssert(spy.submitVM == nil, "should not have been called")
        guard let viewModel = spy.textChangeVM else {
        XCTFail("text change view model should not be nil")
            return
        }
        XCTAssert(viewModel.type == .number, "should be the same field of the response")
        XCTAssert(viewModel.textColor == UIColor.fieldTextValid(), "should be valid color")
        XCTAssert(viewModel.underlineColor == UIColor.fieldUnderline(), "should be valid color")
        XCTAssert(viewModel.text == "1", "should be valid color")
        XCTAssert(viewModel.cardTypeIconUpdate == AddCreditCard.TextChanged.ViewModel.CardTypeUpdate.showPlaceholder, "should be valid color")

    }
    
    func testPresentWithImageChange() {
        
        let presenter = AddCreditCardPresenter()
        let spy = AddCreditCardDisplayLogicSpy()
        presenter.viewController = spy
        let imgURLStr = "http://.www.JCB.com/image.jpg"
        presenter.localData = KeyValueStorageProtocolMockAndSpy(toReturn: imgURLStr)
        //Given
        let response = AddCreditCard.TextChanged.Response(type: .number, text: "1", prefixOfValidValue: true, cardType: .JCB)
        presenter.presentTextChangeResponse(response: response)
        XCTAssert(spy.stateChangedVM == nil , "should not have been called")
        XCTAssert(spy.submitVM == nil, "should not have been called")
        guard let viewModel = spy.textChangeVM else {
            XCTFail("text change view model should not be nil")
            return
        }
        XCTAssert(viewModel.type == .number, "should be the same field of the response")
        XCTAssert(viewModel.textColor == UIColor.fieldTextValid(), "should be valid color")
        XCTAssert(viewModel.underlineColor == UIColor.fieldUnderline(), "should be valid color")
        XCTAssert(viewModel.text == "1", "should be valid color")
        XCTAssert(viewModel.cardTypeIconUpdate == AddCreditCard.TextChanged.ViewModel.CardTypeUpdate.updateCardTypeImage(URL(string: imgURLStr)!), "should be valid color")

    }
    
    func testSubmitFormSuccess(){
        //Arrange
        let presenter = AddCreditCardPresenter()
        let spy = AddCreditCardDisplayLogicSpy()
        presenter.viewController = spy
        
        let response = AddCreditCard.SubmitForm.Response.addedCreditCard
        //Act
        presenter.presentSubmitFormResponse(response: response)

        //Assert
        switch spy.submitVM! {
        case .success:
        break //this should happen
        default:
            XCTFail("should of succeedded")
        }
        
    }


    
}
