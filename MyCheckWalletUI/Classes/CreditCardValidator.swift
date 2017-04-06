//
//  CreditCardValidator.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

private enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard,Maestro, UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard,Maestro, UnionPay]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)[0-9]{0,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Maestro:
            return "^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390|6799)\\d+$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
            
        default:
            return ""
        }
    }
    func getCreditCardType() -> CreditCardType {
        switch self {
        case .Amex:
            return .Amex
        case .Diners:
            return .Diners
        case .Discover:
            return .Discover
        case .JCB:
            return .JCB
        case .Maestro:
            return .Maestro
        case .MasterCard:
            return .MasterCard
        case .Visa:
            return .Visa
            
        default:
            return .Unknown
        }
    }
}

internal struct CreditCardValidator {
    private var cardNumber: String?
    private var DOB: String?
    private var CVV: String?
    private var ZIP: String?
    
    private var _cardType : CardType = .Unknown
    var cardType : CreditCardType{
        get{
        return _cardType.getCreditCardType()
        }
    }
     var formattedCardNumber :String? = nil

     var numberHasvalidFormat: Bool = false
    var numberHasvalidLength: Bool = false
    var numberIsCompleteAndValid : Bool {
        get{
        return numberHasvalidFormat && numberHasvalidLength
        }
    }
    var ZIPIsValid : Bool {
        get{
            guard let ZIP = ZIP else{
                return false;
            }
            let ZIPNoSpaces = ZIP.replacingOccurrences(of: " ", with: "")
            let alphaNumeric = ZIPNoSpaces.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
            return 3...8 ~= ZIPNoSpaces.characters.count && alphaNumeric

        }
    }
    var DOBIsValid = false
    var CVVIsValid : Bool {
        get{
            guard let CVV = CVV else {
                return false
            }
            return 3...4 ~= CVV.characters.count
        }
    }
    
    var CreditDetailsValid : Bool {
        get{
        return numberIsCompleteAndValid && DOBIsValid && CVVIsValid && ZIPIsValid
        }
    }
    var reachedMaxCardLength: Bool {
        get{
            if let cardNumber = cardNumber{
                let cardNumberWithoutFormating =  cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) as String
                return cardNumberWithoutFormating.characters.count >= maxLengthForType(cardType)
            }
            return false
        }
    }
    
    init(cardNumber: String? = nil , DOB: String? = nil, CVV: String? = nil, ZIP: String? = nil) {
        self.cardNumber = cardNumber
        self.DOB = DOB
        self.CVV = CVV
        self.ZIP = ZIP
        
        if let cardNumber = cardNumber {
      
        
        let cardNumberWithoutFormating =  cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) as String
        
        //getting type
        for card in CardType.allCards {
            if (matchesRegex(card.regex, text: cardNumberWithoutFormating)) {
                _cardType = card
                break
            }
        }
        
        // format number e.g. 1111 1111 1111 1111
        var formatted4 = ""
            var formatedNumTmp = ""
        for character in cardNumberWithoutFormating.characters {
            if formatted4.characters.count == 4 {
                formatedNumTmp += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
            formatedNumTmp += formatted4 // the rest

        formattedCardNumber = formatedNumTmp // the rest
        
        numberHasvalidFormat = luhnCheck(cardNumberWithoutFormating) && cardType != .Unknown
        numberHasvalidLength =  cardLengthValid(_cardType, length: cardNumberWithoutFormating.characters.count)
            
        }
        if let DOB = DOB {
        DOBIsValid = isValidDate(DOB)
        }
    }
    
    
    //The asumption is that input has only 1-9 and / in it
    private func isValidDate(_ inputDate: String) -> Bool {
        if inputDate.characters.count != 5 && inputDate.characters.count != 7{
            return false
        }
        let split = inputDate.characters.split(separator: "/").map(String.init)
        
        if split.count < 2{
            return false
        }
        
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year =  components.year! - 2000 // last 2 digits of date
        let month = components.month
//        let day = components.day
        
        let inputYear = Int(split[1])
        let inputmonth = Int(split[0])
        
        if inputYear > year && inputYear < 100{//if 2 digits where entered
            return true
        }
        if inputYear > year + 2000{//if 4 digits where entered
            return true
        }
        if (inputYear == year || inputYear == year + 2000) && inputmonth >= month{
            return true
        }
        return false
        
    }
    

    private func cardLengthValid(_ type: CardType , length: Int) -> Bool{
        switch type {
        case .Amex:
            return 15 == length
        case .Diners:
            return  14...16 ~= length
        case .Visa:
            return 16 == length || 13 == length
        case .JCB , .Discover , .MasterCard:
            return 16 == length
        default:
            return 13...19  ~= length
        }
    }
    
    private func maxLengthForType(_ type: CreditCardType) -> Int{
        switch type {
        case .Amex:
            return 15
        case .Diners:
            return  16
        case .Visa:
            return 16
        case .JCB , .Discover , .MasterCard:
            return 16
        default:
            return 19
        }
    }
    fileprivate  func matchesRegex(_ regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    fileprivate  func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.characters.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
   
    
}
