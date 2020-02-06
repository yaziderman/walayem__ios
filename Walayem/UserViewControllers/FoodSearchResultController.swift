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
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    let db = DatabaseHandler()
    var foods = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: Private methods
    
    private func updateBadge(){
        if let tabItem = tabBarController?.tabBar.items?[3]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = db.getFoodsCount()
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
        }
    }
    
    func didTapRemoveItem(sender: FoodTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = foods[indexPath.row]
        if db.subtractFoodDirectly(foodId: food.id){
            print ("Qunatity subtracted")
            updateBadge()
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

extension FoodSearchResultController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: indexPath) as? FoodTableViewCell else {
            fatalError("Unexpected cell")
        }
        cell.delegate = self
        let food = foods[indexPath.row]
        cell.food = food
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
            fatalError("Unexpected destination VC")
        }
        let food = foods[indexPath.row]
        destinationVC.food = food
        self.presentingViewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

extension FoodSearchResultController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        let sb = searchController.searchBar
        let searchQuery = sb.text!
        
        let params: [String: Any] = ["search": true, "search_keyword": searchQuery]
        RestClient().request(WalayemApi.searchFood, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.foods.removeAll()
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
                self.foods.append(food)
            }
            self.tableView.reloadData()
        }
    }
    
}
