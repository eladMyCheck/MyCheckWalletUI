//
//  MCCreditCardsViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

internal class MCCreditCardsViewController: MCViewController , UIScrollViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var scrollView: MCScrollView!
    var paymentMethods: Array<PaymentMethod>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.frame = CGRect(x:0, y:0, width:self.scrollView.frame.width, height:100)
        //let scrollViewWidth:CGFloat = self.scrollView.frame.width
        
        let creditCardCount = self.paymentMethods.count
        
        let addCreditCardView = AddCreditCardView(frame: CGRectMake(0, 20, 160, 102) )
        self.scrollView.addSubview(addCreditCardView)
        
        for i in (0..<creditCardCount) {
            let method = self.paymentMethods[i]
            let cc = CreditCardView(frame: CGRectMake(193*CGFloat(i+1), 20, 160, 102), method: method)
            
            self.scrollView.addSubview(cc)
        }
        
         self.scrollView.contentSize = CGSize(width:CGFloat(creditCardCount+1)*193, height:self.scrollView.frame.height)
        self.scrollView.delegate = self;
    }
}
