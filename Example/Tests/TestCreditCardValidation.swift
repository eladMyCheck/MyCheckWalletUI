//
//  TestCreditCardValidation.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 4/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import MyCheckWalletUI

private struct CreditCard {
  let number : String?
  let DOB: String?
  let CVV: String?
  let ZIP: String?
  
  init(number: String? , DOB: String? = nil, CVV: String? = nil, ZIP: String? = nil){
    self.number = number
    self.DOB = DOB
    self.CVV = CVV
    self.ZIP = ZIP
  }
}


private let passNumbers: [(String , CreditCardType)] = [
  ("378282246310005" , .Amex),
  ("371449635398431" , .Amex),
  ("378734493671000" , .Amex),
  ("30569309025904" , .Diners),
  ("38520000023237" , .Diners),
  ("6011111111111117" , .Discover),
  ("6011000990139424" , .Discover),
  ("3530111333300000" , .JCB),
  ("3566002020360505" , .JCB),
  ("5555555555554444" , .MasterCard),
  ("5105105105105100" , .MasterCard),
  ("4111111111111111" , .Visa),
  ("4012888888881881" , .Visa),
  ("4222222222222" , .Visa),
  ("2223000048400011" , .MasterCard)// the new mastercard number format
]

private let failNumbers: [String] = [
  "42424242424242424242",
  "0000000000000000",
  "9999999999999995",
  "1",
  "1234123412341234",
  "xxx",
  "9999999999999999999999"
]
private let machingNumberPrefixToType : [(String , CreditCardType)] = [
  
]
private let failNumberLengthOnly: [String] = [
  
]
class TestCreditCardValidation: QuickSpec {
  
  override func spec() {
    describe("Testing the validation of credit card"){
      
      context("Testing end cases... when values are nil") {
        it("Is never valid when it has no input"){
          let validator = CreditCardValidator()
          expect(validator.CreditDetailsValid).to(beFalse())
          expect(validator.numberHasvalidFormat).to(beFalse())
          expect(validator.numberHasvalidLength).to(beFalse())
          expect(validator.numberIsCompleteAndValid).to(beFalse())
          expect(validator.DOBIsValid).to(beFalse())
          expect(validator.CVVIsValid).to(beFalse())
          expect(validator.ZIPIsValid).to(beFalse())
          expect(validator.cardType).to(equal(CreditCardType.Unknown))
          
        }
        
        
        it("When only valid DOB ,CVV  and ZIP is entered only number is valid"){
          let validator = CreditCardValidator(DOB:"12/19",CVV:"123" , ZIP: "10016")
          expect(validator.CreditDetailsValid).to(beFalse())
          expect(validator.numberHasvalidFormat).to(beFalse())
          expect(validator.numberHasvalidLength).to(beFalse())
          expect(validator.numberIsCompleteAndValid).to(beFalse())
          expect(validator.DOBIsValid).to(beTrue())
          expect(validator.CVVIsValid).to(beTrue())
          expect(validator.ZIPIsValid).to(beTrue())
          
        }
        it("is not a valid DOB if it is in the past"){
          let validator = CreditCardValidator(DOB:"12/16",CVV:"123" , ZIP: "10016")
          
          expect(validator.DOBIsValid).to(beFalse())
          
          
        }
        it("is passes on valid Visa Card"){
          let validator = CreditCardValidator(DOB:"12/16",CVV:"123" , ZIP: "10016")
          
          expect(validator.DOBIsValid).to(beFalse())
          
          
        }
        it("is passes on CVV only if it is 3 or 4 chars long "){
          var validator = CreditCardValidator(CVV:"12" )
          
          expect(validator.CVVIsValid).to(beFalse())
          
          validator = CreditCardValidator(CVV:"123" )
          
          expect(validator.CVVIsValid).to(beTrue())
          
          
          validator = CreditCardValidator(CVV:"1234" )
          
          expect(validator.CVVIsValid).to(beTrue())
          
          
          validator = CreditCardValidator(CVV:"12345" )
          
          expect(validator.CVVIsValid).to(beFalse())
          
          
          validator = CreditCardValidator(CVV:"" )
          
          expect(validator.CVVIsValid).to(beFalse())
          
          
        }
        
        it("should partially succeed on all these numbers"){
          for (number , _) in passNumbers{
            let validator = CreditCardValidator(cardNumber: number)
            expect(validator.CreditDetailsValid).to(beFalse())
            expect(validator.numberHasvalidFormat).to(beTrue())
            expect(validator.numberHasvalidLength).to(beTrue())
            expect(validator.numberIsCompleteAndValid).to(beTrue())
            expect(validator.DOBIsValid).to(beFalse())
            expect(validator.CVVIsValid).to(beFalse())
            expect(validator.ZIPIsValid).to(beFalse())
            
          }
        }
        it("should fully succeed on all these numbers"){
          for (number , type) in passNumbers{
            let validator = CreditCardValidator(cardNumber: number , DOB: "11/99" , CVV: "111" , ZIP: "10016")
            expect(validator.CreditDetailsValid).to(beTrue())
            expect(validator.numberHasvalidFormat).to(beTrue())
            expect(validator.numberHasvalidLength).to(beTrue())
            expect(validator.numberIsCompleteAndValid).to(beTrue())
            expect(validator.DOBIsValid).to(beTrue())
            expect(validator.CVVIsValid).to(beTrue())
            expect(validator.ZIPIsValid).to(beTrue())
            expect(validator.cardType) == type

          }
        }
        it("should fail on all these numbers"){

          for number in failNumbers{
            print("testing number: \(number)")
            let validator = CreditCardValidator(cardNumber: number )
          
            expect(validator.numberIsCompleteAndValid).to(beFalse())
            expect(validator.DOBIsValid).to(beFalse())
            expect(validator.CVVIsValid).to(beFalse())
            expect(validator.ZIPIsValid).to(beFalse())
            
          }
        }
        
        it("should recognise card type"){
          for (number , type) in passNumbers{
            for  i in 8..<number.characters.count {
          let index =  number.index(number.startIndex, offsetBy: i)
              let testNumber = number.substring(to: index)
                print("testing number: \(testNumber)")

            let validator = CreditCardValidator(cardNumber: testNumber)
           
            expect(validator.cardType) == type
           
            
            }
          }
        }
        
      }
    }
  }
}
