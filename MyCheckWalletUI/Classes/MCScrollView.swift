//
//  MCScrollView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

class MCScrollView: UIScrollView {
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        if #available(iOS 9.0, *) {
//            if event!.type == .Motion {
//                return self
//            }else if event!.type == .Presses{
//                return self
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//        if self.bounds.insetBy(dx: -100, dy: -100).contains(point){
//            return self
//        }
//        return nil
//
//    }
    
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
