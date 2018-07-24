//
//  ConfigurationViewController.swift
//  MyCheckWalletUI_Example
//
//  Created by MSApps on 02/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckWalletUI
import MyCheckCore

class ConfigurationViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var publishKeyField: UITextView!
    @IBOutlet weak var refreshTokenField: UITextView!
    
    @IBOutlet weak var selectallPublishKeyBtn: UIButton!
    @IBOutlet weak var selectallRefreshTokenBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var environmentSeg: UISegmentedControl!
    
    @IBOutlet weak var masterPassSwitch: UISwitch!
    @IBOutlet weak var payPalSwitch: UISwitch!
    @IBOutlet weak var visaCheckoutSwitch: UISwitch!
    
    @IBOutlet weak var publishkeyAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var refreshtokenAspectRatio: NSLayoutConstraint!
    var adjustableTextFieldsHeightConstraint : NSLayoutConstraint?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var token : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConfigurationViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.

        refreshTokenField.layer.cornerRadius = 7
        publishKeyField.layer.cornerRadius = 7
        refreshTokenField.delegate = self
        publishKeyField.delegate = self
        
        activityIndicator.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if nextBtn.layer.cornerRadius < nextBtn.frame.height / 2{
            nextBtn.layer.cornerRadius = nextBtn.frame.height / 2
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.contentSize.height > textView.frame.height){
            let contentSize = textView.sizeThatFits(textView.bounds.size)
            var frame = textView.frame
            frame.size.height = contentSize.height
            textView.frame = frame
            
            adjustableTextFieldsHeightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: textView, attribute: .width, multiplier: textView.bounds.height/textView.bounds.width, constant: 1)
            
            if let constaint = self.adjustableTextFieldsHeightConstraint{
                textView.addConstraint(constaint)
                
                if textView.tag == 1 {
                    self.publishkeyAspectRatio.priority = UILayoutPriority(rawValue: 0)
                }else if textView.tag == 2{
                    self.refreshtokenAspectRatio.priority = UILayoutPriority(rawValue: 0)
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let constaint = self.adjustableTextFieldsHeightConstraint{
            textView.removeConstraint(constaint)
            
            if textView.tag == 1 {
                self.publishkeyAspectRatio.priority = UILayoutPriority(rawValue: 999)
            }else if textView.tag == 2{
                self.refreshtokenAspectRatio.priority = UILayoutPriority(rawValue: 999)
            }
        }
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        sender.isEnabled = false
        showActivityIndicator(true)
        
        if let publishKey = publishKeyField.text ,let refreshToken = refreshTokenField.text{
            
            var selectedEnvierment : Environment?
            
            switch environmentSeg.selectedSegmentIndex{
                case 1:
                    selectedEnvierment = .sandbox
                    break
                case 2:
                    selectedEnvierment = .production
                    break
                default:
                    selectedEnvierment = .test
                    break
            }
            
            Session.shared.configure(publishKey, environment: selectedEnvierment!)
            
            if let regFont = UIFont(name: "OpenSans", size: 10) , let boldFont = UIFont(name: "OpenSans-Bold", size: 10){
                Wallet.shared.setCustomeFonts(regularFont: regFont, boldFont: boldFont)
            }
            
            Session.logDebugData = true
            
            ApplePayFactory.initiate(merchantIdentifier: "merchant.com.mycheck")
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
                // Your code with delay
                DispatchQueue.main.async{
                    
                    if self.payPalSwitch.isOn{
                        PaypalFactory.initiate("com.mycheck.MyCheckWalletUI-Example.payments")
                    }
                
                    if self.visaCheckoutSwitch.isOn{
                        VisaCheckoutFactory.initiate(apiKey: "S8TQIO2ERW9RIHPE82DC13TA9Uv8FdB9Uu7EBRyZHDCNsp7JU")
                    }
                
                    if self.masterPassSwitch.isOn{
                        MasterPassFactory.initiate()
                    }
                    
                    Session.shared.login(refreshToken, success: {
                        //The view should only be displaid after a user is logged in
                        self.showActivityIndicator(false)
                        self.token = refreshToken
                        self.performSegue(withIdentifier: "GoToMainScreen", sender: self)
                    } , fail: { error in
                        
                    })
                    
                    
                }
                
            }
            
            
        }else{
           // please enter publish key and refresh token alert
        }
    }
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            publishKeyField.becomeFirstResponder()
            publishKeyField.selectedTextRange = publishKeyField.textRange(from: publishKeyField.beginningOfDocument, to: publishKeyField.endOfDocument)
        }else if sender.tag == 2{
            refreshTokenField.becomeFirstResponder()
            refreshTokenField.selectedTextRange = refreshTokenField.textRange(from: refreshTokenField.beginningOfDocument, to: refreshTokenField.endOfDocument)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToMainScreen"{
            if let rToken = token , let vc = segue.destination as? ViewController{
                vc.refreshToken = rToken
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showActivityIndicator(_ show: Bool) {
        
        activityIndicator.isHidden = !show
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
    }
    

}
