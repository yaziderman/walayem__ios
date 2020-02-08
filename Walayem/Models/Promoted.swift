//
//  promoted.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/6/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation


struct Promoted{
    
    let id: Int?
    let result: [result]?
    let jsonrpc: String?
    
    
}

struct result{
    let status: Bool?
    let best_sellers: [best_seller]?
    let recommended: [recommended]?
    let todays_meals: [TodaysMeal]?
    let advertisment_image: String?
}

struct best_seller{
    let kitchen_name: String
    let end_date: String
    let id: Int
    let item_id: [Int: String]
    let start_date: String
    let item_details: [bestSellerItemDetails]
}

struct bestSellerItemDetails{
    let image_hash: String
    let comment: String
    let name: String
    let id: Int
    let kitchen_id: [Int: String]
    let products: String?
    let favorite_products: [Int]?
}

struct recommended{
    let end_date: String?
    let cuisine: String?
    let id: Int?
    let item_id: [Int: String]?
    let start_date: String?
    let item_details : [recommendedItemDetail]?
}

struct recommendedItemDetail{
    let name: String
    let preparation_time: String
    let id: Int
    let cuisine_id: [Int: String]?
    let food_image_ids: [Int]
    let serves: Int
    let list_price: Int
    let food_type: String
    let description_sale: String
    let food_tags: [Int]
}

struct TodaysMeal{
    let id: Int
    let end_date: String
    let start_date: String
    let item_details: MealItemDetail
    let item_id: [String]
    let kitchen_name: String
}

struct MealItemDetail{
    let comment:Int
    let favorite_products: [String]
    let id:Int
    let image_hash:Int
    let kitchen_id: [String]
    let name:String
    let products:String
}


//struct TodaysMeal: Decodable{
//
//    let id: Int
//    let end_date: String
//    let start_date: String
//    let item_details: MealItemDetail
//    let item_id: ()
//    let kitchen_name: String
//}
//
//struct MealItemDetail{
//    let comment:Int
//    let favorite_products:()
//    let id:Int
//    let image_hash:Int
//    let kitchen_id:()
//    let name:String
//    let products:String
//}


//class Promoted{
//    
//    var status: [String : Any]
//    var best_sellers: [String : Any]
//    var recommended: [String : Any]
//    var todays_meals: [String : Any]
//    var advertisment_image: [String : Any]
//    
////    init(record: [String : Any]) {
////
////    }
//}
