//
//  PaymentViewController.swift
//  Walayem
//
//  Created by deya on 10/15/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import WebKit

class PaymentViewController : UIViewController {
    
    @IBOutlet weak var webView : WKWebView?
    
    var order_id = ""
    var enc = ""
    
    override func viewDidLoad() {
        
//        SwiftLoading().showLoading()
        
//        DispatchQueue.main.
        
        webView?.contentMode = .scaleAspectFit
        webView?.contentScaleFactor = 1.0
        
        webView?.navigationDelegate = self

        let url = URL(string: generatePaymentLink())!
        
        print("generated_url",url)
        webView?.load(URLRequest(url: url))
        webView?.allowsBackForwardNavigationGestures = true
    }
    
}

extension PaymentViewController {
    //enc for example : c2a89729d26f1bd3fddb53efdb57cfe0
    
    func generatePaymentLink() -> String {
        //return "https://app.walayem.com/ccavRequestHandler?order_id=\(self.order_id)&return_url=/payment/ccavenue/return&cancel_url=/payment/ccavenue/cancel&language=EN&merchant_param1=test&enc=\(self.enc)"
        return "\(WalayemApi.BASE_URL)/ccavRequestHandler?order_id=\(self.order_id)&return_url=/payment/ccavenue/return&cancel_url=/payment/ccavenue/cancel&language=EN&merchant_param1=test&enc=\(self.enc)"

    }
}

//extension PaymentViewController : WKUIDelegate {
//    
//}

extension PaymentViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("WK_didCommit",webView.url!.absoluteString)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let contentSize:CGSize = self.webView!.scrollView.contentSize
        let viewSize:CGSize = self.view.bounds.size

        let rw: CGFloat = viewSize.width / contentSize.width

        self.webView?.scrollView.minimumZoomScale = rw
        self.webView?.scrollView.maximumZoomScale = rw
        self.webView?.scrollView.zoomScale = rw 
        
        print("WK_didFinish",webView.url!.absoluteString)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WK_didFail",webView.url!.absoluteString)
    }
}
