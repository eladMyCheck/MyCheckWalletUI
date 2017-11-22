//
//  AddCreditCardView.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/30/16.
//
//

import UIKit
import MyCheckCore

class AddCreditCardView: UIView , UIGestureRecognizerDelegate{
  
  var paymentMethod : PaymentMethodInterface?
  

  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setImageView(frame)
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddCreditCardView.buttonPressed(_:)))
    recognizer.delegate = self;
    self.addGestureRecognizer(recognizer)
    addAddCreditCardLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func buttonPressed(_ recognizer : UITapGestureRecognizer) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "AddCreditCardPressed"), object: nil)
    
  }
  
 
}

fileprivate extension AddCreditCardView{
  
   func setImageView(_ frame: CGRect) {
    let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
    let image = UIImage(named: "addcreditcardbackground", in: bundle, compatibleWith: nil)!
    let tintableImage = image.withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: tintableImage)
    
    var imgFrame = frame
    imgFrame.origin.x = 0
    imgFrame.origin.y = 0
    
    imageView.frame = imgFrame
    self.addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    Wallet.shared.configureWallet(success: {
        imageView.tintColor = LocalData.manager.getAddCreditCardTintColor()

    }, fail: nil)

  }
  
  func addAddCreditCardLabel() {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 22))
    let center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - label.frame.size.height )
    label.center  = center
    label.font = UIFont.ragularFont(withSize: label.font.pointSize)
    label.textAlignment = .center
    

    
    Wallet.shared.configureWallet(success: {
        label.text = LocalData.manager.getAddCreditCardText()
        label.textColor = LocalData.manager.getAddCreditCardTextColor()
    }, fail: nil)
    self .addSubview(label)
  }
}
