//
//  MCAddCreditCardViewControllerModel.swift
//  Pods
//
//  Created by elad schiller on 19/07/2017.
//
//

import Foundation


struct MCAddCreditCardViewControllerModel {
    let cardNumber: String
    let dateString: String
    let cvv: String
    let zip: String
    let singleUse: Bool
    
    struct Diff {
        let from: MCAddCreditCardViewControllerModel
        let to: MCAddCreditCardViewControllerModel
        
        /*
         Private so that the only way to create a diff is using the `diffed(with:)`
         method.
         */
        fileprivate init( from: MCAddCreditCardViewControllerModel, to: MCAddCreditCardViewControllerModel) {
            self.dreamChange = dreamChange
            self.from = from
            self.to = to
        }
     
        
       
        
        
    }
    
    /// Returns a diff of `self` and `other`.
    func diffed(with other: MCAddCreditCardViewControllerModel) -> Diff {
        
        return Diff( from: self, to: other)
    }
}
