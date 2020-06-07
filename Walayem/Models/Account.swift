//
//  Account.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
class Account{
    var month: String?
    var amount_total: Double?
    var state: Int
    var orders_count: Int
    
    init(record: [String: Any]){
        self.month = record["month"] as? String
        self.state = record["state"] as! Int
        self.orders_count = record["orders_count"] as! Int
        self.amount_total = record["amount_total"] as? Double
    }
}

