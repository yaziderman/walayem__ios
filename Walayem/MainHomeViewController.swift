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
//    let tableCell = HomeTableViewCell()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
//        getRecommendations()
        
        print(recommendedFoods)
       
    }
    
    private func getRecommendations(){
        let params : [String: Any] = ["partner_id": partnerId ?? 0]
        
        RestClient().request(WalayemApi.recommendation, params) { (result, error) in
//            self.hideActivityIndicator()
            self.tableView.refreshControl?.endRefreshing()
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            let data = result!["result"] as! [String: Any]
            if let status = data["status"] as? Int, status == 0{
                return
            }
            self.recommendedFoods.removeAll()
            let records = data["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String : Any])
                self.recommendedFoods.append(food)
                print(food.chefName as Any)
                self.tableView.reloadData()
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
            cell.selectionStyle = .none
            cell.foods = foods
            
            return cell
        }
        
        
        
        else if indexPath.row == 3 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell1") else { fatalError("mainHomeTableViewCell1") }
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
        return 132
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
    }
}
