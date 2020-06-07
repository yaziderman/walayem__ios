//
//  Cart.swift
//  Walayem
//
//  Created by MAC on 5/7/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

enum CartItemType {
    case chef
    case food
    case summary
    case payment
    case address
}

class Cart{
    var type: CartItemType
    var sectionTitle: String
    var rowCount: Int
    
    init(type: CartItemType, sectionTitle: String, rowCount: Int){
        self.type = type
        self.sectionTitle = sectionTitle
        self.rowCount = rowCount
    }
}
