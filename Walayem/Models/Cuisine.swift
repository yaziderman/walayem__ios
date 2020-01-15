//
//  Cuisine.swift
//  Walayem
//
//  Created by MAC on 5/3/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Cuisine{
    
    var id: Int?
    var name: String?
    
    init(id: Int, name: String){
        self.id = id
        self.name = name
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as? Int ?? 0
        self.name = record["name"] as? String ?? ""
    }
}
