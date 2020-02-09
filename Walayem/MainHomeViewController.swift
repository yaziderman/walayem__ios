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
    
    var todays_meals = [PromotedItem]()
    var bestSellers = [PromotedItem]()
    var recommendedMeals = [PromotedItem]()
    var mealsURLs = [URL]()
    var recommendMealURLs = [URL]()
    
    
    var foods = [Food]()
    let bookmarks = ["Recommended", "Meals of the day", "Cuisines", "Best Chefs"]
    var bookmarkImages: [UIImage] = [
         UIImage(named: "bookmark.jpg")!,
         UIImage(named: "fire.jpg")!,
         UIImage(named: "bookmark.jpg")!,
         UIImage(named: "bookmark.jpeg")!,
         UIImage(named: "bookmark.jpg")!
     ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getRecommendations()
        
       
    }
    
    
    
    private func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshData(sender: UIRefreshControl){
        
        getRecommendations()
        tableView.reloadData()
    }
    
    private func getRecommendations(){
            let params : [String: Any] = ["partner_id": partnerId ?? 0]
            
            RestClient().requestPromotedApi(WalayemApi.homeRecommendation, params) { (result, error) in
                self.tableView.refreshControl?.endRefreshing()
                
                let data = result!["result"] as! [String: Any]
                let status_api = data["status"] as? Int
                
                if let error = error{
                    self.handleNetworkError(error)
                    return
                }
                else if let status = status_api, status == 0{
                    print("STatus Value------------->\(status)")
                    return
                }else{
                    if let best_sellers = data["best_sellers"] as? [Any]{
                        for best_seller in best_sellers{
                            let best_seller = PromotedItem(records: best_seller as! [String : Any])
                            self.bestSellers.append(best_seller)
                        }
                    }
                    if let recommendedMeals = data["recommended"] as? [Any]{
                        for recommended in recommendedMeals{
                            let recommend = PromotedItem(records: recommended as! [String : Any])
                            self.recommendedMeals.append(recommend)
                            
                            let id = recommend.item_details?.id
                            let url = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id ?? 0)/image")
                            self.recommendMealURLs.append(url!)
                            
                        }
                    }
                    if let todaysMeals = data["todays_meals"] as? [Any]{
                        for meal in todaysMeals {
                            let todays_meal = PromotedItem(records: meal as! [String : Any])
                            self.todays_meals.append(todays_meal)
                            let id = todays_meal.item_details?.id
                            let url = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id ?? 0)/image")
                            self.mealsURLs.append(url!)
                        }
                    }
                }
                
                self.tableView.reloadData()
                
                
                if let advertisment_image = data["advertisment_image"] as? Int, advertisment_image == 0{
                    print(advertisment_image)
                    print("no image available")
                }
    
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
            collectionViewCellIdentifier = "recommendedCell0"
        }
        if indexPath.row == 1 {
            collectionViewCellIdentifier = "mealDayCell1"
        }
        if indexPath.row == 2 {
            collectionViewCellIdentifier = "cuisinesCell4"
        }
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell") as? HomeTableViewCell  else { fatalError("mainHomeTableViewCell") }
            
            cell.identifier = collectionViewCellIdentifier;
            cell.bookmarkText.text = self.bookmarks[indexPath.row]
            cell.bookmarkImage.image = self.bookmarkImages[indexPath.row]
            
            cell.recommendedMeals = self.recommendedMeals
            cell.recommendedImagesURLS = self.recommendMealURLs
            cell.todays_meals = self.todays_meals
            cell.mealImagesURLS = self.mealsURLs
            cell.bestSellers = self.bestSellers
            
            
            cell.collectionView.reloadData()
            cell.selectionStyle = .none
            
            return cell
        }
        
        
        
        else if indexPath.row == 3 {
            guard let cell : HomeButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell1") as? HomeButtonTableViewCell else { fatalError("mainHomeTableViewCell1") }
            
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
        
        
    }
}
