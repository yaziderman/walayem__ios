//
//  FavFoodTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class FavFoodTableViewController: UIViewController, FoodCellDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    let db = DatabaseHandler()
    var user: User?
    var foods = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setupNavigationBar(nav: self.navigationController!)
        navigationItem.title = "Favourites"
        user = User().getUserDefaults()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = user{
            getFavFoods(user.partner_id!)
        }
    }
    
    // MARK: Private methods
    
    private func getFavFoods(_ partnerId: Int){
        showActivityIndicator()
        let params = ["partner_id": partnerId]
        
        RestClient().request(WalayemApi.favFoods, params) { (result, error) in
            self.hideActivityIndicator()
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }
                return
            }
            self.foods.removeAll()
            let data = result!["result"] as! [String: Any]
            if let status = data["status"] as? Int, status == 0{
                self.changeView(isEmpty: true)
                self.tableView.reloadData()
                return
            }
            let records = data["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String : Any])
                self.foods.append(food)
            }
            self.tableView.reloadData()
        }
    }
    
    private func changeView(isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
        }else{
            tableView.backgroundView = nil
        }
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }
    
    private func updateBadge(){
        if let tabItem = tabBarController?.tabBar.items?[3]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = db.getFoodsCount()
        }
    }

    // MARK: - Table view data source

    

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
        if db.subtractFoodDirectly(foodId: food.id ?? 0){
            print ("Qunatity subtracted")
            updateBadge()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FavFoodTableViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}
