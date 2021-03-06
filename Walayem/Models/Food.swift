//
//  Food.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Food{
    
    var id: Int
    var name: String
    var description: String?
    var foodType: String?
    var price : Double
    var preparationTime: Int = 0
    var quantity: Int = 0
    var servingQunatity: Int = 0
    var cuisine: Cuisine?
    var imageIds: [Int]?
    var tags = [Tag]()
    var chefId: Int?
    var chefName: String?
    var chefImage: String?
    var kitcherName: String?
    var paused: Bool = false
    var isFav: Bool = false
    
    init(record: [String: Any]){
        self.id = record["id"] as! Int
        self.name = record["name"] as! String
        self.description = record["description_sale"] as? String
        self.foodType = record["food_type"] as? String
        self.price = record["list_price"] as! Double
        self.preparationTime = record["preparation_time"] as! Int
        self.servingQunatity = record["serves"] as! Int
        self.imageIds = record["food_image_ids"] as? [Int]
        self.chefId = record["chef_id"] as? Int ?? 0
        self.chefName = record["chef_name"] as? String ?? ""
        self.chefImage = record["chef_image_hash"] as? String ?? "0"
        self.kitcherName = record["kitchen_name"] as? String ?? ""
        self.paused = record["paused"] as? Bool ?? false
        
        let foodTags = record["food_tags"] as! [Any]
        for foodTag in foodTags{
            let tag = Tag(record: foodTag as! [String : Any])
            self.tags.append(tag)
        }
        self.cuisine = Cuisine(record: record["food_cuisine"] as! [String: Any])
    }
    
    init(dict: [String: Any]){
        self.id = dict["id"] as! Int
        self.name = dict["name"] as! String
        self.price = dict["price"] as! Double
        self.quantity = dict["quantity"] as! Int
        self.preparationTime = dict["preparation_time"] as! Int
    }
    
    init(id: Int, name: String, price: Double, quantity: Int){
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
    }
    
    init(id: Int, name: String, price: Double, quantity: Int, preparationTime: Int){
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.preparationTime = preparationTime
    }
}
