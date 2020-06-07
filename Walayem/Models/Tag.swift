//
//  Tag.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Tag{
    
    var id: Int?
    var name: String?
    
    init(id: Int, name: String){
        self.id = id
        self.name = name
    }
    
//    ▿ 2 elements
//    ▿ 0 : 2 elements
//      - key : "tag_name"
//      - value : نباتي  Vegan
//    ▿ 1 : 2 elements
//      - key : "tag_id"
//      - value : 1
    
    init(record: [String: Any]){
        self.id = record["id"] as? Int ?? 0
        self.name = record["name"] as? String ?? ""
    }
    
    init(rec: [String: Any]) {
        self.id = rec["tag_id"] as? Int ?? 0
        self.name = rec["tag_name"] as? String ?? ""
    }
}
