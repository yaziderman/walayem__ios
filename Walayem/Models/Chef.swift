//
//  Chef.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class Chef: Equatable{
	
    static func == (lhs: Chef, rhs: Chef) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    var id: Int = 0
    var name: String = ""
    var kitchen: String = ""
    var description: String = ""
    var image: String = ""
    var rating: Int = 0
    var isFav: Bool = false
    var foods = [Food]()
  
//    init(record: [String: Any]){
//        self.id = record["chef_id"] as! Int
//        self.name = record["chef_name"] as! String
//        self.kitchen = record["kitchen_name"] as! String
//        self.image = record["chef_image_hash"] as? String
//        self.description = record["chef_description"] as? String ?? ""
//
//        let products = record["products"] as! [Any]
//        for product in products{
//            let food = Food(record: product as! [String : Any])
//            self.foods.append(food)
//        }
//    }
	
    init(record: [String: Any], name: String){
        self.id = record["chef_id"] as? Int ?? 0
        self.name = record["chef_name"] as? String ?? ""
//        self.kitchen = record["kitchen_name"] as! String
		let kitchenDetail = record["kitchen"] as? [String: Any] ?? [String: Any]()
        self.kitchen = kitchenDetail["kitchen_name"] as? String ?? ""
		self.image = record["chef_image_hash"] as? String ?? ""
        self.description = record["chef_description"] as? String ?? ""
        
        let products = record["products"] as? [Any] ?? [Any]()
        for product in products{
			let food = Food(record: (product as? [String : Any] ?? [String: Any]()))
            self.foods.append(food)
        }
        print(self.foods)
    }
    
    init(id: Int, name: String, image: String, kitchen: String, foods: [Food]){
        self.id = id
        self.name = name
        self.image = image
        self.kitchen = kitchen
        self.foods = foods
    }
    
}
