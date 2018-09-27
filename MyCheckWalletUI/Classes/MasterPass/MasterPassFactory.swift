//
//  PaypalViewController.swift
//  Pods
//
//  Created by elad schiller on 11/10/16.
//
//

import UIKit
import MyCheckCore

open class MasterPassFactory : PaymentMethodFactory{
    
    //was the factory ever initiated.
    static var initiated = false
    static var masterPassURL: String?
    override var type : PaymentMethodType { get { return PaymentMethodType.masterPass }}
    
    public static func initiate(){
        if !initiated {
            let factory = MasterPassFactory()
            Wallet.shared.factories.append(factory)
            Networking.shared.configure(success: {JSON in
                guard let walletJSON = JSON["wallet"] as? [String: Any],
                    let walletUIJSON = walletJSON["walletUI"] as? [String: Any],
                    let masterpassJSON = walletUIJSON["masterpass"] as? [String: Any],
                    let urlStr = masterpassJSON["url"] as? String else{
                        return
                }
                masterPassURL = urlStr
                initiated = true
                
                
            }, fail: nil)
            
        }
    }
    
    override func getAddMethodViewControllere(  ){
        
        guard let delegate = self.delegate ,
            let url = MasterPassFactory.masterPassURL else{
                return
        }
        
        showUserConsentMessage { allow in 
           
            if !allow{
                return
            }
            
            delegate.showLoadingIndicator(self, show: true)
            
            Wallet.shared.getMasterPassCredentials(masterPassURL: url, success: {payload in
                
                delegate.showLoadingIndicator(self, show: false)
                let controller = AddMasterPassViewController(url: MasterPassFactory.masterPassURL!, payload: payload, delegate: self)
                delegate.displayViewController(controller)
           
            
            }, fail: {error in
                if let delegate = self.delegate{
                    delegate.error(self, error: error)
                    delegate.showLoadingIndicator(self, show: false)
                    
                }
                
            })

        }
        
        
        
    }
    
    override func getAddMethodButton(presenter: UIViewController) -> PaymentMethodButtonRapper {
        
        let butRap = PaymentMethodButtonRapper(forType: .masterPass)
        butRap.button.translatesAutoresizingMaskIntoConstraints = false
        let innerBut = UIImageView()
        innerBut.kf.setImage(with: URL(string:LocalData.manager.getString("walletImgMasterpass")))
        innerBut.translatesAutoresizingMaskIntoConstraints = false
        innerBut.contentMode = .scaleAspectFit
        butRap.button.addSubview(innerBut)
        
        innerBut.centerXAnchor.constraint(equalTo: butRap.button.centerXAnchor).isActive = true
        innerBut.centerYAnchor.constraint(equalTo: butRap.button.centerYAnchor).isActive = true
        
        let heightConstraint = NSLayoutConstraint(item: innerBut,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: butRap.button,
                                                  attribute: .height,
                                                  multiplier: 0.92,
                                                  constant: 0)
        
        butRap.button.addConstraint(heightConstraint)
        butRap.button.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
        return butRap
    }
    
    @objc fileprivate func addMethodButPressed(_ sender: UIButton){
       
        
        getAddMethodViewControllere()
    }
    
    override func getSmallAddMethodButton(presenter: UIViewController) -> PaymentMethodButtonRapper{
        var butRap = super.getSmallAddMethodButton(presenter: presenter)
        
        butRap.type = .masterPass
        
        //  let i = LocalData.manager.getString("walletImgMasterpassCheckout")
        
        //  let bundle =  MCViewController.getBundle( Bundle(for: MCAddCreditCardViewController.classForCoder()))
        butRap.button.kf.setImage(with: URL( string: LocalData.manager.getString("walletImgMasterpassCheckout") ), for: .normal , options: [.scaleFactor(3.0)])
        
        
        butRap.button.addTarget(self, action: #selector(MasterPassFactory.addMethodButPressed(_:)), for: .touchUpInside)
        
        return butRap
    }
}


fileprivate extension MasterPassFactory{
     func showUserConsentMessage(complition: @escaping (Bool)-> Void){
        
        let texts = LocalData.manager.getConsentAlertTexts()
        let alert = UIAlertController(title: nil, message: texts.message, preferredStyle: .alert);
        
        let yesBut = UIAlertAction(title: texts.positiveBut, style: .default, handler:
        {(alert: UIAlertAction!) in
            complition(true)
            
        })
        
        let noBut = UIAlertAction(title: texts.negativeBut, style: .destructive, handler:
        {(alert: UIAlertAction!) in
            complition(false)
            
        })
        alert.addAction(noBut)
        
        alert.addAction(yesBut)
        self.delegate?.displayViewController(alert)
    }


}

extension MasterPassFactory : AddMasterPassViewControllerDelegate{
    
    
    
    internal func addMasterPassViewControllerComplete(controller: UIViewController , reason:AddMasterPassViewControllerCompletitionReason){
        
        
        switch reason {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)

            break;
        case .failed(let error):
            masterPassFailed(controller: controller, error: error)
            
        case .success(let payload):
            masterpassSuccess(controller: controller  , payload: payload)
        }
        
    }
    
    
    private func masterpassSuccess(controller: UIViewController  ,payload: String){
        if let delegate = self.delegate{
            delegate.dismissViewController(controller)
            delegate.showLoadingIndicator(self, show: true)
            let singleUse = delegate.shouldBeSingleUse(self)
            Wallet.shared.addMasterPass(payload: payload, singleUse: singleUse, success: {method in
                if let delegate = self.delegate ,  let method = method{
                    Wallet.shared.addedAPaymentMethod()
                    delegate.addedPaymentMethod(self, method: method , message: LocalData.manager.getAddedMasterPassMessage())
                    delegate.showLoadingIndicator(self, show: false)

                }
            }, fail: {error in
                if let delegate = self.delegate{
                    delegate.error(self, error: error)
                    delegate.showLoadingIndicator(self, show: false)
                }
            })
        }
    }
    
    
    private func masterPassFailed(controller: UIViewController, error: NSError){
        if let delegate = self.delegate{
            delegate.error(self, error: error)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
   }





