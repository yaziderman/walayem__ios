//
//  ChefFoodTableViewController.swift
//  Walayem
//
//  Created by MAC on 5/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefFoodTableViewController: UIViewController {

    // MARK: Properties
    
    static let FOOD_REMOVE: Int = 1
    static let FOOD_PAUSE: Int = 2
    static let FOOD_RESUME: Int = 3
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    let foodCategs = ["Appetizers", "Main course", "Desserts"]
    var selectedCateg: Int = 0
    var user: User?
    var foods = [Food]()

    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        setupRefreshControl()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        Utils.setupNavigationBar(nav: self.navigationController!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFoods()
        
        if(Utils.SHOW_NEWDISH)
        {
            Utils.SHOW_NEWDISH = false
            self.performSegue(withIdentifier: "showNewDish", sender: self)
        }
    }
    
    // MARK: Private methods
    
    private func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshData(sender: UIRefreshControl){
        getFoods()
    }
    
    private func getFoods(){
        showActivityIndicator()
        
        var filterString: String!
        switch selectedCateg{
        case 0:
            filterString = FoodCategEnum.appetizer.rawValue
        case 1:
            filterString = FoodCategEnum.maincourse.rawValue
        case 2:
            filterString = FoodCategEnum.dessert.rawValue
        default:
            filterString = ""
        }
        
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "food_type": filterString]
        RestClient().request(WalayemApi.chefFood, params) { (result, error) in
            self.hideActivityIndicator()
            self.tableView.refreshControl?.endRefreshing()
            
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }else{
                    self.showAlert(title: "Cannot get meals", msg: errmsg)
                }
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.foods.removeAll()
            let records = value["data"] as! [Any]
            if records.count == 0{
                self.changeView(isEmpty: true)
                self.tableView.reloadData()
                return
            }
            self.changeView(isEmpty: false)
            for record in records{
                let food = Food(record: record as! [String: Any])
                self.foods.append(food)
            }
            self.tableView.reloadData()
        }
    
    }

    private func pauseRemoveFood(foodId: Int, action: Int){
        let params: [String: Int] = ["partner_id": user!.partner_id!, "product_id": foodId, "action": action]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        RestClient().request(WalayemApi.pauseRemoveFood, params) { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
        }
    }
    
    private func changeView(isEmpty: Bool){
        if isEmpty{
            tableView.backgroundView = emptyView
        }else{
            tableView.backgroundView = nil
        }
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
        tableView.backgroundView = nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ChefFoodVCSegue":
            guard let destinationVC = segue.destination as? ChefFoodViewController else{
                fatalError("Unexpected destination \(segue.identifier)")
            }
            guard let selectedCell = sender as? ChefFoodCell else {
                fatalError("Unexpected sender \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("Cell does not exist")
            }
            let selectedFood = foods[indexPath.row]
            destinationVC.food = selectedFood
            
        default:
            print ("Add meal segue")
        }
    }

}

extension ChefFoodTableViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCategCell", for: indexPath) as? FoodCategCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.titleLabel.text = foodCategs[indexPath.row]
        cell.iconImageView.image = UIImage(named: "discover")?.withRenderingMode(.alwaysTemplate)
        cell.iconImageView.tintColor = UIColor.colorPrimary
        if indexPath.row == selectedCateg{
            cell.titleLabel.textColor = UIColor.steel
            cell.iconImageView.isHidden = false
        }else{
            cell.titleLabel.textColor = UIColor.silverTen
            cell.iconImageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCateg = indexPath.row
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        
        foods.removeAll()
        self.tableView.reloadData()
        getFoods()
    }
    
}

extension ChefFoodTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefFoodCell", for: indexPath) as? ChefFoodCell else {
            fatalError("Unexpected cell")
        }
        let food = foods[indexPath.row]
        cell.food = food
        
        return cell
    }
    
   
        
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let food = self.foods[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .normal, title: "       ") { (delete, indexPath) in
            self.pauseRemoveFood(foodId: food.id, action: ChefFoodTableViewController.FOOD_REMOVE)
            self.foods.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    

        let img: UIImage = UIImage(named: "trashIcon")!
//        img = img.imageWithInsets(insets: UIEdgeInsetsMake(30, 30, 30, 30))!
        var imgSize: CGSize = tableView.frame.size
        UIGraphicsBeginImageContext(imgSize)
        let rect = CGRect(x: -15, y: 0, width: 110, height: 110)
        img.draw(in: rect)
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        deleteAction.backgroundColor = UIColor(patternImage: newImage)
        
        
        
//        deleteAction.backgroundColor = UIColor(red: 1.0, green: 107.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
        
        let pauseAction = UITableViewRowAction(style: .normal, title: "") { (pause, indexPath) in
            if food.paused{
                self.pauseRemoveFood(foodId: food.id, action: ChefFoodTableViewController.FOOD_RESUME)
                food.paused = false
            }else {
                self.pauseRemoveFood(foodId: food.id, action: ChefFoodTableViewController.FOOD_PAUSE)
                food.paused = true
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        let pauseimg: UIImage = food.paused ? UIImage(named: "playIcon")! : UIImage(named: "pauseIcon")!
        //        img = img.imageWithInsets(insets: UIEdgeInsetsMake(30, 30, 30, 30))!
        var pauseimgSize: CGSize = tableView.frame.size
        UIGraphicsBeginImageContext(pauseimgSize)
        let pauserect = CGRect(x: -15, y: 0, width: 110, height: 110)
        pauseimg.draw(in: pauserect)
        var pausenewImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        pauseAction.backgroundColor = UIColor(patternImage: pausenewImage)
        
//        pauseAction.title = food.paused ? "Resume" : "Pause"
//        pauseAction.backgroundColor = UIColor(red: 1.0, green: 163.0 / 255.0, blue: 118.0 / 255.0, alpha: 1.0)
        
        return [deleteAction, pauseAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
}
}
