//
//  CCAvenueManager.swift
//  Walayem
//
//  Created by deya on 10/12/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import CCAvenueSDK

class CCAvenueVC : UIViewController {
    
    let paymentController = CCAvenuePaymentController.init(
        orderId:"1234",
        merchantId:"79562" ,
        accessCode:"ABHGH784GFDE",
        custId:"TestUser",
        amount:"10.00",
        currency:"AED",
        rsaKeyUrl:"www.abc.ae/RSA.jsp",
        redirectUrl:"www.abc.ae/Redirect.jsp",
        cancelUrl:"www.abc.ae/Cancel.jsp",
        showAddress:"Y",
        billingName:"ABC",
        billingAddress:"Star City",
        billingCity:"Dubai",
        billingState:"Dubai",
        billingCountry:"United Arab Emirates",
        billingTel:"+971 1234567890",
        billingEmail:"test@gmail.com",
        deliveryName:"XYZ",
        deliveryAddress:"Internet City",
        deliveryCity:"Dubai",
        deliveryState:"Dubai",
        deliveryCountry:"United Arab Emirates",
        deliveryTel:"+971 9876543210",
        promoCode:"PROMO1270" ,
        merchant_param1:"Param 1",
        merchant_param2:"Param 2",
        merchant_param3:"Param 3",
        merchant_param4:"Param 4" ,
        merchant_param5:"Param 5",
        useCCPromo:"Y"
    )
    
    
    func initScreen(){
        self.present(paymentController!, animated: true, completion: nil);
    }
    
    override func viewDidLoad(){
        paymentController?.delegate = self;

    }

}

extension CCAvenueVC : CCAvenuePaymentControllerDelegate {
    
    func getResponse(_ responseDict_: NSMutableDictionary!) {
        // Dismiss the SDK here before processing a response
        // merchant will get response in Dictionary
        print("Response in merchant app :- \(responseDict_)");
    }
    
}
