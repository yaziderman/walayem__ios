//
//  HomeViewController.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/1/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController{
    
    
    // MARK: Properties
    let usertab = UserTabBarController()
    var partnerId: Int?
//    let db = DatabaseHandler()
    var selectedCuisines = [Cuisine]()
    var recommendedFoods = [Food]()
    var mealsofDayFoods = [Food]()
//    weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mealsDayCollectionView: UICollectionView!
    
    let markTexts = ["Recommended", "Meals of the day", "Cuisines"]
//    var images = [#imageLiteral(resourceName: "placeholder.pdf"),#imageLiteral(resourceName: "placeholder.pdf"),#imageLiteral(resourceName: "placeholder.pdf"),#imageLiteral(resourceName: "placeholder.pdf")]
//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
//        mealsDayCollectionView.delegate = self
//        mealsDayCollectionView.dataSource = self

        getRecommendations()
        getMealsOfDay()
        
    }
    @IBAction func browseAllMealsButtonPressed(_ sender: Any) {
        
//        UserTabBarController.init().selectedIndex = 2
        
        
        
//
//
//        guard let orderVC = UIStoryboard.init(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else {
//            fatalError("ProfileTableViewController")
//        }
//
//            let navigationVC = UINavigationController(rootViewController: orderVC)
//            navigationVC.showDetailViewController(navigationVC, sender: self)
        
        
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
    
    private func showActivityIndicator(){
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.color = UIColor.colorPrimary
        activityIndicator.hidesWhenStopped = true
        
//        tableView.tableHeaderView?.frame.size.height = 0
//        tableView.backgroundView = activityIndicator
//        tableView.separatorStyle = .none
        
        activityIndicator.startAnimating()
//        self.activityIndicator = activityIndicator
    }
    
    private func hideActivityIndicator(){
//        self.activityIndicator?.stopAnimating()
//        tableView.tableHeaderView?.frame.size.height = 390
//        self.tableView.separatorStyle = .singleLine
    }
    
    
        
        
    private func getMealsOfDay(){
        let params : [String: Any] = ["partner_id": partnerId ?? 0]

        RestClient().request(WalayemApi.mealsOfDay, params) { (result, error) in
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            let data = result!["result"] as! [String: Any]
            if let status = data["status"] as? Int, status == 0{
                return
            }
            self.mealsofDayFoods.removeAll()
            let records = data["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String : Any])
                self.mealsofDayFoods.append(food)
            }
//            self.mealsDayCollectionView.reloadData()
        }
    }
    
    private func getRecommendations(){
        let params : [String: Any] = ["partner_id": partnerId ?? 0]

        RestClient().request(WalayemApi.recommendation, params) { (result, error) in

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
            }
            
//            self.collectionView.reloadData()
        }
        
    }


}
//
//
//
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == self.collectionView{
            return recommendedFoods.count
//        }
//        else{
//            return mealsofDayFoods.count
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.collectionView{
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCVCellForHome", for: indexPath) as? RecommendedHomeCVCell else {
            fatalError("Unexpected CollectionViewCell")
        }

            let food = recommendedFoods[indexPath.row]
            cell.food = food
            cell.bottomView.roundCorners([.bottomLeft, .bottomRight], radius: 15)
            return cell
        }
        else {
            guard let cell = mealsDayCollectionView.dequeueReusableCell(withReuseIdentifier: "MealOfDayCollectionViewCell", for: indexPath) as? MealOfDayCollectionViewCell else {
                       fatalError("Unexpected CollectionViewCell")
                   }

                let food = mealsofDayFoods[indexPath.row]
                cell.food = food
                return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
//            fatalError("Unexpected destination VC")
//        }
//        let food = recommendedFoods[indexPath.row]
//        destinationVC.food = food
//        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRecommendedCell") as? HomeRecommendedCell
            else { fatalError("Unexpected CollectionViewCell") }

        return cell
    }




}
