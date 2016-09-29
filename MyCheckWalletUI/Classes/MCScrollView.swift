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
        if self.bounds.insetBy(dx: -100, dy: -100).contains(point){
            return self
        }
        return nil

    }

}
