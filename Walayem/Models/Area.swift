//
//  Area.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/16/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
class Area {
    var id: Int?
    var name: String?
    var isSelected: Bool
    
    init(record: [String: Any]){
        self.id = record["city_id"] as? Int
        self.name = record["name"] as? String
        self.isSelected = false
    }
    
    func toogle()  {
        isSelected = !isSelected
    }
}
