//
//  MCContainerView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 10/4/16.
//
//

import UIKit

public class MCContainerView: UIView {

    public convenience init(controller : UIViewController, withPaymentMethods : Array<PaymentMethod>!){
        self.init(frame: CGRectZero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: controller.view, attribute: .LeadingMargin, multiplier: 1.0, constant: -24).active = true
        NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: controller.view, attribute: .TrailingMargin, multiplier: 1.0, constant: 24).active = true
        NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: controller.view, attribute: .BottomMargin, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 400).active = true
        
        let creditCardController : AddAndSelectCreditCardViewController
        if withPaymentMethods != nil{
            if withPaymentMethods.count > 0 {
                creditCardController = AddAndSelectCreditCardViewController.createAddAndSelectCreditCardViewController(withPaymentMethods)
            }else{
                creditCardController = AddAndSelectCreditCardViewController.createAddAndSelectCreditCardViewController(nil)
            }
        }else{
            creditCardController = AddAndSelectCreditCardViewController.createAddAndSelectCreditCardViewController(nil)
        }
        
        controller.addChildViewController(creditCardController)
        creditCardController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(creditCardController.view)
        
        
        
        NSLayoutConstraint(item: creditCardController.view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .LeadingMargin, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: creditCardController.view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .TrailingMargin, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: creditCardController.view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .TopMargin, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: creditCardController.view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .BottomMargin, multiplier: 1.0, constant: 0).active = true
        
        controller.didMoveToParentViewController(controller)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
