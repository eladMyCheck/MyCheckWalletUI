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
  
    @objc func buttonPressed(_ recognizer : UITapGestureRecognizer) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "AddCreditCardPressed"), object: nil)
    
  }
  
 
}

fileprivate extension AddCreditCardView{
    
    func setupUI(_ frame: CGRect){
        //Card build
        var cardFrame = frame
        cardFrame.origin.x = 0
        cardFrame.origin.y = 0
        
        let card = UIView(frame: cardFrame)
        card.layer.cornerRadius = (8.81 * cardFrame.width) / 100
        card.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorscardBackground", fallback:UIColor.white)
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1).cgColor
        card.layer.shadowOpacity = 1
        card.layer.shadowRadius = 21
        
        self.addSubview(card)
        
        var cardCenter = card.center
        cardCenter.y -= (3 * cardFrame.height) / 100
        
        //Circle with "+" inside build
        let circle = UIButton(frame: CGRect(x: 0, y: 0, width: ((22.988 * cardFrame.width) / 100), height: ((22.988 * cardFrame.width) / 100)))
        circle.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: ((8.333 * circle.frame.width) / 100), right: 0)
        circle.isUserInteractionEnabled = false
        circle.backgroundColor = LocalData.manager.getColor("managePaymentMethodscolorscircleColor", fallback: UIColor(red:0.99, green:0.74, blue:0.18, alpha:1))
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.14).cgColor
        circle.layer.shadowOpacity = 1
        circle.layer.shadowRadius = 3
        circle.layer.cornerRadius = circle.frame.width / 2
        circle.setTitle("+", for: .normal)
        circle.titleLabel?.textAlignment = .center
        circle.titleLabel?.font = circle.titleLabel?.font.withSize(circle.frame.height / 1.5)
        circle.setTitleColor(LocalData.manager.getColor("managePaymentMethodscolorsplusColor", fallback: .black), for: .normal)
        circle.center = cardCenter
        
        card.addSubview(circle)
        
        //Label build
        let label = UILabel(frame: CGRect(x: 0, y: circle.frame.origin.y + circle.frame.height - 6, width: self.frame.width, height: (cardFrame.height - (circle.frame.origin.y + circle.frame.height))))
        label.center.x = cardCenter.x
        label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 14)
        label.font = UIFont.ragularFont(withSize: 14)
        label.textAlignment = .center
        
        Wallet.shared.configureWallet(success: {
            label.text = LocalData.manager.getAddCreditCardText()
            label.textColor = LocalData.manager.getAddCreditCardTextColor()
        }, fail: nil)
        
        card.addSubview(label)
        
    }
}

