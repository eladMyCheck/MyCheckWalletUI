//
//  LocalData+MCPaymentMethodsViewController.swift
//  MyCheckWalletUI
//
//  Created by elad schiller on 12/14/17.
//

import Foundation


extension LocalData{
    
    func getPaymentMethodsStatusBarColor() -> UIStatusBarStyle{
        
        let light  = self.getBool("managePaymentMethodscolorsStatusBarIsLightContent", fallback: false)
        let style : UIStatusBarStyle = (light == true)  ? .lightContent : .default
        return style
    }
}
