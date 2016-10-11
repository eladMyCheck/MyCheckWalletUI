//
//  MCCreditCardsViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit

internal protocol MCCreditCardsViewControllerrDelegate {
    func backPressed()
}

internal class MCCreditCardsViewController: MCViewController , UIScrollViewDelegate, UIGestureRecognizerDelegate, CreditCardViewDelegate{

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: MCScrollView!
    var activityView : UIActivityIndicatorView!
    var paymentMethods: Array<PaymentMethod>!
    var delegate : MCCreditCardsViewControllerrDelegate?
    var creditCards : NSMutableArray = []
    var editMode : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCrediCards()
        self.scrollView.delegate = self;
        self.editButton.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(13)], forState: .Normal)
    }
    
    internal func setCrediCards(){
        let subviews = self.scrollView.subviews
        for subview in subviews{
            subview.removeFromSuperview()
        }
        self.scrollView.frame = CGRect(x:self.scrollView.frame.origin.x, y:self.scrollView.frame.origin.y, width:self.scrollView.frame.width, height:100)
        
        var creditCardCount = 0
        if  self.paymentMethods != nil{
            creditCardCount = self.paymentMethods.count
        }

        
        let addCreditCardView = AddCreditCardView(frame: CGRectMake(0, 20, 168, 104) )
        self.scrollView.addSubview(addCreditCardView)
        
        for i in (0..<creditCardCount) {
            let method = self.paymentMethods[i]
            let cc = CreditCardView(frame: CGRectMake(193*CGFloat(i+1), 20, 193, 102), method: method)
            creditCards.addObject(cc)
            cc.delegate = self
            self.scrollView.addSubview(cc)
        }
        
        if creditCardCount == 0 {
            self.editButton.title = ""
            self.editButton.enabled = false
        }else{
            self.editButton.title = self.editMode ? "Done" : "Edit"
            self.editButton.enabled = true
        }
        
        self.scrollView.contentSize = CGSize(width:CGFloat(creditCardCount+1)*193, height:self.scrollView.frame.height)
        
        UIView.animateWithDuration(0.4, animations: {
            if creditCardCount > 0{
                self.scrollView.contentOffset = CGPointMake(193, 0)
            }else{
                self.scrollView.contentOffset = CGPointZero
            }
        })
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.delegate?.backPressed()
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem?) {
        self.editMode = !self.editMode
        self.editButton.title = self.editMode ? "Done" : "Edit"
        
        for cc in creditCards as! [CreditCardView]{
            cc.toggleEditMode()
        }
    }
    
    func deletedPaymentMethod(){
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            self.paymentMethods = array
            for cc in self.creditCards as! [CreditCardView]{
                cc.toggleEditMode()
                self.editButton.title = "Edit"
            }
            self.setCrediCards()
            }, fail: { error in
                
        })
    }
    
    func setPaymentAsDefault(){
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            self.activityView.stopAnimating()
            self.paymentMethods = array
            self.setCrediCards()
            }, fail: { error in
                
        })

    }
    
    func startActivityIndicator() {
            activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .WhiteLarge)
            
            activityView.center=CGPointMake(self.view.center.x, self.view.center.y + 30)
            activityView.startAnimating()
            self.view.addSubview(activityView)
    }
}
