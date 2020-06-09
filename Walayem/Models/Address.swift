//
//  Address.swift
//  Walayem
//
//  Created by MAC on 5/6/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

<<<<<<< HEAD
class Address {
=======
class Address{
>>>>>>> Production
    
    var id: Int
    var name: String
    var city: String
    var street: String
    var extra: String
    var phone: String?
<<<<<<< HEAD
    var location: Location?
    
    init(id: Int, name: String, city: String, street: String, extra: String, location: Location?){
=======
    
    init(id: Int, name: String, city: String, street: String, extra: String){
>>>>>>> Production
        self.id = id
        self.name = name
        self.city = city
        self.street = street
        self.extra = extra
<<<<<<< HEAD
        self.location = location
=======
>>>>>>> Production
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as! Int
        self.name = record["address_name"] as! String
        self.city = record["city"] as! String
        self.street = record["street"] as! String
        self.extra = record["street2"] as! String
        self.phone = record["phone"] as? String
<<<<<<< HEAD
        
        if let locationDict = record["location"] as? [String: Any] {
            guard let latStr = locationDict["lat"] as? String, let lat = Double(latStr) else { return }
            guard let longStr = locationDict["long"] as? String, let long = Double(longStr) else { return }
            self.location = Location(latitude: lat, longitude: long)
        }
=======
>>>>>>> Production
    }
}
