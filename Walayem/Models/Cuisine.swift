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
    var imageName: String?
    
    init(id: Int, name: String){
           self.id = id
           self.name = name
       }
    init(id: Int, name: String, img: String){
          self.id = id
          self.name = name
          self.imageName = "\(self.id ?? 1).jpg"
    }
    
    init(record: [String: Any]){
        self.id = record["id"] as? Int ?? 0
        self.name = record["name"] as? String ?? ""
    }
}
