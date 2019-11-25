//
//  FavChefTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/27/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class FavChefTableViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    
    var user: User?
    var chefs = [Chef]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favourite Chefs"
        user = User().getUserDefaults()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = user{
            getFavChefs(user.partner_id!)
        }
    }
    
    // MARK: Actions

    
    // MARK: Private methods
    
    private func getFavChefs(_ partnerId: Int){
        showActivityIndicator()
        let params = ["partner_id": partnerId]
        
        RestClient().request(WalayemApi.favChefs, params) { (result, error) in
            self.hideActivityIndicator()
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }
                return
            }
            self.chefs.removeAll()
            let data = result!["result"] as! [String: Any]
            if let status = data["status"] as? Int, status == 0{
                self.changeView(isEmpty: true)
                self.tableView.reloadData()
                return
            }
            let records = data["data"] as! [Any]
            for record in records{
                let chef = Chef(record: record as! [String : Any])
                self.chefs.append(chef)
            }
            self.tableView.reloadData()
        }
    }
    
    func showFoodDetailVC(food: Food){
        let storyBoard = UIStoryboard(name: "Discover", bundle: nil)
        guard let foodDetailVC = storyBoard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else {
            fatalError("Unexpected viewController")
        }
        foodDetailVC.food = food
        navigationController?.pushViewController(foodDetailVC, animated: true)
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
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "ChefDetailVCSegue":
            guard let chefViewController = segue.destination as? ChefDetailViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let selectedCell = sender as? ChefTableViewCell else {
                fatalError("Unexpected sender \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedChef = chefs[indexPath.row]
            chefViewController.chef = selectedChef
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    

}

extension FavChefTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefTableViewCell", for: indexPath) as? ChefTableViewCell else{
            fatalError("Unexpected tableViewCell")
        }
        let chef = chefs[indexPath.row]
        cell.chef = chef
        cell.favChefTableVC = self
        
        return cell
    }
    
}
