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
    
    // Constants
    let merchant_id = "45990"
    let access_code = "AVZG03HH52BB21GZBB"
    let working_key = "1EBF259248E077521944E00A169F91CE"
    
    // Variables
    var orderId = "" // WA1430
    
    var billing = CCAvenueBilling?
    var delivery = CCAvenueDelivery?

    var custId : "TestUser"
    var amount : "10.00"
    
    override func viewDidLoad(){
        let paymentController = CCAvenuePaymentController.init(
            orderId:self.orderId,
            merchantId:self.merchant_id,
            accessCode:self.access_code,
            custId:self.custId,
            amount:self.amount,
            currency:"AED",
            rsaKeyUrl:"www.abc.ae/RSA.jsp", // /payment/ccavenue/cancel
            redirectUrl:"www.abc.ae/Redirect.jsp", // /payment/ccavenue/return
            cancelUrl:"www.abc.ae/Cancel.jsp", // /payment/ccavenue/cancel
            showAddress:"Y",
            
            billingName:self.bill.billingName
            billingAddress:self.bill.billingAddress
            billingCity:self.bill.billingCity
            billingState:self.bill.billingState
            billingCountry:self.bill.billingCountry
            billingTel:self.bill.billingTel
            billingEmail:self.bill.billingEmail
            
            deliveryName:self.delivery.deliveryName
            deliveryAddress:self.delivery.deliveryAddress
            deliveryCity:self.delivery.deliveryCity
            deliveryState:self.delivery.deliveryState
            deliveryCountry:self.delivery.deliveryCountry
            deliveryTel:self.delivery.deliveryTel
            
            promoCode:"",
            merchant_param1:"test",
            merchant_param2:"",
            merchant_param3:"",
            merchant_param4:"" ,
            merchant_param5:"",
            useCCPromo:"" //Y
        )
        
        paymentController?.delegate = self;

        self.present(paymentController!, animated: true, completion: nil);
        
    }

}

extension CCAvenueVC : CCAvenuePaymentControllerDelegate {
    
    func getResponse(_ responseDict_: NSMutableDictionary!) {
        // Dismiss the SDK here before processing a response
        // merchant will get response in Dictionary
        print("Response in merchant app :- \(responseDict_)");
    }
    
}

struct CCAvenueBilling {
    var billingName = "ABC"
    var billingAddress = "Star City"
    var billingCity = "Dubai"
    var billingState = "Dubai"
    var billingCountry = "United Arab Emirates"
    var billingTel = "+971 1234567890"
    var billingEmail = "test@gmail.com"
}

struct CCAvenueDelivery {
    var deliveryName = "XYZ"
    var deliveryAddress = "Internet City"
    var deliveryCity = "Dubai"
    var deliveryState = "Dubai"
    var deliveryCountry = "United Arab Emirates"
    var deliveryTel = "+971 9876543210"
}
