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
    
    @IBOutlet var ragularFields: [UITextField]! = []
    @IBOutlet var ragularLabels: [UILabel]! = []
    @IBOutlet var headerLabels: [UILabel]! = []
    @IBOutlet var buttons: [UIButton]! = []
    
    
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
}

internal func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


fileprivate extension MCViewController{
    
    
    func setupUI(){
        if let ragularLabels = ragularLabels{
            ragularLabels.forEach{
                if let size = $0.font?.pointSize{
                    $0.font = UIFont.ragularFont(withSize: size)
                }
            }
        }
        if let ragularFields = ragularFields{

            ragularFields.forEach{
                if let size = $0.font?.pointSize{
                    $0.font = UIFont.ragularFont(withSize: size)

                }
            }
        }
        
        if let headerLabels = headerLabels{
            headerLabels.forEach{
                if let size = $0.font?.pointSize{
                    $0.font = UIFont.headerFont(withSize: size)

                }
            }
        }
        
        if let buttons = buttons {
            buttons.forEach{
                if let size = $0.titleLabel?.font.pointSize{
                    $0.titleLabel?.font = UIFont.buttonFont(withSize: size)

                }
            }
        }
        
    }
}
