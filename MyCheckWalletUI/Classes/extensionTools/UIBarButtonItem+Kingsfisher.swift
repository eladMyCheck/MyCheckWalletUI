//
//  UIBarButtonItem+Kingsfisher.swift
//  Pods
//
//  Created by elad schiller on 10/9/17.
//
//

import Foundation
import Kingfisher

extension UIBarButtonItem{


   func setImageAsync(url:URL){
    KingfisherManager.shared.retrieveImage(with: url, options: [.scaleFactor(2.55)], progressBlock: nil, completionHandler: {  image, _,_ , _ in
        if let image  = image{
        self.image = image
        }
        
    })
    }
    
}
