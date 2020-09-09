//
//  FoodSearchResultController.swift
//  Walayem
//
//  Created by MAC on 5/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class FoodSearchResultController: UIViewController, FoodCellDelegate {
	
	// MARK: Properties
	
	@IBOutlet weak var tableView: UITableView!
	
	let db = DatabaseHandler()
	var foods = [Food]()
	private var page: Int = 1
	private var totalPages: Int = 0
	fileprivate var searchKeyword: String?
	
	@IBOutlet weak var emptyView: UIView!
	var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self as! UITableViewDelegate
		tableView.dataSource = self as! UITableViewDataSource
	}
	
	// MARK: Private methods
	
	private func updateBadge(){
		if let tabItem = tabBarController?.tabBar.items?[3]{
			tabItem.badgeColor = UIColor.colorPrimary
			tabItem.badgeValue = db.getFoodsCount()
		}
	}
	
    private func searchFood(isAddress: Bool) {
//		var params = AreaFilter.shared.coverageParams
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
		
		RestClient().request(WalayemApi.searchFood, params, self) { (result, error) in
			self.foods.removeAll()
			if error != nil{
				let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
				print (errmsg)
				self.tableView.reloadData()
				return
			}
			let value = result!["result"] as! [String: Any]
			if let status = value["status"] as? Int, status == 0{
				self.tableView.reloadData()
				return
			}
			
			self.page = value["current_page"] as? Int ?? 0
			self.totalPages = value["total_pages"] as? Int ?? 0
			let records = value["data"] as! [Any]
			for record in records{
				let food = Food(record: record as! [String: Any], isWebsiteActive: false)
				self.foods.append(food)
			}
			self.tableView.reloadData()
		}
	}
	
    private func searchMoreFood(isAddress: Bool) {
//		var params = AreaFilter.shared.coverageParams
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
//		params["filter_by"] = "area"//"location"
		
		RestClient().request(WalayemApi.searchFood, params, self) { (result, error) in
			self.tableView.tableFooterView = nil
			if error != nil{
				let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
				print (errmsg)
				self.tableView.reloadData()
				return
			}
			let value = result!["result"] as! [String: Any]
			if let status = value["status"] as? Int, status == 0{
				self.tableView.reloadData()
				return
			}
			self.page = value["current_page"] as? Int ?? 0
			self.totalPages = value["total_pages"] as? Int ?? 0
			let records = value["data"] as! [Any]
			for record in records{
				let food = Food(record: record as! [String: Any], isWebsiteActive: false)
				if !self.foods.contains(food) {
					self.foods.append(food)
				}
			}
			self.tableView.reloadData()
		}
	}
	
	// MARK: FoodCellDelegate
	
	func didTapAddItem(sender: FoodTableViewCell) {
		guard let indexPath = tableView.indexPath(for: sender) else {
			fatalError("Cell does not exist")
		}
		let food = foods[indexPath.row]
		if db.addFoodDirectly(item: food) != -1 {
			print ("Qunatity added")
			updateBadge()
			tableView.reloadRows(at: [indexPath], with: .none)
		}
	}
	
	func didTapRemoveItem(sender: FoodTableViewCell) {
		guard let indexPath = tableView.indexPath(for: sender) else {
			fatalError("Cell does not exist")
		}
		let food = foods[indexPath.row]
		if db.subtractFoodDirectly(foodId: food.id ?? 0){
			print ("Qunatity subtracted")
			updateBadge()
			tableView.reloadRows(at: [indexPath], with: .none)
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	super.prepare(for: segue, sender: sender)
	
	switch segue.identifier ?? ""{
	case "FoodDetailSegue":
	guard let destinationVC = segue.destination as? FoodDetailViewController else {
	fatalError("Unexpected destination \(segue.destination)")
	}
	guard let selectedCell = sender as? FoodTableViewCell else{
	fatalError("Unexpected sender \(sender)")
	}
	guard let indexPath = tableView.indexPath(for: selectedCell) else {
	fatalError("Cell does not exist")
	}
	let food = foods[indexPath.row]
	destinationVC.food = food
	default:
	fatalError("Invalid segue")
	}
	}
	*/
	
}

extension FoodSearchResultController : UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.foods.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: indexPath) as? FoodTableViewCell else {
			fatalError("Unexpected cell")
		}
		cell.delegate = self
		let food = self.foods[indexPath.row]
		cell.food = food
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
			fatalError("Unexpected destination VC")
		}
		let food = self.foods[indexPath.row]
		destinationVC.food = food
		destinationVC.is_website_link_active = food.is_website_link_active
		self.presentingViewController?.navigationController?.pushViewController(destinationVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == self.foods.count - 1 && page < totalPages {
			searchMoreFood(isAddress: AreaFilter.shared.isAddress)
			let activityIndicator = UIActivityIndicatorView(style: .gray)
			activityIndicator.color = UIColor.colorPrimary
			activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
			activityIndicator.startAnimating()
			tableView.tableFooterView = activityIndicator
		}
	}
}

extension FoodSearchResultController: UISearchResultsUpdating{
	
	func updateSearchResults(for searchController: UISearchController) {
		let sb = searchController.searchBar
		let trimmedString = sb.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.searchKeyword = trimmedString
		if trimmedString.count >= 1 {
			self.tableView.scroll(to: .top, animated: false)
			self.searchFood(isAddress: AreaFilter.shared.isAddress)
			let searchQuery = sb.text!
			let trimmedString = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
			
			
			var doSearch = false
			
			if searchQuery.count >= 1 {
				doSearch = true
			}
			
			if doSearch{
				var params: [String: Any] = AreaFilter.shared.coverageParams
				
				params["search"] =  true
				params["search_keyword"] = trimmedString
				params["filter_by"] = "location"
				
				RestClient().request(WalayemApi.searchFood, params, self) { (result, error) in
					self.foods.removeAll()
					if error != nil{
						let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
						print (errmsg)
						self.tableView.reloadData()
						return
					}
					let value = result!["result"] as! [String: Any]
					if let status = value["status"] as? Int, status == 0{
						self.tableView.reloadData()
						return
					}
					
					let records = value["data"] as! [Any]
					for record in records{
						let food = Food(record: record as! [String: Any], isWebsiteActive: false)
						self.foods.append(food)
					}
					self.tableView.reloadData()
				}
			}
		}
	}
	
}
