//
//  CreditCardValidator.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
internal enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
}

internal class CreditCardValidator {
    
    
    internal static func checkCardNumber(input: String) -> (type: CardType, formatted: String, valid: Bool, complete: Bool) {
        // Get only numbers from the input string
        let numberOnly = input.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch) as String
        
        var type: CardType = .Unknown
        var formatted = ""
        var valid = false
        
        // detect card type
        for card in CardType.allCards {
            if (matchesRegex(card.regex, text: numberOnly)) {
                type = card
                break
            }
        }
        let validLegnth = cardLengthValid(type, length: numberOnly.characters.count)
        // check validity
        valid = luhnCheck(numberOnly)
        
        // format
        var formatted4 = ""
        for character in numberOnly.characters {
            if formatted4.characters.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
        
        // return the tuple
        return (type, formatted, valid , validLegnth  )
    }
    
    //The asumption is that input has only 1-9 and / in it
    internal static func isValidDate(inputDate: String) -> Bool {
        if inputDate.characters.count != 5 && inputDate.characters.count != 7{
        return false
        }
        let split = inputDate.characters.split("/").map(String.init)
        
        if split.count < 2{
        return false
        }
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year =  components.year - 2000 // last 2 digits of date
        let month = components.month
        let day = components.day
        
        let inputYear = Int(split[1])
        let inputmonth = Int(split[0])

        if inputYear > year && inputYear < 2000{//if 2 digits where entered
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
    internal static func cardLengthValid(type: CardType , length: Int) -> Bool{
        switch type {
        case .Amex:
            return 15 == length
        case .Diners:
            return length >= 14 && length <= 16
        case .Visa:
            return 16 == length || 13 == length
        case .JCB , .Discover , .MasterCard:
                return 16 == length
        default:
           return length >= 13
        }
    }
    
    internal static func maxLengthForType(type: CardType) -> Int{
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
    private static func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.CaseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatchInString(text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    private static func luhnCheck(number: String) -> Bool {
        var sum = 0
        let digitStrings = number.characters.reverse().map { String($0) }
        
        for tuple in digitStrings.enumerate() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.index % 2 == 1
            
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
