//
//  ChefSearchResultsViewController.swift
//  Walayem
//
//  Created by D4ttatraya on 20/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class ChefSearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChefCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var chefs = [Chef]()
    private var page: Int = 1
    private var totalPages: Int = 0
    fileprivate var searchKeyword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func searchChefs(isAddress: Bool) {
//        var params = AreaFilter.shared.coverageParams
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["search"] = true
        params["search_keyword"] = self.searchKeyword
        params["page"] = 1
//		params["filter_by"] = "area"//"location"
		
        RestClient().request(WalayemApi.searchChef, params, self) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                return
            }
            self.chefs.removeAll()
            self.page = value["current_page"] as? Int ?? 0
            self.totalPages = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
				let chef = Chef(record: record as! [String: Any], name: "")
                self.chefs.append(chef)
            }
            self.tableView.reloadData()
        }
    }
    
    private func searchMoreChefs(isAddress: Bool) {
//        var params = AreaFilter.shared.coverageParams
//        params["search"] = true
//        params["search_keyword"] = self.searchKeyword
//        params["page"] = self.page + 1
//		params["filter_by"] = "location"
        
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["search"] = true
        params["search_keyword"] = self.searchKeyword
        params["page"] = self.page + 1
//        params["filter_by"] = "area"//"location"
		
        RestClient().request(WalayemApi.searchChef, params, self) { (result, error) in
            self.tableView.tableFooterView = nil
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                return
            }
            self.page = value["current_page"] as? Int ?? 0
            self.totalPages = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
				let chef = Chef(record: record as! [String: Any], name: "")
                if !self.chefs.contains(chef){
                    self.chefs.append(chef)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chefs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefTableViewCell", for: indexPath) as? ChefTableViewCell else{
            fatalError("Unexpected tableViewCell")
        }
        let chef = chefs[indexPath.row]
        cell.chef = chef
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chefDetailsVC = storyboard!.instantiateViewController(withIdentifier: "ChefDetailVCId") as! ChefDetailViewController
        let selectedChef = chefs[indexPath.row]
        chefDetailsVC.chef = selectedChef
        self.presentingViewController?.navigationController?.pushViewController(chefDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == chefs.count - 1 && page < totalPages {
            searchMoreChefs(isAddress: AreaFilter.shared.isAddress)
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            activityIndicator.startAnimating()
            tableView.tableFooterView = activityIndicator
        }
    }
    
    func foodSelected(_ food: Food) {
        let storyBoard = UIStoryboard(name: "Discover", bundle: nil)
        guard let foodDetailVC = storyBoard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else {
            fatalError("Unexpected viewController")
        }
        foodDetailVC.food = food
		foodDetailVC.is_website_link_active = food.is_website_link_active
        self.presentingViewController?.navigationController?.pushViewController(foodDetailVC, animated: true)
    }
}

extension ChefSearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let sb = searchController.searchBar
        let trimmedString = sb.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.searchKeyword = trimmedString
        if trimmedString.count >= 1 {
            self.tableView.scroll(to: .top, animated: false)
            self.searchChefs(isAddress: AreaFilter.shared.isAddress)
        }
    }
}
