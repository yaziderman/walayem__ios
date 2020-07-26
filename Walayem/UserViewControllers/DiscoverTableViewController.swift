//
//  DiscoverTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import DatePickerDialog

class DiscoverTableViewController: BaseTabViewController, FoodCellDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popularView: UIStackView!
//    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var recommendedHeight: NSLayoutConstraint!
    
    weak var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var datePickerButton: UIButton!
    let db = DatabaseHandler()
    var partnerId: Int?
    var selectedTags = [Tag]()
    var selectedCuisines = [Cuisine]()
    var homeSelectedCuisines = [Cuisine]()
    var recommendedFoods = [Food]()
    var foods = [Food]()
    var page: Int = 0
    var totalPage: Int = 0
    var isLoading = false
    var addressList = [Address]()
    var isSearching = false
    var isFirtTime = true
	var metaLocation = ""
//    @IBOutlet weak var recommendedHeight: NSLayoutConstraint!
    
    var mCells = [FoodTableViewCell]()
//    var lastIndex
//    var indexPath = []
//    var cartItems = [CartItem]()
    var spinnerView = UIView()
       
    func showSpinner(){
        spinnerView = getSpinnerView()
        self.view.addSubview(spinnerView)
    }
   
    func hideSpinner(){
        spinnerView.removeFromSuperview()
    }
       
    @IBAction func locationPickClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Select an address", preferredStyle: .actionSheet)
        
        for address in self.addressList
        {
            alert.addAction(UIAlertAction(title: address.name, style: .default, handler: { (action) in
                self.locationPickButton.setTitle(address.name, for: .normal)
//                if(StaticLinker.chefViewController != nil){
//                    StaticLinker.chefViewController?.locationPickButton.setTitle(address.name, for: .normal)
//                }
                let userDefaults = UserDefaults.standard
                userDefaults.set(address.id, forKey: "OrderAddress")
                userDefaults.synchronize()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        if(addressList.count > 0){
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
            if(session == nil){
                self.showAlertBeforeLogin(message: "Please login to add Address...!")
            }
//            else{
//                self.present(alert, animated: true, completion: nil)
//            }
        }
    }
    
    @IBAction func datePickerClicked(_ sender: Any) {
//        let alert = UIAlertController(title: "", message: "When do you want your meal?", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "ASAP", style: .default, handler: { (action) in
//            self.datePickerButton.setTitle("ASAP", for: .normal)
//            let userDefaults = UserDefaults.standard
//            userDefaults.set("asap", forKey: "OrderType")
//            userDefaults.synchronize()
//        }))
//        alert.addAction(UIAlertAction(title: "Custom time", style: .default, handler: { (action) in
//            self.datePickerTapped()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
//            self.navigationController?.popViewController(animated: true)
//        }))
//
//        self.present(alert, animated: true, completion: nil)
//
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
                    searchFood(isAddress: AreaFilter.shared.isAddress)
                    filterBarButton.addBadge(number: badgeNumber, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
                }else {
                    getFoods(isAddress: AreaFilter.shared.isAddress)
                    filterBarButton.removeBadge()
                }
            }
            catch {
            
            }
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
//        datePickerButton.setTitle("ASAP", for: .normal)
        setupSearch()
        setupRefreshControl()
        showSpinner()

        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        showActivityIndicator()
//        getRecommendations()
//        getFoods()
//        updateBadge()
//        getAddress()
		
        Utils.setupNavigationBar(nav: self.navigationController!)
        StaticLinker.discoverViewController = self

        initialCustomDate()
        

        if isFirtTime {
            isFirtTime = false
            if (StaticLinker.selectedCuisine != nil){
                self.selectedCuisines.append(StaticLinker.selectedCuisine!)
                self.showCuisineFromHome()
            }else{
                getFoods(isAddress: AreaFilter.shared.isAddress)
                updateBadge()
            }
            tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFav) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
    }
    
    override func deliveryLocationSelected(_ location: Location?, title: String) {
        super.deliveryLocationSelected(location, title: title)
        refreshData(sender: UIRefreshControl())
    }
    
    @objc private func filterBtnClicked() {
        let selectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliverySelectionVCId") as! DeliverySelectionViewController
        selectionVC.delegate = self
        let navVC = UINavigationController(rootViewController: selectionVC)
        navVC.navigationBar.isTranslucent = true
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
        }
    
    func refreshItemsQuantity(){
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAddress()
        
        self.view.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodTableViewCell", for: selectedIndexPath)
        }
        
        refreshItemsQuantity()
        
        
//        updateBadge()
        
         if StaticLinker.selectedCuisine != nil && !isFirtTime{
            self.selectedCuisines.append(StaticLinker.selectedCuisine!)
            self.showCuisineFromHome()
            isFirtTime = false
            
        }
        
//        let cells = self.tableView.cells
//            as! [FoodTableViewCell]
        
        for cell in mCells{
            cell.food.quantity = 0
        }
        
        
        
        
//        tableView.scroll(to: .top, animated: true)
        
        
        self.tableView.reloadData()
       
        
        
        hideActivityIndicator()
        updateFav();
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		filterBarButton.removeBadge()
    }
    
    // MARK: Private methods
    
    private func getAddress(){
        let params = ["partner_id": partnerId!]
        
        RestClient().request(WalayemApi.address, params, self) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
//					self.onSessionExpired()
                }
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            let status = value["status"] as! Int
            if (status != 0) {
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

//		if(StaticLinker.chefViewController != nil){
//            StaticLinker.chefViewController?.timePickerButton?.setTitle("\(date_str) at \(time_str)", for: .normal)
//        }
//        self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
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
        
        
        
        
        
//        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", startTime: startTime, endTime: endTime, minimumDate: date , datePickerMode: .dateAndTime) {
//            (date) -> Void in
//            if let dt = date {
//                let thisDate = Date()
//                if thisDate > dt{
//                    self.datePickerButton.setTitle("ASAP", for: .normal)
//                    let userDefaults = UserDefaults.standard
//                    userDefaults.set("asap", forKey: "OrderType")
//                    userDefaults.synchronize()
//                    return
//                }
//                let calendar = NSCalendar.current
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MMM dd yyyy"
//                //dateFormatter.dateFormat = "dd MMM yyyy"
//
//                let timeFormatter = DateFormatter()
//                timeFormatter.dateFormat = "hh:mm aa"
//
//                let time_str = timeFormatter.string(from: dt)
//                var date_str = dateFormatter.string(from: dt)
//
//                if calendar.isDateInToday(dt) { date_str = "Today" }
//                else if calendar.isDateInTomorrow(dt) { date_str = "Tomorrow" }
//
//                let dateTimeFormatter = DateFormatter()
//                dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let date_time_str = dateTimeFormatter.string(from: dt)
//
//                let userDefaults = UserDefaults.standard
//                userDefaults.set("future", forKey: "OrderType")
//                userDefaults.set(date_time_str, forKey: "OrderDate")
//                userDefaults.synchronize()
//
//                if(StaticLinker.chefViewController != nil){
//                    StaticLinker.chefViewController?.timePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
//                }
//                self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
//
//
//            }
//        }
    }
    
    
   
    private func setupSearch(){
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
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
        definesPresentationContext = true
    }
    
    private func setupRefreshControl(){
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.colorPrimary
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
    }
    
    @objc private func refreshData(sender: UIRefreshControl){
        // reset filter
//        showSpinner()
        selectedTags.removeAll()
        selectedCuisines.removeAll()
        filterBarButton.removeBadge()
        mCells.removeAll()
        getFoods(isAddress: AreaFilter.shared.isAddress)
        getMoreFoods(isAddress: AreaFilter.shared.isAddress)
        isSearching = false
    }
    
    private func getRecommendations(){
        var params = AreaFilter.shared.coverageParams
        params["partner_id"] = partnerId ?? 0
//        let params : [String: Any] = ["partner_id": partnerId ?? 0]
        
        RestClient().request(WalayemApi.recommendation, params, self) { (result, error) in
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
    
    private func getFoods(isAddress: Bool){
        if isLoading{
            return
        }
//        var params = AreaFilter.shared.coverageParams
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["page"] = 1
//		params["filter_by"] = "area"//"location"
        
        isLoading = true
        RestClient().request(WalayemApi.discoverFood, params, self) { (result, error) in
            self.hideSpinner()
            self.hideActivityIndicator()
            self.tableView.refreshControl?.endRefreshing()
            self.isLoading = false
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
				self.foods.removeAll()
				self.tableView.reloadData()
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
				self.foods.removeAll()
				self.tableView.reloadData()
                return
            }
            
            self.hideActivityIndicator()
            self.foods.removeAll()
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
			let meta = value["meta"] as! [String: Any]
			self.metaLocation = meta["name"] as? String ?? ""
            for record in records{
                let food = Food(record: record as! [String: Any])
                if !self.foods.contains(food){
                    self.foods.append(food)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func getMoreFoods(isAddress: Bool){
        if (isLoading){
            return
        }
//		var params = AreaFilter.shared.coverageParams
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
		params["page"] = page + 1
//		params["filter_by"] = "area"//"location"
		if (isLoading || isSearching){
            return
        }
//        let params : [String: Int] = ["page": page + 1]

		isLoading = true
        self.hideActivityIndicator()
        self.hideSpinner()
        self.tableView.refreshControl?.endRefreshing()
        RestClient().request(WalayemApi.discoverFood, params, self) { (result, error) in
		self.tableView.tableFooterView = nil
			
            self.isLoading = false
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
                if !self.foods.contains(food){
                    self.foods.append(food)
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
//    private func searchFood() {
//		self.tableView.tableFooterView = nil
//    }
    
    private func searchFood(isAddress: Bool){
        isSearching = true
        self.hideActivityIndicator()
        self.hideSpinner()
        self.tableView.refreshControl?.endRefreshing()
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            (tag.id ?? 0)
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            (cuisine.id ?? 0)
        }
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["search"] = false
        params["food_tags"] = tagIds
        params["cuisine"] = cuisineIds
        params["page"] = 1
		//"location"
		
        RestClient().request(WalayemApi.searchFood, params, self) { (result, error) in
            self.hideActivityIndicator()
            
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
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
                self.foods.append(food)
            }
            
            self.tableView.reloadData()
        }
        selectedCuisines.removeAll()
        StaticLinker.selectedCuisine = nil
    }
    
    private func searchMoreFood(isAddress: Bool) {
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            (tag.id ?? 0)
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            (cuisine.id ?? 0)
        }
        
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["search"] = false
        params["food_tags"] = tagIds
        params["cuisine"] = cuisineIds
        params["page"] = self.page + 1
//		params["filter_by"] = "location"
		
        RestClient().request(WalayemApi.searchFood, params, self) { (result, error) in
            self.tableView.tableFooterView = nil
            self.hideActivityIndicator()
            
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
                let food = Food(record: record as! [String: Any])
                if !self.foods.contains(food) {
                    self.foods.append(food)
                }
            }
            
            self.tableView.reloadData()
        }
        selectedCuisines.removeAll()
        StaticLinker.selectedCuisine = nil
    }
	
    private func handleNetworkError(_ error: NSError){
        if error.userInfo[NSLocalizedDescriptionKey] != nil{
            let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
            if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
                let alert = UIAlertController(title: "Cannot get Foods", message: errmsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }else if errmsg == OdooClient.SESSION_EXPIRED{
//                self.onSessionExpired()
            }
        }
//        else{
//            showSorryAlertWithMessage("No internet connection...!")
//        }
    }
    
    private func showSorryAlertWithMessage(_ msg: String){
        let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
	
    private func showActivityIndicator(){
        let activityIndicator = UIActivityIndicatorView(style: .gray)
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
        tableView.tableHeaderView?.frame.size.height = 54
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
			tableView.reloadRows(at: [indexPath], with: .none)
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
			tableView.reloadRows(at: [indexPath], with: .none)
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
                    searchFood(isAddress: AreaFilter.shared.isAddress)
                    filterBarButton.addBadge(number: badgeNumber, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
                }else {
                    getFoods(isAddress: AreaFilter.shared.isAddress)
                    filterBarButton.removeBadge()
                }
            }
            catch {
    
            }
        }
    
   override func areaSelected(selectedAreaArray: [Int], areaName: String) {
       super.areaSelected(selectedAreaArray: selectedAreaArray, areaName: areaName)
       getFoods(isAddress: AreaFilter.shared.isAddress)
   }
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
        self.mCells.append(cell)
//        cell.food.quantity = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else{
            fatalError("Unexpected destination VC")
        }
        let food = foods[indexPath.row]
        destinationVC.food = food
		destinationVC.metaLocation = metaLocation
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == foods.count - 1 && page < totalPage {
            if isSearching {
                searchMoreFood(isAddress: AreaFilter.shared.isAddress)
            } else {
                getMoreFoods(isAddress: AreaFilter.shared.isAddress)
            }
            
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            activityIndicator.startAnimating()
            
            tableView.tableFooterView = activityIndicator
        if !isSearching{
			if indexPath.row == foods.count - 1 && page < totalPage{
                getMoreFoods(isAddress: AreaFilter.shared.isAddress)

                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.color = UIColor.colorPrimary
                activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                activityIndicator.startAnimating()

                tableView.tableFooterView = activityIndicator
            }
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
//        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCollectionViewCell", for: indexPath) as? RecommendationCollectionViewCell else{
            fatalError("Unexpected CollectionViewCell")
        }
        
        let food = recommendedFoods[indexPath.row]
        cell.food = food
        
        return cell
        
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
