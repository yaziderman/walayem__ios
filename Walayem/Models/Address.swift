//
//  Address.swift
//  Walayem
//
//  Created by MAC on 5/6/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Address{
    
    var id: Int
    var name: String
    var city: String
    var street: String
    var extra: String
    var phone: String?
    
    init(id: Int, name: String, city: String, street: String, extra: String){
        self.id = id
        self.name = name
        self.city = city
        self.street = street
        self.extra = extra
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as! Int
        self.name = record["address_name"] as! String
        self.city = record["city"] as! String
        self.street = record["street"] as! String
        self.extra = record["street2"] as! String
        self.phone = record["phone"] as? String
    }
}
