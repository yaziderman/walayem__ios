//
//  Order.swift
//  Walayem
//
//  Created by MAC on 5/9/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

enum OrderState: String{
    case sale
    case done
    case cooking
    case ready
    case delivered
    case cancel
    case rejected
}

class Order{
    var id: Int
    var chefId: Int?
    var chefName: String?
    var date: String
    var amount: Double
    var foods: [String]?
    var state: OrderState?
    
    init(record: [String: Any]){
        self.id = record["order_id"] as? Int ?? 0
        self.chefId = record["chef_id"] as? Int
        self.chefName = record["chef_name"] as? String
        self.date = record["date"] as? String ?? ""
        self.amount = record["amount_total"] as! Double
        self.foods = record["products"] as? [String]
        self.state = OrderState.init(rawValue: (record["state"] as? String)!) ?? OrderState(rawValue: "")
    }
}

class OrderDetail: Order{
    
    
    var customer: String
    var chefImage: String
    var createDate: String
    var cancelDate: String
    var cookingDate: String
    var saleDate: String
    var deliveryCost: Int
    var readyDate: String
    var deliveredDate: String
    var doneDate: String
    var kitchen: String
    var note: String
    var reject_reason: String
    var products = [Food]()
    var address: Address?
    
    var shProductNames: String
    var shTotalPrice: Int
    var subTotal: Int
//    var shPhone: String
    
    override init(record: [String: Any]){
        self.customer = record["user_name"] as? String ?? ""
        self.deliveryCost = record["delivery_cost"] as? Int ?? 0
        self.createDate = record["create_date"] as? String ?? ""
        self.chefImage = record["chef_image"] as? String ?? ""
        self.cancelDate = record["datetime_cancel"] as? String ?? ""
        self.cookingDate = record["datetime_cooking"] as? String ?? ""
        self.saleDate = record["datetime_sale"] as? String ?? ""
        self.readyDate = record["datetime_ready"] as? String ?? ""
        self.deliveredDate = record["datetime_delivered"] as? String ?? ""
        self.doneDate = record["datetime_done"] as? String ?? ""
        self.reject_reason = record["reject_reason"] as? String ?? ""
        self.kitchen = record["kitchen_name"] as? String ?? ""
        self.note = record["note"] as? String ?? ""
        
        self.address = Address(record: record["address"] as! [String: Any])
        let products = record["products"] as! [Any]
        self.shProductNames = ""
        self.shTotalPrice = 0
        
        for product in products{
            let food = Food(dict: product as! [String: Any])
            self.products.append(food)
            
            self.shProductNames = shProductNames + "" + (food.name ?? "") + " x "
            self.shProductNames = shProductNames + "" + String(food.quantity) + "\n"
//            self.shProductNames = shProductNames + String(food.price)  + ") \n"
            self.shTotalPrice = shTotalPrice + Int(food.price)
        }
        self.subTotal = self.shTotalPrice + self.deliveryCost
        super.init(record: record)
    }
}
