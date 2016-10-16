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

internal class MCCreditCardsViewController: MCViewController , UIGestureRecognizerDelegate, CreditCardViewDelegate{
  let cardViewWidth = 193.0 as CGFloat
  var startMargin = 106 as CGFloat

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var scrollView: MCScrollView!
    var activityView : UIActivityIndicatorView!
    var paymentMethods: Array<PaymentMethod>!
    var delegate : MCCreditCardsViewControllerrDelegate?
    var creditCards : NSMutableArray = []
    var editMode : Bool = false
    var indexToScrollTo : Int = 0
  var currantIndex : Int = 0
    //MARK: - lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
      startMargin = (UIScreen.mainScreen().bounds.width - cardViewWidth) / 2.0 + 15.0 as CGFloat
      
        self.setCreditCards()
        self.scrollView.delegate = self;
        //self.editButton.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(13)], forState: .Normal)
    }
    
    internal func setCreditCards(){
   
        let subviews = self.scrollView.subviews
        for subview in subviews{
            subview.removeFromSuperview()
        }
        self.scrollView.frame = CGRect(x:self.scrollView.frame.origin.x, y:self.scrollView.frame.origin.y, width:self.scrollView.frame.width, height:100)
        
        var creditCardCount = 0
        if  self.paymentMethods != nil{
            creditCardCount = self.paymentMethods.count
        }

        let addCreditCardView = AddCreditCardView(frame: CGRectMake(startMargin, 20, 168, 104) )
        self.scrollView.addSubview(addCreditCardView)
        
        for i in (0..<creditCardCount) {
            let method = self.paymentMethods[i]
            let cc = CreditCardView(frame: CGRectMake(cardViewWidth*CGFloat(i+1)+startMargin, 20, cardViewWidth, 102), method: method)
            creditCards.addObject(cc)
            cc.delegate = self
            self.scrollView.addSubview(cc)
        }
        
        if creditCardCount == 0 {
            //self.editButton.title = ""
            self.editButton.setTitle("", forState: .Normal)
            self.editButton.enabled = false
        }else{
            //self.editButton.title = self.editMode ? "Done" : "Edit"
            self.editMode ? self.editButton.setTitle("Done", forState: .Normal) : self.editButton.setTitle("Edit", forState: .Normal)
            self.editButton.enabled = true
        }
        
        self.scrollView.contentSize = CGSize(width:CGFloat(creditCardCount+1)*cardViewWidth + startMargin * 2 , height:self.scrollView.frame.height)
        
        UIView.animateWithDuration(0.4, animations: {
            if creditCardCount > 0{
                if self.indexToScrollTo == 0{
                    self.indexToScrollTo =  1
                }
                self.scrollView.contentOffset = CGPointMake(CGFloat(self.indexToScrollTo)*self.cardViewWidth , 0)
              self.currantIndex = self.indexToScrollTo
                self.indexToScrollTo = 0
            }else{
                self.scrollView.contentOffset = CGPointZero
              self.currantIndex = 0
            }
        })
    }
   //MARK: - actions
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.delegate?.backPressed()
        
    }
    
 
    @IBAction func editPressed(_ sender: UIButton) {
        self.editMode = !self.editMode
        //self.editButton.title = self.editMode ? "Done" : "Edit"
        self.editMode ? self.editButton.setTitle("Done", forState: .Normal) : self.editButton.setTitle("Edit", forState: .Normal)
        
        for cc in creditCards as! [CreditCardView]{
            cc.toggleEditMode()
        }

    }
    
    func deletedPaymentMethod(method: PaymentMethod) {
        for i in (0..<self.paymentMethods.count) {
            if method.Id == self.paymentMethods[i].Id {
                if i > 0 {
                    self.indexToScrollTo = i
                }else{
                    self.indexToScrollTo = 0
                }
            }
        }
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            self.paymentMethods = array
            for cc in self.creditCards as! [CreditCardView]{
                cc.toggleEditMode()
            }
            self.editMode = !self.editMode
            //self.editButton.title = "Edit"
            self.editButton.setTitle("Edit", forState: .Normal)
            self.setCreditCards()
            }, fail: { error in
        })
    }
    
    func setPaymentAsDefault(){
        MyCheckWallet.manager.getPaymentMethods({ (array) in
            self.activityView.stopAnimating()
            self.paymentMethods = array
            self.setCreditCards()
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

extension MCCreditCardsViewController : UIScrollViewDelegate {
  
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                                targetContentOffset: UnsafeMutablePointer<CGPoint>){
    let kMaxIndex = 20000 as CGFloat
    let targetX = scrollView.contentOffset.x + velocity.x * 20.0 as CGFloat
    var targetIndex = round(targetX / (cardViewWidth + 0)) as CGFloat
   
//     currantIndex = round( scrollView.contentOffset.x / (cardViewWidth + 0)) as CGFloat
print("currantIndex: \(currantIndex) TargetIndex: \(targetIndex)")
    //taking care of scrollview jumping to its initial position when making very small swipes
    if (velocity.x > 0) {
      targetIndex = ceil(targetX / (self.cardViewWidth + 0.0))
    } else {
      targetIndex = floor(targetX / (self.cardViewWidth + 0.0));
    }
    
    let currantIndexFloat =  CGFloat( currantIndex)
  
    if targetIndex < currantIndexFloat {
    targetIndex =  currantIndexFloat - 1
    }
    if targetIndex > currantIndexFloat {
      targetIndex =  currantIndexFloat + 1
    }
    
    if targetIndex < 0 {
      targetIndex = 0
    }
    if targetIndex > kMaxIndex{
      targetIndex = kMaxIndex
    }
    targetContentOffset.memory.x = targetIndex * (cardViewWidth + 0);
    currantIndex = Int( targetIndex)
  }
}
