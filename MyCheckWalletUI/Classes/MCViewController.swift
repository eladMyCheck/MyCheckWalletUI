//
//  MCViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit

public class MCViewController: UIViewController {

    
    
    internal static func getStoryboard(bundle: NSBundle) -> UIStoryboard{
       let finalBundle = getBundle(bundle)
        let storyboard = UIStoryboard(name: "MyCheckWalletUI", bundle: finalBundle)
        return storyboard

    }
    internal static func getBundle(bundle: NSBundle) -> NSBundle{
    
        let bundleURL = bundle.URLForResource("MyCheckWalletUI", withExtension: "bundle")
        let finalBundle = NSBundle(URL: bundleURL!)
        return finalBundle!
    }
}
