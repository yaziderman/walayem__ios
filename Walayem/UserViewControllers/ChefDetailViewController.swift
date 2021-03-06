//
//  ChefDetailViewController.swift
//  Walayem
//
//  Created by MAC on 4/26/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log

enum FoodCategEnum: String{
    case appetizer
    case maincourse
    case dessert
}

class ChefDetailViewController: UIViewController, FoodCellDelegate {

    // MARK:Properties
    
    @IBOutlet weak var chefImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kitchenLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var foodTableViewHeightCnstrnt: NSLayoutConstraint!
    @IBOutlet weak var emptyView: UIView!
    
    var favouriteBarItem: UIBarButtonItem?
    
    let db = DatabaseHandler()
    var chef: Chef?
    var user: User?
    var filteredFoods = [Food]()
    var selectedCateg: Int = 0
    var foodCategs = [String]()
    var hasAppetizers: Bool = false
    var hasMainCourse: Bool = false
    var hasDesserts: Bool = false
    var hadOrdered: Bool = true
    
    var orderedFoods = [String]()
    // MARK: Actions
    
    @IBAction func addRating(_ sender: UITapGestureRecognizer) {
        guard let chefRatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ChefRatingVC") as? ChefRatingViewController else {
            fatalError("Unexpected View controller")
        }
        chefRatingVC.chef = chef
        chefRatingVC.foods = self.orderedFoods
        if(hadOrdered){
            present(chefRatingVC, animated: true, completion: nil)
        }else{
            showAlert(title: "", msg: "You can rate a chef only if you've ordered from them before.")
        }
        
        
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        favouriteBarItem = UIBarButtonItem(image: UIImage(named: "emptyFavourite"), style: .plain, target: self, action: #selector(addRemoveFavourite(_:)))
        navigationItem.setRightBarButton(favouriteBarItem, animated: false)
        
        chefImageView.layer.cornerRadius = 15
        chefImageView.layer.masksToBounds = true
        
        foodTableView.delegate = self
        foodTableView.dataSource = self
        foodTableViewHeightCnstrnt.constant = view.frame.height - 52 - navigationController!.navigationBar.frame.height - tabBarController!.tabBar.frame.height
        foodTableView.tableFooterView = UIView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        if let chef = chef{
            checkIsFavourite(chef.id)
            
            let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef.id)-\(chef.image!)/image_medium")
            chefImageView.kf.setImage(with: imageUrl)
            nameLabel.text = chef.name
            kitchenLabel.text = chef.kitchen
            descriptionLabel.text = chef.description
            
            var tagString: String = ""
            for tag in chef.foods[0].tags{
                tagString.append(tag.name)
                if let lastTag = chef.foods[0].tags.last, lastTag !== tag{
                    tagString.append(" \u{2022} ")
                }
            }
            tagsLabel.text = tagString
            initTabs(chef.foods)
            filterFoods(chef.foods)
            getChefRating(chef.id)
            Utils.setupNavigationBar(nav: self.navigationController!)
            loadPrevFoods()
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let indexPath = foodTableView.indexPathForSelectedRow else {
            os_log("No cell has been selected", log: .default, type: .debug)
            return
        }
        foodTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Private methods
    
    private func getChefRating(_ chefId: Int){
        let fields = ["average_rate"]
        let domain = [["chef_id", "=", chefId]]
        OdooClient.sharedInstance().searchRead(model: "walayem.totalchefrate", domain: domain, fields: fields, offset: 0, limit: 1, order: "") { (result, error) in
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                print(errmsg)
                return
            }
            let records = result!["records"] as! [Any]
            if records.count == 0{
                return
            }
            if let record = records[0] as? [String: Any]{
                let averageRate = record["average_rate"] as! Double
                self.ratingControl.rating = Int(averageRate)
            }
        }
        
    }
    
    private func loadPrevFoods(){
          let params = ["partner_id": user!.partner_id!, "chef_id": chef!.id]
        RestClient().request(WalayemApi.orderedFoods, params) { (result, error) in
            if error != nil{
                return
            }
            
            let value = result!["result"] as! [String: Any]
            self.hadOrdered = value["has_ordered"] as! Bool
            self.orderedFoods = value["foods"] as! [String]
            
            for food in self.orderedFoods{
                print("ordereed food-->\(food)")
            }
        }
    }
    
    @objc private func addRemoveFavourite(_ sender: UIBarButtonItem){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let params = ["partner_id": user!.partner_id!, "chef_id": chef!.id]
        if chef!.isFav{
            changeFavouriteBarItemIcon(isFav: false)
            RestClient().request(WalayemApi.removeFav, params) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    self.changeFavouriteBarItemIcon(isFav: self.chef!.isFav)
                    return
                }
                self.chef!.isFav = false
            }
        }else{
            changeFavouriteBarItemIcon(isFav: true)
            RestClient().request(WalayemApi.addFav, params) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    self.changeFavouriteBarItemIcon(isFav: self.chef!.isFav)
                    return
                }
                self.chef!.isFav = true
            }
        }
    }
    
    private func checkIsFavourite(_ chefId: Int){
        let params = ["partner_id": user!.partner_id!, "chef_id": chefId]
        
        RestClient().request(WalayemApi.checkFav, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let record = result!["result"] as! [String: Any]
            self.chef!.isFav = record["is_favorite"] as! Bool
            
            self.changeFavouriteBarItemIcon(isFav: self.chef!.isFav)
        }
    }
    
    private func changeFavouriteBarItemIcon(isFav: Bool){
        favouriteBarItem?.image = isFav ? UIImage(named: "favourite") : UIImage(named: "emptyFavourite")
    }
    
    private func initTabs(_ foods: [Food]){
        for food in foods {
            if(food.foodType == FoodCategEnum.appetizer.rawValue){
                hasAppetizers = true
            }else if(food.foodType == FoodCategEnum.maincourse.rawValue){
                hasMainCourse = true
            }else if(food.foodType == FoodCategEnum.dessert.rawValue){
                hasDesserts = true
            }
        }
        
        if(hasAppetizers){
             foodCategs.append("Appetizers")
        }
        if(hasMainCourse){
             foodCategs.append("Main course")
        }
        if(hasDesserts){
            foodCategs.append("Desserts")
        }
    }
    
    private func filterFoods(_ foods: [Food]){
        var filterString: String!
        switch selectedCateg{
        case 0:
            if (hasAppetizers){filterString = FoodCategEnum.appetizer.rawValue}
            else if(hasMainCourse) {filterString = FoodCategEnum.maincourse.rawValue}
            else { filterString = FoodCategEnum.dessert.rawValue}
        case 1:
            if(hasMainCourse){
                 filterString = FoodCategEnum.maincourse.rawValue
            }else{
              filterString = FoodCategEnum.dessert.rawValue
            }
        case 2:
            filterString = FoodCategEnum.dessert.rawValue
        default:
            filterString = ""
        }
        
        filteredFoods = foods.filter({ (food) -> Bool in
            return food.foodType == filterString
        })

        changeView(isEmpty: filteredFoods.count == 0)
        foodTableView.reloadSections([0], with: .automatic)
    }
    
    private func changeView(isEmpty: Bool){
        if isEmpty{
            foodTableView.backgroundView = emptyView
        }else{
            foodTableView.backgroundView = nil
        }
    }
    
    private func updateBadge(){
        if let tabItem = tabBarController?.tabBar.items?[2]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = db.getFoodsCount()
        }
    }
    
    // MARK: FoodCellDelegate
    
    func didTapAddItem(sender: FoodTableViewCell) {
        guard let indexPath = foodTableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = filteredFoods[indexPath.row]
        if db.addFoodDirectly(item: food) != -1 {
            print ("Quantity added")
            updateBadge()
        }
    }
    
    func didTapRemoveItem(sender: FoodTableViewCell) {
        guard let indexPath = foodTableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = filteredFoods[indexPath.row]
        if db.subtractFoodDirectly(foodId: food.id){
            print ("Quantity subtracted")
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

extension ChefDetailViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView{
            return
        }
        if !scrollView.bounds.intersects(nameLabel.frame){
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationItem.title = self.chef?.name
            })
        }else{
            UIView.animate(withDuration: 0.5) {
                self.navigationItem.title = ""
            }
        }
    }
    
}

extension ChefDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: indexPath) as? FoodTableViewCell else {
            fatalError("Unexpected cell")
        }
        cell.delegate = self
        let food = filteredFoods[indexPath.row]
        food.chefId = chef?.id
        food.chefName = chef?.name
        food.kitcherName = chef?.kitchen
        cell.food = food
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let food = filteredFoods[indexPath.row]
        
        let storyBoard = UIStoryboard(name: "Discover", bundle: nil)
        guard let foodDetailVC = storyBoard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else {
            fatalError("Unexpected viewController")
        }
        foodDetailVC.food = food
        navigationController?.pushViewController(foodDetailVC, animated: true)
    }
}

extension ChefDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCategCollectioViewCell", for: indexPath) as? FoodCategCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.titleLabel.text = foodCategs[indexPath.row]
        cell.iconImageView.tintColor = UIColor.perrywinkle
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
        filterFoods(chef!.foods)
    }
}
