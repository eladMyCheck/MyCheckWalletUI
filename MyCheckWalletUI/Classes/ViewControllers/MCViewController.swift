//
//  MCViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
import Kingfisher
open class MCViewController: UIViewController {

    
    
    internal static func getStoryboard(_ bundle: Bundle) -> UIStoryboard{
       let finalBundle = getBundle(bundle)
        let storyboard = UIStoryboard(name: "MyCheckWalletUI", bundle: finalBundle)
        return storyboard

    }
    internal static func getBundle(_ bundle: Bundle) -> Bundle{
    
        let bundleURL = bundle.url(forResource: "MyCheckWalletUI", withExtension: "bundle")
        let finalBundle = Bundle(url: bundleURL!)
        return finalBundle!
    }
}

internal func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
