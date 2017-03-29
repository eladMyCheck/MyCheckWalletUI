//
//  AddMasterPassViewController.swift
//  Pods
//
//  Created by elad schiller on 3/27/17.
//
//

import Foundation
import WebKit

protocol AddMasterPassViewControllerDelegate{
    func addMasterPassReturned(payload: String);
    func masterPassFailed(error: NSError);
}
class AddMasterPassViewController : UIViewController{
    private var webView: WKWebView?
    internal var delegate: AddMasterPassViewControllerDelegate;
    
    init(delegate: AddMasterPassViewControllerDelegate) {
        self.delegate = delegate

         super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    // MARK - lifecycle functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: self.view.frame)
        
        if let url = URL(string: "https://google.com") {
            let req = URLRequest(url: url )
            webView?.load(req)
        }
    }
}
