//
//  UIFont+customFonts.swift
//  Pods
//
//  Created by elad schiller on 9/24/17.
//
//

import Foundation


extension UIFont{

   static func ragularFont(withSize:CGFloat) -> UIFont{
        let defaultFont = Wallet.shared.ui.regularFont
        let size = withSize + Wallet.shared.ui.ragularFontSizeDelta
        return UIFont(name: defaultFont.fontName, size: size) ??
        UIFont.systemFont(ofSize: size)
    }
    
   static func headerFont(withSize:CGFloat) -> UIFont{
        let defaultFont = Wallet.shared.ui.headersFont
        let size = withSize + Wallet.shared.ui.headerFontSizeDelta
        return UIFont(name: defaultFont.fontName, size: size) ??
            UIFont.systemFont(ofSize: size)

    }
    
   static func buttonFont(withSize:CGFloat) -> UIFont{
        let defaultFont = Wallet.shared.ui.regularFont
        let size = withSize + Wallet.shared.ui.ragularFontSizeDelta
        return UIFont(name: defaultFont.fontName, size: size) ??
            UIFont.systemFont(ofSize: size)

    }
}
