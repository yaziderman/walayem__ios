//
//  Address.swift
//  Walayem
//
//  Created by MAC on 5/6/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Address {
    
    var id: Int
    var name: String = ""
    var city: String = ""
	var street: String = ""
    var extra: String = ""
    var phone: String? = ""
    var location: Location?
    var address_lat = ""
    var address_lon = ""
    
    init(id: Int, name: String, city: String, street: String, extra: String, location: Location?){
        self.id = id
        self.name = name
        self.city = city
        self.street = street
        self.extra = extra
        self.location = location
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as! Int
		
		if let name = record["address_name"] as? String {
			self.name = name
		}
		
		if let city = record["city"] as? String {
			self.city = city
		}
		
        self.street = record["street"] as? String ?? ""
        self.extra = record["street2"] as? String ?? ""
        self.phone = record["phone"] as? String
        self.address_lat = record["customer_lat"] as? String ?? ""
        self.address_lon = record["customer_long"] as? String ?? ""
        
        if let locationDict = record["location"] as? [String: Any] {
            guard let latStr = locationDict["lat"] as? String, let lat = Double(latStr) else { return }
            guard let longStr = locationDict["long"] as? String, let long = Double(longStr) else { return }
            self.location = Location(latitude: lat, longitude: long)
        }
    }
}
