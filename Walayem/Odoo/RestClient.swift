//
//  RestClient.swift
//  Walayem
//
//  Created by MAC on 4/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import Alamofire

class RestClient{
    
    private var headers: HTTPHeaders
    
    // MARK: Initialization
    init(){
        guard let sessionId = UserDefaults.standard.string(forKey: "sessionId") else{
            headers = [:]
            return
        }
        headers = [
            "Accept": "application/json",
            "Cookie": "session_id=\(sessionId)"
        ]
    }
    
    
    func request(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
        
        let jsonParam : [String: Any] = ["jsonrpc": "2.0",
                                         "id": Int(Date().timeIntervalSince1970),
                                         "params": params]
        print(Int(Date().timeIntervalSince1970))
        
        Alamofire.request(url, method: .post, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON { (response) in
            if response.result.isSuccess{
                let value: [String: Any] = response.result.value as! [String: Any]
                if let error = value["error"] as? [String: Any]{
                    completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
                }else{
                    completionHandler(value, nil)
                }
            }else{
                completionHandler(nil, response.result.error as NSError?)
            }
        }
    }
    
    
    func requestPromotedApi(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
            
            
        let parameter = [String:AnyObject]()
        
            Alamofire.request(url, method: .post, parameters: parameter , encoding: JSONEncoding.default, headers: headers).validate()
            .responseJSON { (response) in
                
                if response.result.isSuccess{
                    let value: [String: Any] = response.result.value as! [String: Any]
                    if let error = value["error"] as? [String: Any]{
                        completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
                    }else{
                        completionHandler(value, nil)
                    }
                }else{
                    completionHandler(nil, response.result.error as NSError?)
                }
            }
            
        }
        
    
    
    
    
//
//    func requestNewApi(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
//
//           let jsonParam : [String: Any] = ["jsonrpc": "2.0",
//                                            "id": Int(Date().timeIntervalSince1970),
//                                            "params": params]
//
//        headers = ["Content-Type": "application/json"]
//
//        Alamofire.request(WalayemApi.homeRecommendation, headers: headers).responseJSON { response in
//            print(response.request)   // original url request
//            print(response.response) // http url response
//            print(response.result)  // response serialization result
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//        }
        
       
    
    
//    func requestHomeApis(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
//
//        let jsonParam : [String: Any] = ["":""]
//
//         headers = ["Content-Type": "application/json"]
//
//        Alamofire.request(url, method: .get, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
//        .validate()
//        .responseJSON { (response) in
//            if response.result.isSuccess{
//                let value: [String: Any] = response.result.value as! [String: Any]
//                if let error = value["error"] as? [String: Any]{
//                    completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
//                }else{
//                    completionHandler(value, nil)
//                }
//            }else{
//                completionHandler(nil, response.result.error as NSError?)
//            }
//        }
//    }
//
}
//
//struct Promoted{
//    
//    var id: Int?
//    var result: Results?
//    var jsonrpc: String?
//    
//    init(records: [String: Any]) {
//        self.id = records["id"] as? Int
//        self.result = Results(records: records["result"] as? [String: Any] ?? ["No results":false])
//        self.jsonrpc = records["jsonrpc"] as? String
//    }
//}
//
//struct Results{
//    var status: Bool?
//    var best_sellers: [Best_seller]?
//    var recommended: [RecommendedHome]?
//    let todays_meals: [TodaysMeal]?
//    let advertisment_image: String?
//    
//    init(records: [String: Any]) {
//        self.status = records["status"] as? Bool
//        self.recommended = [RecommendedHome(records: records["recommended"] as? [String: Any] ?? ["No recommended":false])]
//        self.best_sellers = [Best_seller(records: records["best_sellers"] as? [String: Any] ?? ["No best_sellers":false])]
//        self.todays_meals = [TodaysMeal(records: records["todays_meals"] as? [String: Any] ?? ["No todays_meals":false])]
//        self.advertisment_image = records[""] as? String
//    }
//}
//
//struct Best_seller{
//    let kitchen_name: String?
//    let end_date: String?
//    let id: Int?
//    let item_id: [Int: String]?
//    let start_date: String?
//    let item_details: [bestSellerItemDetails]?
//    
//    init(records: [String: Any]) {
//        self.kitchen_name = records["kitchen_name"] as? String
//        self.end_date = records["end_date"] as? String
//        self.id = records["id"] as? Int
//        self.item_id = records["item_id"] as? [Int: String]
//        self.start_date = records["start_date"] as? String
//        self.item_details = records["item_details"] as? [bestSellerItemDetails]
//    }
//}
//
//struct bestSellerItemDetails{
//    let image_hash: String?
//    let comment: String?
//    let name: String?
//    let id: Int?
//    let kitchen_id: [Int: String]?
//    let products: String?
//    let favorite_products: [Int]?
//    
//    init(records: [String: Any]) {
//        self.name = records["name"] as? String
//        self.comment = records["comment"] as? String
//        self.image_hash = records["image_hash"] as? String
//        self.kitchen_id = records["kitchen_id"] as? [Int: String]
//        self.products = records["products"] as? String
//        self.favorite_products = records["favorite_products"] as? [Int]
//        self.id = records["id"] as? Int
//    }
//    
//}
//
//struct RecommendedHome{
//    let end_date: String?
//    let cuisine: String?
//    let id: Int?
//    let item_id: [Int: String]?
//    let start_date: String?
//    let item_details : [recommendedItemDetail]?
//    
//    
//    init(records: [String: Any]) {
//        self.cuisine = records["cuisine"] as? String
//        self.end_date = records["end_date"] as? String
//        self.id = records["id"] as? Int
//        self.item_id = records["item_id"] as? [Int: String]
//        self.start_date = records["start_date"] as? String
//        self.item_details = records["item_details"] as? [recommendedItemDetail]
//    }
//    
//}
//
//struct recommendedItemDetail{
//    let name: String?
//    let preparation_time: String?
//    let id: Int?
//    let cuisine_id: [Int: String]?
//    let food_image_ids: [Int]?
//    let serves: Int?
//    let list_price: Int?
//    let food_type: String?
//    let description_sale: String?
//    let food_tags: [Int]?
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
//struct TodaysMeal{
//    let id: Int?
//    let end_date: String?
//    let start_date: String?
//    let item_details: [MealItemDetail]?
//    let item_id: [String]?
//    let kitchen_name: String?
//    
//    init(records: [String: Any]) {
//        self.id = records["id"] as? Int
//        self.end_date = records["end_date"] as? String
//        self.start_date = records["start_date"] as? String
//        self.item_details = records["item_details"] as? [MealItemDetail]
//        self.kitchen_name = records["kitchen_name"] as? String
//        self.item_id = records["item_id"] as? [String]
//    }
//}
//
//struct MealItemDetail{
//    let comment:String?
//    let favorite_products: [String]?
//    let id:Int?
//    let image_hash:String?
//    let kitchen_id: [String]?
//    let name:String?
//    let products:String?
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
