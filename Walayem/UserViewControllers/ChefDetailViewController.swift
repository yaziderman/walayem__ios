//
//  ChefDetailViewController.swift
//  Walayem
//
//  Created by MAC on 4/26/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log
import SDWebImage

enum FoodCategEnum: String{
    case appetizer
    case maincourse
    case dessert
    case drink
	case other
}

class ChefDetailViewController: UIViewController, FoodCellDelegate {

    // MARK:Properties
    
    @IBOutlet weak var chefDescTitleStack: UIStackView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var desc: UILabel!
    
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
	@IBOutlet weak var locatonLabel: UILabel!
    @IBOutlet weak var shareChefIV: UIImageView!
    
    var isChefDescAvailable = true
    
    
    var favouriteBarItem: UIBarButtonItem?
    
    let db = DatabaseHandler()
    var chef: Chef?
    var chef_id: Int?
    var metaLocation = ""
    var chef_website = ""
    var user: User?
    var filteredFoods = [Food]()
    var selectedCateg: Int = 0
    var foodCategs = [String]()
    var hasfoodCategs = [String]()
    var hasAppetizers: Bool = false
    var hasMainCourse: Bool = false
    var hasDesserts: Bool = false
    var hasDrinks: Bool = false
	var hasOthers: Bool = false
    var hasAppetizersAlreadyChecked: Bool = false
    var hasMainCourseAlreadyChecked: Bool = false
    var hasDessertsAlreadyChecked: Bool = false
    var hasDrinksAlreadyChecked: Bool = false
    var hadOrdered: Bool = true
    var orderedFoods = [String]()
    // MARK: Actions
    
//    @IBAction func addRating(_ sender: UITapGestureRecognizer) {
//        guard let chefRatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ChefRatingVC") as? ChefRatingViewController else {
//            fatalError("Unexpected View controller")
//        }
//        chefRatingVC.chef = chef
//        chefRatingVC.foods = self.orderedFoods
//        if(hadOrdered){
//            present(chefRatingVC, animated: true, completion: nil)
//        }else{
//            showAlert(title: "", msg: "You can rate a chef only if you've ordered from them before.")
//        }
//	}
        
	var session: String?
    
    var spinnerView = UIView()
    
    func showSpinner(){
        spinnerView = getSpinnerView()
        self.view.addSubview(spinnerView)
    }
    
    func hideSpinner(){
        spinnerView.removeFromSuperview()
    }
    
    // MARK: Actions
    
    @IBAction func addRating(_ sender: UITapGestureRecognizer) {
        
        session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        if(session == nil)
        {
          // PresentLoginScreen(showSkip: true)
            print("not logged IN")
        }else{
            guard let chefRatingVC = self.storyboard?.instantiateViewController(withIdentifier: "ChefRatingVC") as? ChefRatingViewController else {
                fatalError("Unexpected View controller")
            }
            chefRatingVC.chef = chef
			chefRatingVC.chefRatingDelegate = self
            chefRatingVC.foods = self.orderedFoods
            if(hadOrdered){
                present(chefRatingVC, animated: true, completion: nil)
            }else{
                showAlert(title: "", msg: "You can rate a chef only if you've ordered from them before.")
            }
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
        if (chef_id != nil){
            // Call API to get chefById
            getChef()
        }else{
            initVC()
        }

        
    }
    
    func initVC(){
        
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
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
        
        if let chef = chef{
            checkIsFavourite(chef.id)
            
            let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/api/chefImage/\(chef.id)-\(chef.image)/image_medium")
//            chefImageView.kf.setImage(with: imageUrl)
            chefImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            chefImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "foodImageEmpty"))
            nameLabel.text = chef.name
            kitchenLabel.text = chef.kitchen
            descriptionLabel.text = chef.description
            
            let ar_name = chef.area?.name
            let em_name = chef.area?.emirate?.name
            
            if ar_name != nil {
                if em_name != nil {
                    locatonLabel.isHidden = false
                    locatonLabel.text = em_name
                } else {
                    locatonLabel.isHidden = false
                    locatonLabel.text = ar_name
                }
            } else {
                locatonLabel.isHidden = true
            }
			
//			locatonLabel.text = chef.
            
            print(" \(chef.description) -< this is chef.description")
            
            if chef.description == ""{
                isChefDescAvailable = false
                self.descriptionLabel.isHidden = true
                self.desc.isHidden = true
                self.img.isHidden = true
			} else {
				isChefDescAvailable = true
				self.descriptionLabel.isHidden = false
				self.desc.isHidden = false
				self.img.isHidden = false
			}
            
            var tagString: String = ""
			for tag in (chef.foods.first?.tags ?? [Tag]()) {
                tagString.append(tag.name ?? "")
				if let lastTag = chef.foods.first?.tags.last, lastTag !== tag{
                    tagString.append(" \u{2022} ")
                }
            }
            tagsLabel.text = tagString
            getChefRating(chef.id)
            Utils.setupNavigationBar(nav: self.navigationController!)
            loadPrevFoods()
            initTabs(chef.foods)
			if((self.chef?.is_weblink_active ?? false) && self.chef?.website != ""){
				shareChefIV.isHidden = false
			}else{
				shareChefIV.isHidden = true
			}
            filterFoods(chef.foods)
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(updateFav) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
        
        updateFav()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapShareChef))
        
        shareChefIV.addGestureRecognizer(tap)
        shareChefIV.isUserInteractionEnabled = true
        
//        if(self.chef?.website == ""  || ((self.chef?.website.elementsEqual("")) != nil)){
//            shareChefIV.isHidden = true
//        }

    }

    @objc func updateFav()
    {
        
        let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        if(session == nil)
        {
            self.navigationItem.rightBarButtonItems![0].isEnabled = false;
        }
        else
        {
            self.navigationItem.rightBarButtonItems![0].isEnabled = true;
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//		if((self.chef?.is_weblink_active ?? false) && self.chef?.website == ""){
//            shareChefIV.isHidden = true
//        }else{
//            shareChefIV.isHidden = false
//        }
//        if (self.chef?.foods.count)! > 0 {
//            initTabs(self.chef!.foods)
//        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        if !isChefDescAvailable{
            self.desc.isHidden = true
            self.img.isHidden = true
            self.view.layoutIfNeeded()
        }
        
//        if(self.chef?.website == ""){
//            shareChefIV.isHidden = true
//        }else{
//            shareChefIV.isHidden = false
//        }
        
        guard let indexPath = foodTableView.indexPathForSelectedRow else {
            os_log("No cell has been selected", log: .default, type: .debug)
            return
        }
        foodTableView.deselectRow(at: indexPath, animated: true)
//        filterFoods(chef!.foods)
        foodTableView.reloadData()
        
        updateFav()
        
        print("")
        
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
        RestClient().request(WalayemApi.orderedFoods, params, self) { (result, error) in
            if error != nil{
                return
            }
            
            let value = result!["result"] as! [String: Any]
            self.hadOrdered = value["has_ordered"] as? Bool ?? false
            self.orderedFoods = value["foods"] as? [String] ?? [String]()
            
            for food in self.orderedFoods{
                print("ordereed food-->\(food)")
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.foodTableView.beginUpdates()
        self.foodTableView.endUpdates()
    }
    
    @objc private func addRemoveFavourite(_ sender: UIBarButtonItem){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let params = ["partner_id": user!.partner_id!, "chef_id": chef!.id]
        if chef!.isFav{
            changeFavouriteBarItemIcon(isFav: false)
            RestClient().request(WalayemApi.removeFav, params, self) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    self.changeFavouriteBarItemIcon(isFav: self.chef!.isFav)
                    return
                }
                self.chef!.isFav = false
            }
        }else{
            changeFavouriteBarItemIcon(isFav: true)
            RestClient().request(WalayemApi.addFav, params, self) { (result, error) in
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
        
        RestClient().request(WalayemApi.checkFav, params, self) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let record = result!["result"] as? [String: Any]
            if(record != nil)
            {
                self.chef!.isFav = record!["is_favorite"] as! Bool
                
                self.changeFavouriteBarItemIcon(isFav: self.chef!.isFav)
            }
        }
    }
    
    private func changeFavouriteBarItemIcon(isFav: Bool){
        favouriteBarItem?.image = isFav ? UIImage(named: "favourite") : UIImage(named: "emptyFavourite")
    }
    
    private func initTabs(_ foods: [Food]){
        for food in foods {
			DLog(message: (food.foodType ?? ""))
            if(food.foodType == FoodCategEnum.appetizer.rawValue){
                hasAppetizers = true
            }else if(food.foodType == FoodCategEnum.maincourse.rawValue){
                hasMainCourse = true
            }else if(food.foodType == FoodCategEnum.dessert.rawValue){
                hasDesserts = true
            }else if(food.foodType == FoodCategEnum.drink.rawValue){
                hasDrinks = true
			} else if(food.foodType == FoodCategEnum.other.rawValue){
				hasOthers = true
			}
        }
        
        if(hasAppetizers){
            foodCategs.append("Appetizers")
            hasfoodCategs.append(FoodCategEnum.appetizer.rawValue)
        }
        if(hasMainCourse){
            foodCategs.append("Main course")
            hasfoodCategs.append(FoodCategEnum.maincourse.rawValue)
        }
        if(hasDesserts){
            foodCategs.append("Desserts")
            hasfoodCategs.append(FoodCategEnum.dessert.rawValue)
        }
        if(hasDrinks){
            foodCategs.append("Drinks")
            hasfoodCategs.append(FoodCategEnum.drink.rawValue)
        }
		if(hasOthers){
			foodCategs.append("Others")
			hasfoodCategs.append(FoodCategEnum.other.rawValue)
		}
    }
    
    @objc private func tapShareChef(sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5) {
            
            print(self.chef?.website)
            self.chef_website = "\(self.chef?.website ?? "")"
            print("Chef detail tapped...!")
            self.shareChef()
        }
    }
    
    func shareChef(){
		if(self.chef_website != ""){
            let web_p = "http://order.walayem.com/" + "\(self.chef_website)"
            if let urlStr = NSURL(string: web_p) {
                let string = web_p
                let objectsToShare = [string, urlStr] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                if UI_USER_INTERFACE_IDIOM() == .pad {
                     if let popup = activityVC.popoverPresentationController {
                         popup.sourceView = self.view
                         popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                     }
                 }

                self.present(activityVC, animated: true, completion: nil)
             }
        }
    }

    
    private func filterFoods(_ foods: [Food]){
        
        var filterString: String!
        switch selectedCateg{
        case 0:
            
            if(hasfoodCategs.count > 0){
                if(hasfoodCategs[selectedCateg] != ""){
                    filterString = hasfoodCategs[selectedCateg]
                }
            }else if (hasAppetizers  ){
                filterString = FoodCategEnum.appetizer.rawValue
                hasfoodCategs.append(FoodCategEnum.appetizer.rawValue)
            }
            else if(hasMainCourse ) {
                filterString = FoodCategEnum.maincourse.rawValue
                hasfoodCategs.append(FoodCategEnum.maincourse.rawValue)
            }
            else if(hasDesserts) {
                filterString = FoodCategEnum.dessert.rawValue
                hasfoodCategs.append(FoodCategEnum.dessert.rawValue)
            }
            else if(hasDrinks) {
                filterString = FoodCategEnum.drink.rawValue
                hasfoodCategs.append(FoodCategEnum.drink.rawValue)
            }
			else if(hasOthers){
				filterString = FoodCategEnum.other.rawValue
				hasfoodCategs.append(FoodCategEnum.other.rawValue)
			}
        case 1:
            
            if(hasfoodCategs.count > 1){
                if(hasfoodCategs[selectedCateg] != ""){
                    filterString = hasfoodCategs[selectedCateg]
                }
            }else if(hasMainCourse ){
                 filterString = FoodCategEnum.maincourse.rawValue
                 hasfoodCategs.append(FoodCategEnum.maincourse.rawValue)
            }
            else if(hasDesserts ){
              filterString = FoodCategEnum.dessert.rawValue
              hasfoodCategs.append(FoodCategEnum.dessert.rawValue)
            }
            else if(hasDrinks){
                filterString = FoodCategEnum.drink.rawValue
                hasfoodCategs.append(FoodCategEnum.drink.rawValue)
            }
			else if(hasOthers){
				filterString = FoodCategEnum.other.rawValue
				hasfoodCategs.append(FoodCategEnum.other.rawValue)
			}
        case 2:
            
            if(hasfoodCategs.count > 2){
                if(hasfoodCategs[selectedCateg] != ""){
                    filterString = hasfoodCategs[selectedCateg]
                }
            }else if(hasDesserts ){
                filterString = FoodCategEnum.dessert.rawValue
                hasfoodCategs.append(FoodCategEnum.dessert.rawValue)
            }else if(hasDrinks){
                filterString = FoodCategEnum.drink.rawValue
                hasfoodCategs.append(FoodCategEnum.drink.rawValue)
            }
			else if(hasOthers){
				filterString = FoodCategEnum.other.rawValue
				hasfoodCategs.append(FoodCategEnum.other.rawValue)
			}
        case 3:
            
            if(hasfoodCategs.count > 3){
                if(hasfoodCategs[selectedCateg] != ""){
                    filterString = hasfoodCategs[selectedCateg]
                }
            }else  if(hasDrinks){
                filterString = FoodCategEnum.drink.rawValue
                hasfoodCategs.append(FoodCategEnum.drink.rawValue)
            }
			else if(hasOthers){
				filterString = FoodCategEnum.other.rawValue
				hasfoodCategs.append(FoodCategEnum.other.rawValue)
			}
		case 4:
				
				if(hasfoodCategs.count > 4){
					if(hasfoodCategs[selectedCateg] != ""){
						filterString = hasfoodCategs[selectedCateg]
					}
				}
				else if(hasOthers){
					filterString = FoodCategEnum.other.rawValue
					hasfoodCategs.append(FoodCategEnum.other.rawValue)
			}
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
        if let tabItem = tabBarController?.tabBar.items?[3]{
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
			foodTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didTapRemoveItem(sender: FoodTableViewCell) {
        guard let indexPath = foodTableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = filteredFoods[indexPath.row]
        if db.subtractFoodDirectly(foodId: food.id ?? 0){
            print ("Quantity subtracted")
            updateBadge()
			foodTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
		
    private func getChef(){
        
        showSpinner()
        let params : [String: Int] = ["chef_id": self.chef_id!]
        RestClient().request(WalayemApi.getChefById, params, self) { (result, error) in
            if let error = error{
                self.handleNetworkError(error)
                return
            }
                
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Bool, status == false{
                return
            }
            
            let records = value["data"] as! [String: Any]
            
            let mChef = Chef(record: records, name: "init")
            self.chef = mChef
            self.chef_website = mChef.website
                self.hideSpinner()
            self.foodTableView.reloadData()
            self.collectionView.reloadData()
            self.initVC()
            
        }
    }
    
    private func handleNetworkError(_ error: NSError){
             if error.userInfo[NSLocalizedDescriptionKey] != nil{
                 let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                 if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
                     let alert = UIAlertController(title: "Cannot get Foods", message: errmsg, preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                     present(alert, animated: true, completion: nil)
                 }else if errmsg == OdooClient.SESSION_EXPIRED{
                     self.onSessionExpired()
                 }
             }
             else{
                 showSorryAlertWithMessage("Please check your internet connection...!")
             }
         }
      
      private func showSorryAlertWithMessage(_ msg: String){
          let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
          present(alert, animated: true, completion: nil)
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
//        foodDetailVC.metaLocation = metaLocation
        foodDetailVC.food = food
		foodDetailVC.is_website_link_active = food.is_website_link_active
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
            cell.iconImageView.isHidden = false
            cell.titleLabel.textColor = UIColor.init(light: UIColor.steel, dark: UIColor.silver)
         }else{
            cell.titleLabel.textColor = UIColor.init(light: UIColor.silverTen, dark: UIColor.steel)
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

extension ChefDetailViewController: ChefRatingDelegate {
	
	func chefRated() {
		getChefRating(chef?.id ?? 0)
	}
	
}
