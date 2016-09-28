//
//  MCPaymentMethodsViewController.swift
//  Pods
//
//  Created by elad schiller on 9/25/16.
//
//

import UIKit
public protocol MCPaymentMethodsViewControllerDelegate {
    func userDismissed( controller: MCPaymentMethodsViewControllerDelegate)

    
}
public class MCPaymentMethodsViewController: MCViewController {
    
    var delegate: MCPaymentMethodsViewControllerDelegate?
    
   public static func createPaymentMethodsViewController(delegate: MCPaymentMethodsViewControllerDelegate?) -> MCPaymentMethodsViewController
    {
        
        let storyboard = MCViewController.getStoryboard(  NSBundle(forClass: self.classForCoder()))
        let controller = storyboard.instantiateViewControllerWithIdentifier("MCPaymentMethodsViewController") as! MCPaymentMethodsViewController
            
        controller.delegate = delegate
       
        return controller
    }
    

}
