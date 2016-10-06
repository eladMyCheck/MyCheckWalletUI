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
    }
    
    internal func setCrediCards(){
        self.scrollView.frame = CGRect(x:self.scrollView.frame.origin.x, y:self.scrollView.frame.origin.y, width:self.scrollView.frame.width, height:100)
        
        UIView.animateWithDuration(0.4, animations: {
            self.scrollView.contentOffset = CGPointZero
        })
        var creditCardCount = 0
        if  self.paymentMethods != nil{
            creditCardCount = self.paymentMethods.count
        }
        
        
        let addCreditCardView = AddCreditCardView(frame: CGRectMake(0, 20, 168, 104) )
        self.scrollView.addSubview(addCreditCardView)
        
        let testMEthod1 = PaymentMethod(JSON: ["id":4, "token" : "5", "exp_month" : 2, "exp_year4" : 2002, "last_4_digits" : "2131", "is_default" : 1, "is_single_use" : 0, "issuer_short" : "visa", "issuer_full" : "visa"])
        let testMEthod2 = PaymentMethod(JSON: ["id":5, "token" : "6", "exp_month" : 3, "exp_year4" : 2003, "last_4_digits" : "2133", "is_default" : 0, "is_single_use" : 0, "issuer_short" : "mastercard", "issuer_full" : "mastercard"])
        let testMEthod3 = PaymentMethod(JSON: ["id":6, "token" : "7", "exp_month" : 4, "exp_year4" : 2004, "last_4_digits" : "2134", "is_default" : 0, "is_single_use" : 0, "issuer_short" : "amex", "issuer_full" : "amex"])
        let testMEthod4 = PaymentMethod(JSON: ["id":7, "token" : "8", "exp_month" : 5, "exp_year4" : 2005, "last_4_digits" : "2135", "is_default" : 0, "is_single_use" : 0, "issuer_short" : "discover", "issuer_full" : "discover"])
        self.paymentMethods = [testMEthod1!, testMEthod2!, testMEthod3!, testMEthod4!]
        creditCardCount = self.paymentMethods.count
        for i in (0..<creditCardCount) {
            let method = self.paymentMethods[i]
            let cc = CreditCardView(frame: CGRectMake(193*CGFloat(i+1), 20, 164, 102), method: method)
            creditCards.addObject(cc)
            cc.delegate = self
            self.scrollView.addSubview(cc)
        }
        
        self.scrollView.contentSize = CGSize(width:CGFloat(creditCardCount+1)*193, height:self.scrollView.frame.height)
    }
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.delegate?.backPressed()
    }
    @IBAction func editPressed(_ sender: UIBarButtonItem?) {
        //self.editMode ? self.editButton.title("Done", forState: .Normal) : self.editButton.setTitleTextAttributes("Edit", forState: .Normal)
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
            activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .WhiteLarge)//[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            activityView.center=CGPointMake(self.view.center.x, self.view.center.y + 30)//self.view.center
            activityView.startAnimating()
            self.view.addSubview(activityView)
    }
}
