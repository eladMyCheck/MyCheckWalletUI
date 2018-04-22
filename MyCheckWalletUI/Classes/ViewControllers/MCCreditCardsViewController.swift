//
//  MCCreditCardsViewController.swift
//  Pods
//
//  Created by Mihail Kalichkov on 9/29/16.
//
//

import UIKit
import MyCheckCore
internal protocol MCCreditCardsViewControllerrDelegate {
    func backPressed()
}

internal class MCCreditCardsViewController: MCViewController , UIGestureRecognizerDelegate, CreditCardViewDelegate{
    @IBOutlet var barItem: UINavigationItem!
    let margin = 5.0 as CGFloat
    var cardViewWidth = 210 as CGFloat
    var startMargin = 106 as CGFloat
    var secondMargin = 5 as CGFloat
    
    @IBOutlet weak var scrollView: MCScrollView!
    @IBOutlet weak var backBut: UIButton!
    var activityView : UIActivityIndicatorView!
    var paymentMethods: Array<PaymentMethodInterface>!
    var delegate : MCCreditCardsViewControllerrDelegate?
    var creditCards : NSMutableArray = []
    var indexToScrollTo : Int = 0
    var currantIndex : Int = 0
    //MARK: - lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        cardViewWidth =  270.0 / 375 * screenWidth
        startMargin = (screenWidth - cardViewWidth + 5) / 2.0  as CGFloat
        
        secondMargin = margin + 5.0
        
        self.scrollView.delegate = self;
        delay(0.1){
            self.setCreditCardsUI(false)
        }
        //setting up UI and updating it if the user logges in... just incase
        Wallet.shared.configureWallet(success: {
               self.setupUI()
        }, fail: nil)
     
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MCCreditCardsViewController.setupUI), name: NSNotification.Name(rawValue: Session.Const.loggedInNotification), object: nil)
        
        barItem.rightBarButtonItem = getRightBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    internal func setCreditCardsUI(_ animated: Bool){
        
        let subviews = self.scrollView.subviews
        for subview in subviews{
            subview.removeFromSuperview()
        }
        let cardHeight = 0.603846153 * cardViewWidth
        var creditCardCount = 0
        if  self.paymentMethods != nil{
            creditCardCount = self.paymentMethods.count
            self.scrollView.isScrollEnabled = creditCardCount > 0
            
        }else{
            self.scrollView.isScrollEnabled = false
        }
        
        if creditCardCount == 0 {
            let addCreditCardView = AddCreditCardView(frame: CGRect(x:startMargin , y: 0.5 * (scrollView.frame.size.height-cardHeight), width: cardViewWidth , height: cardHeight) )
            self.scrollView.addSubview(addCreditCardView)
        }
        
        creditCards.removeAllObjects()
        for i in (0..<creditCardCount) {
            let method = self.paymentMethods[i]
            var frame = CGRect(x:startMargin + ((cardViewWidth + secondMargin) * CGFloat(i)) , y: 0.5 * (scrollView.frame.size.height-cardHeight), width: cardViewWidth , height: cardHeight)
            
            if i == 0{
                frame.origin.x = startMargin
            }
            
            //trying to create a card object, set it up and add it to the scroll view
            if  let card : CreditCardView = {
                if method.type == .creditCard{
                    return  CreditCardView(frame: frame, method: method)
                    
                }else{
                    if let factory = Wallet.shared.getFactory(method.type){
                        
                        guard let cc = factory.getCreditCardView(frame, method: method) else{
                            return nil
                        }
                        return cc
                    }
                }
                return nil
                }(){//if we succeed in creating the card we will now set it up
                
                //updating the width to be more acurate (calculated directly from xib file)
                
                creditCards.add(card)
                card.delegate = self
                self.scrollView.addSubview(card)
            }
        }
        
        if creditCardCount == 0 {
            barItem.rightBarButtonItem = nil
        }else{
            updateButtonTxt()
        }
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * CGFloat(creditCardCount) , height:0.0)
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
            if creditCardCount > 0{
                
                self.scrollView.contentOffset = CGPoint(x: self.getXOffset(index: Int( self.indexToScrollTo)), y: 0)
                self.currantIndex = self.indexToScrollTo
                // self.indexToScrollTo = 0
            }else{
                self.scrollView.contentOffset = CGPoint.zero
                self.currantIndex = 0
            }
        })
    }
    //MARK: - actions
    @IBAction internal func backPressed(_ sender: UIButton) {
        self.delegate?.backPressed()
        
    }
    
    
    @IBAction internal func addPressed(_ sender: UIButton) {
        //call addCard
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AddCreditCardPressed"), object: nil)
    }
    
    internal  func deletedPaymentMethod(_ method: PaymentMethodInterface) {
        for i in (0..<self.paymentMethods.count) {
            if method.ID == self.paymentMethods[i].ID {
                if i > 0 {
                    self.indexToScrollTo = i
                }else{
                    self.indexToScrollTo = 0
                }
            }
        }
        Wallet.shared.getPaymentMethods(success: { (array) in
            self.paymentMethods = array
            self.setCreditCardsUI(true)
        }, fail: { error in
        })
    }
    
    internal func setPaymentAsDefault(method: PaymentMethodInterface){
        if method.type != .applePay{
            Wallet.shared.applePayController.changeApplePayDefault(to: false)
        }
        reloadMethods()
        
    }
    
    internal func reloadMethods(){
        showActivityIndicator(true)
        Wallet.shared.getPaymentMethods(success: { (array) in
            self.showActivityIndicator(false)
            self.paymentMethods = array
            self.setCreditCardsUI(true)
        }, fail: { error in
            self.showActivityIndicator(false)
            
        })
    }
    internal func showActivityIndicator(_ show: Bool) {
        if activityView == nil{
            activityView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
            
            activityView.center=CGPoint(x: self.view.center.x, y: self.view.center.y + 30)
            self.view.addSubview(activityView)
            self.view.bringSubview(toFront: activityView)
            activityView.startAnimating()
            
        }
        activityView.isHidden = !show
    }
    
    @objc fileprivate func setupUI(){
      
        barItem.title = LocalData.manager.getString("managePaymentMethodsheader")
        if let url = LocalData.manager.getBackButtonImageURL(){
            self.barItem.backBarButtonItem?.setImageAsync(url: url)
        }
        self.barItem.backBarButtonItem?.target = self
        self.barItem.backBarButtonItem?.action = #selector(MCCreditCardsViewController.backPressed)
    }
    
    fileprivate func updateButtonTxt(){
//        printIfDebug("edit mode \(editMode)")

        self.barItem.rightBarButtonItem = getRightBarButton()
    }
    
    func  getXOffset(index: Int) -> CGFloat{
        if index == 0 {
            return 0.0
        }
        
        let card : CreditCardView = creditCards.object(at: index) as! CreditCardView
        return card.frame.origin.x - startMargin
    }
}

extension MCCreditCardsViewController : UIScrollViewDelegate {
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>){
        printIfDebug("x location: \(targetContentOffset.pointee.x )")
        
        let kMaxIndex = CGFloat( creditCards.count )
        
        let targetX = scrollView.contentOffset.x + velocity.x * 20.0 as CGFloat
        var targetIndex = round(targetX / (cardViewWidth + 0)) as CGFloat
        
        //     currantIndex = round( scrollView.contentOffset.x / (cardViewWidth + 0)) as CGFloat
        //taking care of scrollview jumping to its initial position when making very small swipes
        if (velocity.x > 0) {
            targetIndex = ceil(targetX / (self.cardViewWidth + 0.0))
        } else {
            targetIndex = floor(targetX / (self.cardViewWidth + 0.0));
        }
        //  printIfDebug("currantIndex: \(currantIndex) TargetIndex: \(targetIndex)")
        
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
        targetContentOffset.pointee.x = getXOffset(index: Int( targetIndex))
        currantIndex = Int( targetIndex)
    }
}

extension MCCreditCardsViewController: navigationItemHasViewController{
    func getNavigationItem() -> UINavigationItem{
        return barItem
    }
}

fileprivate extension MCCreditCardsViewController{
    
    func getRightBarButton() -> UIBarButtonItem{
        
        let title = LocalData.manager.getString("managePaymentMethodsdineAddButton" , fallback: "ADD")
        
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(MCCreditCardsViewController.addPressed))
        return button
    }
}
