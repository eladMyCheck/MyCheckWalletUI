//
//  File.swift
//  Pods
//
//  Created by elad schiller on 9/7/17.
//
//

import Foundation

extension LocalData{
    struct MasterPassConsentAlertTexts{
      let message: String
        let positiveBut: String
        let negativeBut: String
    }
    func getConsentAlertTexts() -> MasterPassConsentAlertTexts{
        let msg = getString("thirdPartyPaymentMethodsmasterpassactiveConsent")
        let yes = getString("thirdPartyPaymentMethodsmasterpasspositiveButton")
        let no = getString("thirdPartyPaymentMethodsmasterpassnegativeButton")
        return MasterPassConsentAlertTexts(message: msg, positiveBut: yes, negativeBut: no)
    }
    
    func getAddedMasterPassMessage() -> String{
        let msg = getString("thirdPartyPaymentMethodsmasterpassaddPaymentMethodSuccess")
return msg
    }
}
