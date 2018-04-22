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
    
    setupUI(frame)
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddCreditCardView.buttonPressed(_:)))
    recognizer.delegate = self;
    self.addGestureRecognizer(recognizer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func buttonPressed(_ recognizer : UITapGestureRecognizer) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "AddCreditCardPressed"), object: nil)
    
  }
  
 
}

fileprivate extension AddCreditCardView{
    
    func setupUI(_ frame: CGRect){
        //Card build
        let card = UIView(frame: frame)
        card.layer.cornerRadius = 23
        card.backgroundColor = UIColor.white
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        card.layer.shadowOpacity = 1
        card.layer.shadowRadius = 21
        
        var cardFrame = frame
        cardFrame.origin.x = 0
        cardFrame.origin.y = 0
        
        card.frame = cardFrame
        self.addSubview(card)
        
        var cardCenter = card.center
        cardCenter.y -= 10.0
        
        //Circle with "+" inside build
        let circle = UIButton(frame: CGRect(x: 157, y: 153, width: 60, height: 60))
        circle.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        circle.isUserInteractionEnabled = false
        circle.backgroundColor = LocalData.manager.getColor("addCreditColorsCircleColor", fallback: UIColor(red:0.99, green:0.74, blue:0.18, alpha:1))
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.14).cgColor
        circle.layer.shadowOpacity = 1
        circle.layer.shadowRadius = 3
        circle.layer.cornerRadius = circle.frame.width / 2
        circle.setTitle("+", for: .normal)
        circle.titleLabel?.textAlignment = .center
        circle.titleLabel?.font = circle.titleLabel?.font.withSize(circle.frame.height / 1.5)
        circle.setTitleColor(LocalData.manager.getColor("addCreditColorsPlusColor", fallback:UIColor.black), for: .normal)
        circle.center = cardCenter
        
        card.addSubview(circle)
        
        //Label build
        let label = UILabel(frame: CGRect(x: 0, y: circle.frame.origin.y + circle.frame.height + 16, width: self.frame.width, height: 22))
        label.center.x = cardCenter.x
        label.font = UIFont.ragularFont(withSize: label.font.pointSize)
        label.textAlignment = .center
        
        Wallet.shared.configureWallet(success: {
            label.text = LocalData.manager.getAddCreditCardText()
            label.textColor = LocalData.manager.getAddCreditCardTextColor()
        }, fail: nil)
        
        card.addSubview(label)
        
    }
}

