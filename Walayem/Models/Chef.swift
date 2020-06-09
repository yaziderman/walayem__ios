//
//  Chef.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

<<<<<<< HEAD
class Chef: Equatable {
=======
class Chef: Equatable{
>>>>>>> Production
    static func == (lhs: Chef, rhs: Chef) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    
    var id: Int
    var name: String
<<<<<<< HEAD
    var kitchen: String
=======
    var kitchen: String = ""
>>>>>>> Production
    var description: String = ""
    var image: String?
    var rating: Int?
    var isFav: Bool = false
    var foods = [Food]()
  
    init(record: [String: Any]){
        self.id = record["chef_id"] as! Int
        self.name = record["chef_name"] as! String
        self.kitchen = record["kitchen_name"] as! String
        self.image = record["chef_image_hash"] as? String
        self.description = record["chef_description"] as? String ?? ""
        
        let products = record["products"] as! [Any]
        for product in products{
            let food = Food(record: product as! [String : Any])
            self.foods.append(food)
        }
    }
    
<<<<<<< HEAD
=======
    init(record: [String: Any], name: String){
        self.id = record["id"] as! Int
        self.name = record["name"] as! String
//        self.kitchen = record["kitchen_name"] as! String
        let kitchenDetail = record["kitchen"] as! [String: Any]
        self.kitchen = kitchenDetail["name"] as? String ?? ""
        self.image = record["chef_image_hash"] as? String
        self.description = record["chef_description"] as? String ?? ""
        
        let products = record["products"] as! [Any]
        for product in products{
            let food = Food(record: product as! [String : Any])
            self.foods.append(food)
        }
        print(self.foods)
    }
    
>>>>>>> Production
    init(id: Int, name: String, image: String, kitchen: String, foods: [Food]){
        self.id = id
        self.name = name
        self.image = image
        self.kitchen = kitchen
        self.foods = foods
    }
    
}
