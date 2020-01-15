//
//  FoodDetailViewController.swift
//  Walayem
//
//  Created by MAC on 4/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

//import UIKit
//import Kingfisher
//
//class FoodDetailViewController: UIViewController {
//
//    // MARK: Properties
//    
//    @IBOutlet weak var foodImageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var tagsLabel: UILabel!
//    @IBOutlet weak var estimatedTimeLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var deliveryLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var serveLabel: UILabel!
//    @IBOutlet weak var kitchenLabel: UILabel!
//    @IBOutlet weak var cuisineLabel: UILabel!
//    @IBOutlet weak var saveButton: UIButton!
//    @IBOutlet weak var addButton: UIButton!
//    @IBOutlet weak var subtractButton: UIButton!
//    @IBOutlet weak var descriptionImageView: UIImageView!
//    @IBOutlet weak var timeImageView: UIImageView!
//    @IBOutlet weak var quantityImageView: UIImageView!
//    var favouriteBarItem: UIBarButtonItem?
//    
//    var food: Food?
//    var user: User?
//    let db = DatabaseHandler()
//    
//    // MARK: Actions
//    
//    @IBAction func addItem(_ sender: UIButton) {
//        food?.quantity += 1
//        setSaveButtonTitle()
//    }
//    
//    @IBAction func subtractItem(_ sender: UIButton) {
//        if food!.quantity > 1{
//            food?.quantity -= 1
//            setSaveButtonTitle()
//        }
//    }
//    
//    @IBAction func saveToCart(_ sender: UIButton){
//        let r = db.addFood(item: food!)
//        if r != -1{
//            let alert = UIAlertController(title: "Success", message: "Food is added to your cart.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Add more", style: .default, handler: { (action) in
//                
//            }))
//            alert.addAction(UIAlertAction(title: "Done", style: .destructive, handler: { (action) in
//                self.navigationController?.popViewController(animated: true)
//            }))
//            
//            self.present(alert, animated: true, completion: nil)
//            updateBadge()
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        Utils.setupNavigationBar(nav: self.navigationController!)
//        Utils.setupNavigationBarDiscover(nav: self.navigationController!)
//        
//        user = User().getUserDefaults()
//        
//        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .never
//        } 
//        favouriteBarItem = UIBarButtonItem(image: UIImage(named: "emptyFavourite"), style: .plain, target: self, action: #selector(addRemoveFavourite(_:)))
//        navigationItem.setRightBarButton(favouriteBarItem, animated: false)
//        navigationItem.title = "test"
//        setCollectionView()
//        setViews()
//        if traitCollection.forceTouchCapability == .available{
//            registerForPreviewing(with: self, sourceView: collectionView)
//        }
//        
//        if let food = food{
//            checkIfFavourite(food.id)
//
//            let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
//            foodImageView.kf.setImage(with: imageUrl)
//            
//            food.quantity = 1
//            nameLabel.text = food.name
////            self.navigationItem.title = food.name
//            kitchenLabel.text = food.kitcherName! + " \u{2022} " + food.chefName!
//                    
//            let time = Int(max(1, round( Double(food.preparationTime) / 60.0)))
//
//            estimatedTimeLabel.text = "\(time) hour(s)"
//            priceLabel.text = "AED \(food.price)"
//            descriptionLabel.text = food.description
//            deliveryLabel.text = "Home delivery"
//            timeLabel.text = "Preparation \(time) hour(s)"
//            serveLabel.text = "Serves \(food.servingQunatity) people"
//            
//            var tags: String = ""
//            for tag in food.tags{
//                tags.append(tag.name)
//                if let lastTag = food.tags.last, lastTag !== tag{
//                    tags.append(" \u{2022} ")
//                }
//            }
//            tagsLabel.text = tags
//            cuisineLabel.text = food.cuisine?.name
//            
//            setSaveButtonTitle()
//            collectionView.reloadData()
//        }
//         Utils.setupNavigationBar(nav: self.navigationController!)
//    }
//    
//    // MARK: Private methods
//    
//    private func setCollectionView(){
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
////        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//    
//    private func setViews(){
////        foodImageView.layer.cornerRadius = 0
//        foodImageView.layer.frame.size.width = self.view.frame.size.width
//        foodImageView.layer.cornerRadius = 12
//        foodImageView.layer.masksToBounds = true
//        addButton.roundCorners([.topRight], radius: 20)
//        subtractButton.roundCorners([.topLeft], radius: 20)
//        
//        descriptionImageView.tintColor = UIColor.amber
//        timeImageView.tintColor = UIColor.silverTen
//        quantityImageView.tintColor = UIColor.silverTen
//    }
//    
//    private func setSaveButtonTitle(){
//        let title = "Add \(food!.quantity) (AED \(Double(food!.quantity) * food!.price))"
//        saveButton.setTitle(title, for: .normal)
//    }
//    
//    private func checkIfFavourite(_ foodId: Int){
//        let params = ["partner_id": user!.partner_id!, "product_id": foodId]
//        
//        RestClient().request(WalayemApi.checkFav, params) { (result, error) in
//            if error != nil{
//                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
//                print (errmsg)
//                return
//            }
//            
//            let record = result!["result"] as! [String: Any]
//            self.food!.isFav = record["is_favorite"] as! Bool
//            
//            self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
//        }
//    }
//    
//    private func changeFavouriteBarItemIcon(isFav: Bool){
//        favouriteBarItem?.image = isFav ? UIImage(named: "favourite") : UIImage(named: "emptyFavourite")
//    }
//    
//    @objc private func addRemoveFavourite(_ sender: UIBarButtonItem){
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let params = ["partner_id": user!.partner_id!, "product_id": food!.id]
//        if food!.isFav{
//            changeFavouriteBarItemIcon(isFav: false)
//            RestClient().request(WalayemApi.removeFav, params) { (result, error) in
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if error != nil{
//                    self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
//                    return
//                }
//                self.food!.isFav = false
//            }
//        }else{
//            changeFavouriteBarItemIcon(isFav: true)
//            RestClient().request(WalayemApi.addFav, params) { (result, error) in
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if error != nil{
//                    self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
//                    return
//                }
//                self.food!.isFav = true
//            }
//        }
//    }
//    
//    private func updateBadge(){
//        if let tabItem = tabBarController?.tabBar.items?[2]{
//            tabItem.badgeColor = UIColor.colorPrimary
//            tabItem.badgeValue = db.getFoodsCount()
//        }
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//extension FoodDetailViewController: UIScrollViewDelegate{
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView is UICollectionView{
//            return
//        }
//        if !scrollView.bounds.intersects(nameLabel.frame){
//            UIView.animate(withDuration: 0.5, animations: {
//                self.navigationItem.title = self.food?.name
//            })
//        }else{
//            UIView.animate(withDuration: 0.5) {
//                self.navigationItem.title = ""
//            }
//        }
//        
//    }
//    
//}
//
//extension FoodDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return (food?.imageIds!.count)!
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCollectionViewCell", for: indexPath) as? ChefFoodCollectionViewCell else {
//            fatalError("Unexpected CollectionViewCell")
//        }
////        cell.foodImageView.layer.cornerRadius = 15
////        cell.foodImageView.layer.masksToBounds = true
//////        cell.layer.frame.size.width = self.view.frame.width
//////        cell.layer.frame.size. = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
////        // adding shadow
////        cell.layer.cornerRadius = 15
//////        cell.layer.cornerRadius = 0
////        cell.layer.masksToBounds = false
////
////        cell.layer.shadowColor = UIColor.black.cgColor
////        cell.layer.shadowOpacity = 0.3
////        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
////        cell.layer.shadowRadius = 5
////        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 15).cgPath
////
////        let id = food?.imageIds![indexPath.row] ?? 0
////        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/food.image/\(id)/image")
////        cell.foodImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "foodImageEmpty"))
//        
//          cell.foodImageView.layer.cornerRadius = 15
//          cell.foodImageView.layer.masksToBounds = true
//          // adding shadow
//          cell.layer.cornerRadius = 15
//          cell.layer.masksToBounds = false
//          cell.layer.shadowColor = UIColor.black.cgColor
//          cell.layer.shadowOpacity = 0.3
//          cell.layer.shadowOffset = CGSize(width: 0, height: 5)
//          cell.layer.shadowRadius = 5
//          cell.layer.frame.size.width = self.view.frame.width
//          cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 15).cgPath
//          
//          let id = food?.imageIds![indexPath.row] ?? 0
//          let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/food.image/\(id)/image")
//          cell.foodImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "foodImageEmpty"))
//              
//        
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ChefFoodCollectionViewCell else {
//            fatalError("Unexpected CollectionViewCell")
//        }
//        let selectedImage = selectedCell.foodImageView.image
//        guard let imageVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController else {
//            fatalError("Unexpected view controller")
//        }
//        imageVC.image = selectedImage
//        self.navigationController?.pushViewController(imageVC, animated: true)
//    }
//}
//
//extension FoodDetailViewController: UIViewControllerPreviewingDelegate{
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        guard let indexPath = collectionView.indexPathForItem(at: location) else {
//            return nil
//        }
//        guard let cell = collectionView.cellForItem(at: indexPath) as? ChefFoodCollectionViewCell else {
//            fatalError("Unexpected cell")
//        }
//        guard let imageVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController else {
//            fatalError("Unexpected view controller")
//        }
//        
//        let selectedImage = cell.foodImageView.image
//        imageVC.image = selectedImage
//        imageVC.preferredContentSize = CGSize(width: 0.0, height: 300)
//        previewingContext.sourceRect = cell.frame
//        
//        return imageVC
//    }
//    
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        navigationController?.pushViewController(viewControllerToCommit, animated: true)
//    }
//
//}


import UIKit
import Kingfisher

class FoodDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var serveLabel: UILabel!
    @IBOutlet weak var kitchenLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var quantityImageView: UIImageView!
    var favouriteBarItem: UIBarButtonItem?
    
    var food: Food?
    var user: User?
    let db = DatabaseHandler()
    
    // MARK: Actions
    
    @IBAction func addItem(_ sender: UIButton) {
        food?.quantity += 1
        setSaveButtonTitle()
    }
    
    @IBAction func subtractItem(_ sender: UIButton) {
        if food!.quantity > 1{
            food?.quantity -= 1
            setSaveButtonTitle()
        }
    }
    
    @IBAction func saveToCart(_ sender: UIButton){
        let r = db.addFood(item: food!)
        if r != -1{
            let alert = UIAlertController(title: "Success", message: "Food is added to your cart.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Add more", style: .default, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "Done", style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            updateBadge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setupNavigationBar(nav: self.navigationController!)
        user = User().getUserDefaults()
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        favouriteBarItem = UIBarButtonItem(image: UIImage(named: "emptyFavourite"), style: .plain, target: self, action: #selector(addRemoveFavourite(_:)))
        navigationItem.setRightBarButton(favouriteBarItem, animated: false)
       
        setCollectionView()
        setViews()
        if traitCollection.forceTouchCapability == .available{
            registerForPreviewing(with: self, sourceView: collectionView)
        }
        
        if let food = food{
            checkIfFavourite(food.id)

            let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(food.id)/image")
            foodImageView.kf.setImage(with: imageUrl)
            
            food.quantity = 1
            nameLabel.text = food.name
            kitchenLabel.text = food.kitcherName! + " \u{2022} " + food.chefName!
                    
            let time = Int(max(1, round( Double(food.preparationTime) / 60.0)))

            estimatedTimeLabel.text = "\(time) hour(s)"
            priceLabel.text = "AED \(food.price)"
            descriptionLabel.text = food.description
            deliveryLabel.text = "Home delivery"
            timeLabel.text = "Preparation \(time) hour(s)"
            serveLabel.text = "Serves \(food.servingQunatity) people"
            
            var tags: String = ""
            for tag in food.tags{
                tags.append(tag.name ?? "")
                if let lastTag = food.tags.last, lastTag !== tag{
                    tags.append(" \u{2022} ")
                }
            }
            tagsLabel.text = tags
            cuisineLabel.text = food.cuisine?.name
            
            setSaveButtonTitle()
            collectionView.reloadData()
        }
         Utils.setupNavigationBar(nav: self.navigationController!)
    }
    
    // MARK: Private methods
    
    private func setCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private func setViews(){
        foodImageView.layer.cornerRadius = 12
        foodImageView.layer.masksToBounds = true
        addButton.roundCorners([.topRight], radius: 20)
        subtractButton.roundCorners([.topLeft], radius: 20)
        
        descriptionImageView.tintColor = UIColor.amber
        timeImageView.tintColor = UIColor.silverTen
        quantityImageView.tintColor = UIColor.silverTen
    }
    
    private func setSaveButtonTitle(){
        let title = "Add \(food!.quantity) (AED \(Double(food!.quantity) * food!.price))"
        saveButton.setTitle(title, for: .normal)
    }
    
    private func checkIfFavourite(_ foodId: Int){
        let params = ["partner_id": user!.partner_id!, "product_id": foodId]
        
        RestClient().request(WalayemApi.checkFav, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            
            let record = result!["result"] as! [String: Any]
            self.food!.isFav = record["is_favorite"] as! Bool
            
            self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
        }
    }
    
    private func changeFavouriteBarItemIcon(isFav: Bool){
        favouriteBarItem?.image = isFav ? UIImage(named: "favourite") : UIImage(named: "emptyFavourite")
    }
    
    @objc private func addRemoveFavourite(_ sender: UIBarButtonItem){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let params = ["partner_id": user!.partner_id!, "product_id": food!.id]
        if food!.isFav{
            changeFavouriteBarItemIcon(isFav: false)
            RestClient().request(WalayemApi.removeFav, params) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
                    return
                }
                self.food!.isFav = false
            }
        }else{
            changeFavouriteBarItemIcon(isFav: true)
            RestClient().request(WalayemApi.addFav, params) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil{
                    self.changeFavouriteBarItemIcon(isFav: self.food!.isFav)
                    return
                }
                self.food!.isFav = true
            }
        }
    }
    
    private func updateBadge(){
        if let tabItem = tabBarController?.tabBar.items?[2]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = db.getFoodsCount()
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

extension FoodDetailViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView{
            return
        }
        if !scrollView.bounds.intersects(nameLabel.frame){
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationItem.title = self.food?.name
            })
        }else{
            UIView.animate(withDuration: 0.5) {
                self.navigationItem.title = ""
            }
        }
        
    }
    
}

extension FoodDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (food?.imageIds!.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCollectionViewCell", for: indexPath) as? ChefFoodCollectionViewCell else {
            fatalError("Unexpected CollectionViewCell")
        }
        cell.foodImageView.layer.cornerRadius = 15
        cell.foodImageView.layer.masksToBounds = true
        // adding shadow
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.layer.shadowRadius = 5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 15).cgPath
        print(cell.layer.frame.width)
        print(cell.layer.frame)
        
        
        
        let id = food?.imageIds![indexPath.row] ?? 0
        let imageUrl = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/food.image/\(id)/image")
        cell.foodImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "foodImageEmpty"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ChefFoodCollectionViewCell else {
            fatalError("Unexpected CollectionViewCell")
        }
        let selectedImage = selectedCell.foodImageView.image
        guard let imageVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController else {
            fatalError("Unexpected view controller")
        }
        imageVC.image = selectedImage
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
}

extension FoodDetailViewController: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return nil
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChefFoodCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        guard let imageVC = UIStoryboard(name: "More", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageVC") as? ImageViewController else {
            fatalError("Unexpected view controller")
        }
        
        let selectedImage = cell.foodImageView.image
        imageVC.image = selectedImage
        imageVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        previewingContext.sourceRect = cell.frame
        
        return imageVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}
