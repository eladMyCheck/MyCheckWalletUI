//
//  MCScrollView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

class MCScrollView: UIScrollView {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if self.bounds.insetBy(dx: -100, dy: 0).contains(point){
            let result = super.hitTest(point, withEvent: event)//superhitTest:point withEvent:event];
            
            if ((result?.superview?.isKindOfClass(CreditCardView)) != nil){
                return result
            }
            else{
                return self;
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canCancelContentTouches = true
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancelInContentView(view)
    }

}
