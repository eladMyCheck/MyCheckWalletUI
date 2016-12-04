//
//  MCScrollView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

class MCScrollView: UIScrollView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.bounds.insetBy(dx: -100, dy: 0).contains(point){
            let result = super.hitTest(point, with: event)//superhitTest:point withEvent:event];
            
            if ((result?.superview?.isKind(of: CreditCardView.self)) != nil){
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
        super.translatesAutoresizingMaskIntoConstraints = false;

    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}
