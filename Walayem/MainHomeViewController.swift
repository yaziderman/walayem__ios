//
//  MainHomeViewController.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/3/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit



class MainHomeViewController: UIViewController {
    
    var partnerId: Int?
    var recommendedFoods = [Food]()
    var foods = [Food]()
    let bookmarks = ["Recommended", "Meals of the day", "Cuisines", "Best Chefs"]
    var bookmarkImages: [UIImage] = [
        UIImage(named: "bookmark.jpg")!,
        UIImage(named: "fire.jpg")!,
        UIImage(named: "bookmark.jpg")!,
        UIImage(named: "fire2.jpeg")!,
        UIImage(named: "bookmark.jpg")!,
        UIImage(named: "fire.jpg")!
    ]
    
    
//    let tableCell = HomeTableViewCell()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getRecommendations()
        
        print(recommendedFoods)
       
    }
    
    private func getRecommendations(){
        let params : [String: Any] = ["partner_id": partnerId ?? 0]
        
        RestClient().requestPromotedApi(WalayemApi.homeRecommendation, params) { (result, error) in
            self.tableView.refreshControl?.endRefreshing()
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            
           
            
//            let data = result!["result"] as! [String: Any]
//            let status_api = data["status"]
//
//            if let status = status_api as? Int, status == 0{
////                return
//                print(status)
//            }
//            if let advertisment_image = data["advertisment_image"] as? Int, advertisment_image == 0{
//                print(advertisment_image)
//                print("no image available")
//            }
//
//
//            self.recommendedFoods.removeAll()
//
//            for best_seller in data["best_sellers"] as! [Any]{
//                print(best_seller)
//            }
//            for todays_meal in data["todays_meals"] as! [Any]{
//                print(todays_meal)
////                do{
////                    let tMeals = try JSONDecoder().decode(TodaysMeal.self, from: todays_meal as! Data)
////                    print(tMeals.end_date)
////                }catch let err {
////                   print(err)
////                }
//            }
//            for recommended in data["recommended"] as! [Any] {
//                print(recommended)
//
////                let food = Food(recommended)
////                self.recommendedFoods.append(rFood)
//            }
//
//            print(self.recommendedFoods)
//
////            let records = data["data"] as! [Any]
//            for record in records{
//                let food = Food(record: record as! [String : Any])
//                self.recommendedFoods.append(food)
//                print(food.chefName as Any)
//                self.tableView.reloadData()
//            }
        }
    }
    
    private func handleNetworkError(_ error: NSError){
           let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
           if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
               let alert = UIAlertController(title: "Cannot get Foods", message: errmsg, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
               present(alert, animated: true, completion: nil)
           }else if errmsg == OdooClient.SESSION_EXPIRED{
               self.onSessionExpired()
           }
       }
}

extension MainHomeViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var collectionViewCellIdentifier = "cell1"
        
        if indexPath.row == 0 {
            collectionViewCellIdentifier = "cell0"
        }
        if indexPath.row == 1 {
            collectionViewCellIdentifier = "cell1"
        }
        if indexPath.row == 2 {
            collectionViewCellIdentifier = "cell4"
        }
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell") as? HomeTableViewCell  else { fatalError("mainHomeTableViewCell") }
            cell.identifier = collectionViewCellIdentifier;
            cell.bookmarkText.text = self.bookmarks[indexPath.row]
            cell.bookmarkImage.image = self.bookmarkImages[indexPath.row]
            cell.selectionStyle = .none
            cell.foods = foods
            
            return cell
        }
        
        
        
        else if indexPath.row == 3 {
            guard let cell : HomeButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell1") as! HomeButtonTableViewCell else { fatalError("mainHomeTableViewCell1") }
            
            cell.parent = self
            cell.selectionStyle = .none
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCellLast") else { fatalError("mainHomeTableViewCellLast")  }
            cell.selectionStyle = .none
            
            
            return cell
        }
        
    }
    
    @objc func browseMealsTapped(sender: UIButton){
        print("browse meals tapped!")
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 310
        }
        if indexPath.row == 1 {
            return 200
        }
        if indexPath.row == 2 {
            return 180
            
        }
        if indexPath.row == 3 {
            return 90
        }
        return 98
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
//struct promoted: Decodable{
//    
//    let id: Int?
//    let result: [result]?
//    let jsonrpc: String?
//}
//
//struct result: Decodable{
//    let status: Bool?
//    let best_sellers: [best_seller]?
//    let recommended: [recommended]?
//    let todays_meals: [TodaysMeal]?
//    let advertisment_image: String?
//}
//
//struct best_seller: Decodable{
//    let kitchen_name: String
//    let end_date: String
//    let id: Int
//    let item_id: [Int: String]
//    let start_date: String
//    let item_details: [bestSellerItemDetails]
//}
//
//struct bestSellerItemDetails: Decodable{
//    let image_hash: String
//    let comment: String
//    let name: String
//    let id: Int
//    let kitchen_id: [Int: String]
//    let products: String?
//    let favorite_products: [Int]?
//}
//
//struct recommended: Decodable{
//    let end_date: String?
//    let cuisine: String?
//    let id: Int?
//    let item_id: [Int: String]?
//    let start_date: String?
//    let item_details : [recommendedItemDetail]?
//}
//
//struct recommendedItemDetail: Decodable{
//    let name: String
//    let preparation_time: String
//    let id: Int
//    let cuisine_id: [Int: String]?
//    let food_image_ids: [Int]
//    let serves: Int
//    let list_price: Int
//    let food_type: String
//    let description_sale: String
//    let food_tags: [Int]
//}
//
//struct TodaysMeal: Decodable{
//    let id: Int
//    let end_date: String
//    let start_date: String
//    let item_details: MealItemDetail
//    let item_id: [String]
//    let kitchen_name: String
//}
//
//struct MealItemDetail: Decodable{
//    let comment:Int
//    let favorite_products: [String]
//    let id:Int
//    let image_hash:Int
//    let kitchen_id: [String]
//    let name:String
//    let products:String
//}
