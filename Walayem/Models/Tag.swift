//
//  Tag.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Tag{
    
    var id: Int
    var name: String
    
    init(id: Int, name: String){
        self.id = id
        self.name = name
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as! Int
        self.name = record["name"] as! String
    }
}
