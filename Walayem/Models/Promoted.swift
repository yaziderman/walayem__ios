//
//  Promoted.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/8/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation

class ChefInfo {
    let id: Int?
    let name: String?
    
    init(id:Int, name:String) {
        self.id = id as? Int ?? 0
        self.name = name as? String ?? ""
    }
    init(record: [String: Any]){
        self.id = record["id"] as? Int ?? 0
        self.name = record["name"] as? String ?? ""
    }
}

class PromotedItem{
    var kitchen_name: String?
    var end_date: String?
    var id: Int?
    var cuisine: String?
    
    var chefInfo: ChefInfo?
    var start_date: String?
    var chef_name: String?
    var chef_image_hash: String?
    var item_details: ItemDetail?
    
    init(records: [String: Any]) {
        self.kitchen_name = records["kitchen_name"] as? String
        self.end_date = records["end_date"] as? String
        self.id = records["id"] as? Int
        self.chef_name = records["chef_name"] as? String
        
        self.chef_image_hash = records["chef_image_hash"] as? String
        if records["item_id"] != nil {
            let item_Ids = records["item_id"] as![Any]
            self.chefInfo = ChefInfo(id: item_Ids[0] as! Int, name: item_Ids[1]as! String)
        }
        
        
        self.cuisine = records["cuisine"] as? String
        self.start_date = records["start_date"] as? String
        self.item_details = ItemDetail(records["item_details"] as! [Any])
    }
}

class ItemDetail{
    var image_hash: String?
    var comment: String?
    var name: String?
//    var chef_name: String?
    var id: Int?
    var kitchen_id: [Int: String]?
    var products: String?
    var favorite_products: [Int]?
    var preparation_time: Int?
    var serves: Int?
    var list_price: Double?
    var chef_id: Int?
    var food_type: String?
    var description_sale: String?
    
    var food_tags : [Tag]?
    var cuisine_id: Cuisine?
    var food_image_ids: [Int]?
    
    init(_ records: [Any]?) {
        if let tempRecords = records{
            if tempRecords.count > 0, let record = tempRecords[0] as? [String:Any]{
                self.name = record["name"] as? String
//                self.chef_name = record["chef_name"] as? String
                self.comment = record["comment"] as? String
                self.image_hash = record["image_hash"] as? String
                self.kitchen_id = record["kitchen_id"] as? [Int: String]
                self.products = record["products"] as? String
                self.favorite_products = record["favorite_products"] as? [Int]
                
                if record["food_image_ids"] != nil{
                    self.food_image_ids?.removeAll()
                    let tempImageIds = record["food_image_ids"] as! [Int]
                    self.food_image_ids = tempImageIds
                }
                if record["chef_id"] != nil{
                   let tempChef = record["chef_id"] as! [Any]
                    self.chef_id = tempChef[0] as! Int
                }
                if record["food_tags"] != nil{
                    let tags = record["food_tags"] as! [Any]
                    print(tags[0])
                    var mTagsList = [Tag]()
                    for tag in tags{
                        let mTag = Tag(rec: tag as! [String : Any])
                        mTagsList.append(mTag)
                    }
                    self.food_tags = mTagsList
                }
                
                if record["cuisine_id"] != nil {
                    let cuisine = record["cuisine_id"] as! [Any]
                    self.cuisine_id = Cuisine(id: cuisine[0] as! Int, name: cuisine[1] as! String)
                    print(self.cuisine_id)
                }
                self.id = record["id"] as? Int
                self.preparation_time = record["preparation_time"] as? Int
                self.serves = record["serves"] as? Int
                if let price = record["list_price"]{
                    self.list_price = price as? Double
                }else{
                    self.list_price = 0
                }
                self.description_sale = record["description_sale"] as? String
                self.food_type = record["food_type"] as? String
                
            }
        }
    }
    
}

//class HRecommended{
//    var end_date: String?
//    var cuisine: String?
//    var id: Int?
//    var item_id: [Int: String]?
//    var start_date: String?
////    var item_details = RecommendedItemDetail?
//
//    init(records: [String: Any]) {
//        self.cuisine = records["cuisine"] as? String
//        self.end_date = records["end_date"] as? String
//        self.id = records["id"] as? Int
//        self.item_id = records["item_id"] as? [Int: String]
//        self.start_date = records["start_date"] as? String
//
////        self.item_details = RecommendedItemDetail(records: records["item_details"] as? [String : Any] ?? ["":""])
//    }
//
//}
//
//class RecommendedItemDetail{
//    var name: String?
//    var preparation_time: String?
//    var id: Int?
//    var cuisine_id: [Int: String]?
//    var food_image_ids: [Int]?
//    var serves: Int?
//    var list_price: Int?
//    var food_type: String?
//    var description_sale: String?
//    var food_tags: [Int]?
//
//
//    init(records: [String: Any]) {
//        self.name = records["name"] as? String
//        self.preparation_time = records["preparation_time"] as? String
//        self.id = records["id"] as? Int
//        self.cuisine_id = records["cuisine_id"] as? [Int: String]
//        self.food_image_ids = records["food_image_ids"] as? [Int]
//        self.serves = records["serves"] as? Int
//        self.list_price = records["list_price"] as? Int
//        self.food_type = records["food_type"] as? String
//        self.description_sale = records["description_sale"] as? String
//        self.food_tags = records["food_tags"] as? [Int]
//    }
//}
//
//class PTodaysMeal{
//    var id: Int?
//    var end_date: String?
//    var start_date: String?
//    var item_details: [PMealItemDetail]?
//    var item_id: [String]?
//    var kitchen_name: String?
//
//    init(records: [String: Any]) {
//        self.id = records["id"] as? Int
//        self.end_date = records["end_date"] as? String
//        self.start_date = records["start_date"] as? String
//        self.item_details = records["item_details"] as? [PMealItemDetail]
//        self.kitchen_name = records["kitchen_name"] as? String
//        self.item_id = records["item_id"] as? [String]
//    }
//}
//
//class PMealItemDetail{
//    var comment:String?
//    var favorite_products: [String]?
//    var id:Int?
//    var image_hash:String?
//    var kitchen_id: [String]?
//    var name:String?
//    var products:String?
//
//    init(records: [String: Any]) {
//           self.name = records["name"] as? String
//           self.comment = records["comment"] as? String
//           self.image_hash = records["image_hash"] as? String
//           self.kitchen_id = records["kitchen_id"] as? [String]
//           self.products = records["products"] as? String
//           self.favorite_products = records["favorite_products"] as? [String]
//           self.id = records["id"] as? Int
//       }
//
//}
