//
//  LocalesManager.swift
//  Pods
//
//  Created by elad schiller on 9/17/17.
//
//

import Foundation
internal struct Locales{

   private let langaugeURLs: [NSLocale: URL]
    
    
    
    let defaultLocaleURLTuple: (NSLocale ,URL )
    
    init?(langaugeURLStrings: [String: String] ) {
        
        
        let  localeArray = Array(langaugeURLStrings.keys).map{
            return NSLocale(localeIdentifier: $0)
        }
        
        var langaugeURLsTmp :  [NSLocale: URL] = [:]// creating a temp so langaugeURLs can be a let
        
        for locale in localeArray{
            if let value = langaugeURLStrings[locale.localeIdentifier],
                let url = URL(string: value){
            langaugeURLsTmp[locale] = url
            }
        
        }
        
        langaugeURLs = langaugeURLsTmp
        
        
        if  langaugeURLs.count < 1 {
        return nil
        }
        
       let defaultLocale = Array(langaugeURLs.keys)[langaugeURLs.keys.count - 1]
        guard let defaultLocaleURL = langaugeURLs[defaultLocale] else{
            return nil
        }
        defaultLocaleURLTuple = (defaultLocale , defaultLocaleURL)
    }
    
    func getLocaleURL(locale: NSLocale) -> URL?{
    return langaugeURLs[locale]
    }

}
