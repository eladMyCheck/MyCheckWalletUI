//
//  MCCreditCardsViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

internal class MCCreditCardsViewController: MCViewController , UIScrollViewDelegate{

    @IBOutlet weak var scrollView: MCScrollView!
    var paymentMethods: Array<PaymentMethod>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.frame = CGRect(x:0, y:0, width:self.scrollView.frame.width, height:100)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        
        let viewcount = self.paymentMethods.count
        for i in (0..<viewcount) {
            let viewnew = UIView(frame: CGRectMake(193*CGFloat(i), 20, 160,102))
            viewnew.backgroundColor = UIColor.orangeColor()
            self.scrollView.addSubview(viewnew)
        }
        
         self.scrollView.contentSize = CGSize(width:CGFloat(viewcount)*193, height:self.scrollView.frame.height)
        self.scrollView.delegate = self;
    }
}
