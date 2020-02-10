//
//  DiscoverTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import DatePickerDialog

class DiscoverTableViewController: UIViewController, FoodCellDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popularView: UIStackView!
    weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var datePickerButton: UIButton!
    let db = DatabaseHandler()
    var partnerId: Int?
    var selectedTags = [Tag]()
    var selectedCuisines = [Cuisine]()
    var homeSelectedCuisines = [Cuisine]()
    var recommendedFoods = [Food]()
    var foods = [Food]()
    var page: Int = 0
    var totalPage: Int?
    var isLoading = false
    var addressList = [Address]()
    var isSearching = false
//    var lastIndex
//    var indexPath = []
//    var cartItems = [CartItem]()
    
    @IBAction func locationPickClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Select an address", preferredStyle: .actionSheet)
        
        for address in self.addressList
        {
            alert.addAction(UIAlertAction(title: address.name, style: .default, handler: { (action) in
                self.locationPickButton.setTitle(address.name, for: .normal)
                if(StaticLinker.chefViewController != nil){
                    StaticLinker.chefViewController?.locationPickButton.setTitle(address.name, for: .normal)
                }
                let userDefaults = UserDefaults.standard
                userDefaults.set(address.id, forKey: "OrderAddress")
                userDefaults.synchronize()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        if(addressList.count > 0){
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func datePickerClicked(_ sender: Any) {
        datePickerTapped()
    }
    @IBOutlet weak var locationPickButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func unwindFromFilterVC(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? FilterViewController{
            self.selectedTags = sourceVC.selectedTags!
            self.selectedCuisines = sourceVC.selectedCuisines!
            let badgeNumber = selectedTags.count + selectedCuisines.count
            
            do{
                if badgeNumber > 0{
                    searchFood()
                    filterBarButton.addBadge(number: badgeNumber, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
                }else {
                    getFoods()
                    filterBarButton.removeBadge()
                }
            }
            catch {
            
            }
        }
    }
    
    func showCuisineFromHome() {
//        self.selectedCuisines = [cuisine]
//        let badge = 1
//        searchFood()
//        filterBarButton.addBadge(number: badge, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
        let badgeNumber = 1
        do{
            if badgeNumber > 0{
                searchFood()
                filterBarButton.addBadge(number: badgeNumber, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
            }else {
                getFoods()
                filterBarButton.removeBadge()
            }
        }
        catch {
        
        }
    }
    
    @IBAction func showFilter(sender: UIBarButtonItem){
        guard let filterVC = UIStoryboard(name: "Discover", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterVC") as? FilterViewController else {
            fatalError("Unexpected view controller")
        }
        filterVC.selectedTags = selectedTags
        filterVC.selectedCuisines = selectedCuisines
        present(filterVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
        datePickerButton.setTitle("ASAP", for: .normal)
        setupSearch()
        setupRefreshControl()

//        let strNumber: NSString = "Today at 5pm to Address" as NSString
//        let range = (strNumber).range(of: "to")
//        let attribute = NSMutableAttributedString.init(string: strNumber as String)
//        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray , range: range)
//        scheduleButton.setAttributedTitle(attribute, for: .normal)

        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        showActivityIndicator()
        getRecommendations()
        getFoods()
        updateBadge()
//        getAddress()
        Utils.setupNavigationBar(nav: self.navigationController!)
        StaticLinker.discoverViewController = self
        
        print(StaticLinker.selectedCuisine)
        initialCustomDate()
        
        if StaticLinker.selectedCuisine != nil {
            self.selectedCuisines.append(StaticLinker.selectedCuisine!)
            self.showCuisineFromHome()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: selectedIndexPath)
        }
        
        self.tableView.reloadData()
//        getAddress()
//        hideActivityIndicator()
        
        if StaticLinker.selectedCuisine != nil {
            self.selectedCuisines.append(StaticLinker.selectedCuisine!)
            self.showCuisineFromHome()
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool){
        
    }
    
    

    
    // MARK: Private methods
    
    
    private func getAddress(){
        let params = ["partner_id": partnerId!]
        
        RestClient().request(WalayemApi.address, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
                    self.onSessionExpired()
                }
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            self.addressList.removeAll()
            let records = value["addresses"] as! [Any]
            if records.count == 0{
                return
            }
            for record in records{
                let address = Address(record: record as! [String : Any])
                self.addressList.append(address)
            }
            
            let selectedAddressId = UserDefaults.standard.integer(forKey: "OrderAddress") as Int?
            if(selectedAddressId != nil){
                for addr in self.addressList{
                    if(addr.id == selectedAddressId){
                        self.locationPickButton.setTitle(addr.name, for: .normal)
                    }
                }
            }
        }
    }
    
    func initialCustomDate() {
        let startTime = Utils.getChefStartTime()
        let endTime = Utils.getChefEndTime()
        let minHours = Utils.getMinHours()
        
        let cal = Calendar.current
        var dt = cal.date(byAdding: .hour, value: minHours, to: Date())
        

        var components = cal.dateComponents([.year, .month, .day, .hour], from: dt!)

        if components.hour! < startTime {
            components.hour = startTime
            components.minute = 0
        }
        else if components.hour! > endTime - 1 {
            components.hour = endTime - 1
            components.minute = 59
        }
        
        dt = cal.date(from: components)! // 2018-10-10
        
        
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
//        dateFormatter.dateFormat = "dd MMM yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm aa"
        
        let time_str = timeFormatter.string(from: dt!)
        var date_str = dateFormatter.string(from: dt!)
        
        if calendar.isDateInToday(dt!) { date_str = "Today" }
        else if calendar.isDateInTomorrow(dt!) { date_str = "Tomorrow" }
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date_time_str = dateTimeFormatter.string(from: dt!)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set("future", forKey: "OrderType")
        userDefaults.set(date_time_str, forKey: "OrderDate")
        userDefaults.synchronize()
//
        if(StaticLinker.chefViewController != nil){
            StaticLinker.chefViewController?.timePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
        }
        self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
//        self.datePickerButton.setTitle("ASAP", for: .normal)
        
    }
    
    func datePickerTapped() {
        let startTime = Utils.getChefStartTime()
        let endTime = Utils.getChefEndTime()
        let minHours = Utils.getMinHours()
        
        let calendar = Calendar.current
        var date = calendar.date(byAdding: .hour, value: minHours, to: Date())
        
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)

        if components.hour! < startTime {
            components.hour = startTime
            components.minute = 0
        }
        else if components.hour! > endTime - 1 {
            components.hour = endTime - 1
            components.minute = 59
        }
        
        date = calendar.date(from: components)! // 2018-10-10
        
        let orderFirstTime = UserDefaults.standard.bool(forKey: UserDefaultsKeys.ORDER_FIRST_TIME)
        
        if(!orderFirstTime){
            
            Utils.showDelayAlert(context: self)
            Utils.setUserDefaults(value: true, key: UserDefaultsKeys.ORDER_FIRST_TIME)
//
//            let userDefaults = UserDefaults.standard
//            userDefaults.set(true, forKey: UserDefaultsKeys.ORDER_FIRST_TIME)
//            userDefaults.synchronize()
            
            
        }
        
        
        
        
        
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", startTime: startTime, endTime: endTime, minimumDate: date , datePickerMode: .dateAndTime) {
            (date) -> Void in
            if let dt = date {
                let thisDate = Date()
                if thisDate > dt{
                    self.datePickerButton.setTitle("ASAP", for: .normal)
                    let userDefaults = UserDefaults.standard
                    userDefaults.set("asap", forKey: "OrderType")
                    userDefaults.synchronize()
                    return
                }
                let calendar = NSCalendar.current
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"
                //dateFormatter.dateFormat = "dd MMM yyyy"
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm aa"
                
                let time_str = timeFormatter.string(from: dt)
                var date_str = dateFormatter.string(from: dt)
                
                if calendar.isDateInToday(dt) { date_str = "Today" }
                else if calendar.isDateInTomorrow(dt) { date_str = "Tomorrow" }
                
                let dateTimeFormatter = DateFormatter()
                dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date_time_str = dateTimeFormatter.string(from: dt)
                
                let userDefaults = UserDefaults.standard
                userDefaults.set("future", forKey: "OrderType")
                userDefaults.set(date_time_str, forKey: "OrderDate")
                userDefaults.synchronize()
                
                if(StaticLinker.chefViewController != nil){
                    StaticLinker.chefViewController?.timePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
                }
                self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
                
                
            }
        }
    }
   
    private func setupSearch(){
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
                navigationItem.standardAppearance = appearance
                navigationItem.scrollEdgeAppearance = appearance
            
        } else {
            // Fallback on earlier versions
        }
      
        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "FoodSearchResultVC") as? FoodSearchResultController else {
            fatalError("Unexpected ViewController")
        }
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchResultsUpdater = searchResultController
        searchController.searchBar.placeholder = "Search for foods"
        searchController.searchBar.tintColor = UIColor.colorPrimary
        searchController.searchBar.setShowsCancelButton(false, animated: true)
        searchController.searchBar.showsCancelButton = false
        
        if #available(iOS 11.0, *){
            navigationItem.searchController = searchController
        }else{
            navigationItem.titleView = searchController.searchBar
        }
        searchController.searchBar.setShowsCancelButton(false, animated: true)
         searchController.searchBar.showsCancelButton = false
        definesPresentationContext = true
    }
    
    private func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshData(sender: UIRefreshControl){
        // reset filter
        selectedTags.removeAll()
        selectedCuisines.removeAll()
        filterBarButton.removeBadge()
        getRecommendations()
        getFoods()
        isSearching = false
    }
    
    private func getRecommendations(){
        let params : [String: Any] = ["partner_id": partnerId ?? 0]
        
        RestClient().request(WalayemApi.recommendation, params) { (result, error) in
            self.hideActivityIndicator()
            self.tableView.refreshControl?.endRefreshing()
            
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
            self.collectionView.reloadData()
        }
    }
    
    private func getFoods(){
        if isLoading {
            return
        }
        let params : [String: Int] = ["page": 1]
        isLoading = true
        RestClient().request(WalayemApi.discoverFood, params) { (result, error) in
            self.isLoading = false
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
            self.page = value["current_page"] as! Int
            self.totalPage = value["total_pages"] as? Int
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
//                self.foods.append(food)
                
                if !self.foods.contains(food){
                    self.foods.append(food)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func getMoreFoods(){
        if (isLoading || isSearching){
            return
        }
        let params : [String: Int] = ["page": page + 1]
        isLoading = true
        RestClient().request(WalayemApi.discoverFood, params) { (result, error) in
            self.isLoading = false
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.page = value["current_page"] as! Int
            self.totalPage = value["total_pages"] as? Int
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
//                self.foods.append(food)
                
                if !self.foods.contains(food){
                    self.foods.append(food)
                }
                
            }
            self.tableView.reloadData()
            self.tableView.tableFooterView = nil
        }
    }
    
    private func searchFood(){
        isSearching = true
//        self.foods.removeAll()
        
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            (tag.id ?? 0)
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            (cuisine.id ?? 0)
        }
        let params: [String: Any] = ["search": false, "food_tags": tagIds, "cuisine": cuisineIds]
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
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.color = UIColor.colorPrimary
        activityIndicator.hidesWhenStopped = true
        
        tableView.tableHeaderView?.frame.size.height = 0
        tableView.backgroundView = activityIndicator
        tableView.separatorStyle = .none
        
        activityIndicator.startAnimating()
        self.activityIndicator = activityIndicator
    }
    
    private func hideActivityIndicator(){
        self.activityIndicator?.stopAnimating()
        tableView.tableHeaderView?.frame.size.height = 390
        self.tableView.separatorStyle = .singleLine
    }
    
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
            print ("Quantity added")
            updateBadge()
            
        }
    }
    
    func didTapRemoveItem(sender: FoodTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = foods[indexPath.row]
        if db.subtractFoodDirectly(foodId: food.id ?? 0){
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

extension DiscoverTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: indexPath) as? FoodTableViewCell else {
            fatalError("Unexpected cell")
        }
        cell.delegate = self
        let food = foods[indexPath.row]
        cell.food = food
//        cell.food.quantity = 0
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !isSearching{
            if indexPath.row == foods.count - 1 && page < totalPage!{
                getMoreFoods()
                
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                activityIndicator.startAnimating()
                
                tableView.tableFooterView = activityIndicator
            }
        }
    }
    
}

extension DiscoverTableViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCollectionViewCell", for: indexPath) as? RecommendationCollectionViewCell else{
            fatalError("Unexpected CollectionViewCell")
        }
        
        let food = recommendedFoods[indexPath.row]
        cell.food = food
        
        return cell
    }
    
    func setSelectedCuisines(cuisines: [Cuisine]){
        self.selectedCuisines = cuisines
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
            fatalError("Unexpected destination VC")
        }
        let food = recommendedFoods[indexPath.row]
        destinationVC.food = food
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}
