//
//  ChefTableViewController.swift
//  Walayem
//
//  Created by MAC on 4/19/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log
import DatePickerDialog

class ChefTableViewController: BaseTabViewController, ChefCellDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var headerView: UIView!
	
    var activityIndicator: UIActivityIndicatorView!
    var dateC = Date()
    var dateN = Date()
    
    var selectedTags = [Tag]()
    var selectedCuisines = [Cuisine]()
    var chefs = [Chef]()
    var page: Int = 0
    var totalPage: Int = 0
    var isLoading = false
    var partnerId: Int?
    var discover = DiscoverTableViewController()
    var addressList = [Address]()
    var isSearching = false
    
    @IBOutlet weak var timePickerButton: UIButton!
    @IBOutlet weak var locationPickButton: UIButton!
    
    var spinnerView = UIView()
        
     func showSpinner(){
         spinnerView = getSpinnerView()
         self.view.addSubview(spinnerView)
     }
    
     func hideSpinner(){
         spinnerView.removeFromSuperview()
     }
        
    
    @IBAction func locationPickClicked(_ sender: Any) {
//        if ((StaticLinker.discoverViewController?.addressList) != nil){
//
//            let alert = UIAlertController(title: "", message: "Select an address", preferredStyle: .actionSheet)
//            for address in (StaticLinker.discoverViewController?.addressList)!
//            {
//                alert.addAction(UIAlertAction(title: address.name, style: .default, handler: { (action) in
//                    self.locationPickButton.setTitle(address.name, for: .normal)
//
//                    if(StaticLinker.discoverViewController != nil){
//                        StaticLinker.discoverViewController?.locationPickButton.setTitle(address.name, for: .normal)
//                    }
//                    let userDefaults = UserDefaults.standard
//                    userDefaults.set(address.id, forKey: "OrderAddress")
//                    userDefaults.synchronize()
//                }))
//            }
//            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
//                self.navigationController?.popViewController(animated: true)
//            }))
//
//            if((StaticLinker.discoverViewController?.addressList.count)! > 0){
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//        else{
//            self.showAlertBeforeLogin(message: "Please login to add Address...!")
//        }
        
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
    
    
    @IBAction func onTimePickerClicked(_ sender: Any) {
        
//        let alert = UIAlertController(title: "", message: "When do you want your meal?", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "ASAP", style: .default, handler: { (action) in
//            self.timePickerButton.setTitle("ASAP", for: .normal)
//            let userDefaults = UserDefaults.standard
//            userDefaults.set("asap", forKey: "OrderType")
//            userDefaults.synchronize()
//        }))
//        alert.addAction(UIAlertAction(title: "Custom time", style: .default, handler: { (action) in
             self.datePickerTapped()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
//            self.navigationController?.popViewController(animated: true)
//        }))
//
//        self.present(alert, animated: true, completion: nil)
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
//            self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
    //        self.datePickerButton.setTitle("ASAP", for: .normal)
            
        }
        
    
    
//    @IBAction func onTimePickerClicked(_ sender: Any) {
//             self.datePickerTapped()
//    }
    
    
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
       
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: UserDefaultsKeys.ORDER_FIRST_TIME)
            userDefaults.synchronize()
        }
                
                
        
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", startTime: startTime, endTime: endTime, minimumDate: date, datePickerMode: .dateAndTime) {
            (date) -> Void in
            if let dt = date {
                let thisDate = Date()
                if thisDate > dt{
                    self.timePickerButton.setTitle("ASAP", for: .normal)
                    let userDefaults = UserDefaults.standard
                    userDefaults.set("asap", forKey: "OrderType")
                    userDefaults.synchronize()
                   return
                }
                let calendar = NSCalendar.current
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd yyyy"
                
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
                
                if(StaticLinker.discoverViewController != nil){
                    StaticLinker.discoverViewController?.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
                }
                self.timePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
            }
        }
    }
    // MARK: Actions
    
    @IBAction func unwindFromFilterVC(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? FilterViewController{
            self.selectedTags = sourceVC.selectedTags!
            self.selectedCuisines = sourceVC.selectedCuisines!
            let badgeNumber = selectedTags.count + selectedCuisines.count
            
            if badgeNumber > 0{
                searchChef()
                filterBarButton.addBadge(number: badgeNumber, withOffset: CGPoint(x: 0, y: 5), andColor: UIColor.colorPrimary, andFilled: true)
            }else {
                getChefs()
                filterBarButton.removeBadge()
            }
        }
    }
    
    @IBAction func showFilter(_ sender: UIBarButtonItem) {
        guard let filterVC = UIStoryboard(name: "Discover", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterVC") as? FilterViewController else {
            fatalError("Unexpected view controller")
        }
        filterVC.selectedTags = selectedTags
        filterVC.selectedCuisines = selectedCuisines
        present(filterVC, animated: true, completion: nil)
    }
    
    private func getAddress(){
        let params = ["partner_id": partnerId!]
        
        RestClient().request(WalayemApi.address, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                if errmsg == OdooClient.SESSION_EXPIRED{
//                    self.onSessionExpired()
                }
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            self.addressList.removeAll()
            
            let records = value["addresses"] as? [Any]
            if records == nil || records!.count == 0 {
                return
            }
            for record in records! {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partnerId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
        setupSearch()
        setupRefreshControl()
        tableView.delegate = self
        tableView.dataSource = self
        getAddress()
        Utils.setupNavigationBar(nav: self.navigationController!)
        showActivityIndicator()
        showSpinner()
        getChefs()
        StaticLinker.chefViewController = self
        initialCustomDate()
        
        if(StaticLinker.discoverViewController != nil){
            let str = StaticLinker.discoverViewController?.datePickerButton.titleLabel?.text
            self.timePickerButton.setTitle(str, for: .normal)
            let str_loc = StaticLinker.discoverViewController?.locationPickButton.titleLabel?.text
            self.locationPickButton.setTitle(str_loc, for: .normal)
        }
               
        NotificationCenter.default.addObserver(self, selector: #selector(updateFav) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)

		if let selectedIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        let selectedAddressId = UserDefaults.standard.integer(forKey: "OrderAddress") as Int?
        
//        do
//        {
            if(selectedAddressId != nil){
                if((StaticLinker.discoverViewController) != nil)
                {
                    for addr in (StaticLinker.discoverViewController?.addressList)!{
                        if(addr.id == selectedAddressId){
                            locationPickButton.setTitle(addr.name, for: .normal)
                        }
                    }
                }
            }
//        }
//        catch {
//
//        }
        
        tableView.reloadData()
        
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
    
    override func deliveryLocationSelected(_ location: Location, title: String) {
        super.deliveryLocationSelected(location, title: title)
        refreshData(sender: UIRefreshControl())
    }
    
    // MARK: Private methods
    
    private func setupSearch(){
        guard let searchResultController = storyboard?.instantiateViewController(withIdentifier: "ChefSearchResultsVCId") as? ChefSearchResultsViewController else {
            fatalError("Unexpected ViewController")
        }
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchResultsUpdater = searchResultController
        searchController.searchBar.placeholder = "Search for chefs"

		if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
                navigationItem.standardAppearance = appearance
                navigationItem.scrollEdgeAppearance = appearance
            
        } else {
            // Fallback on earlier versions
        }
        searchController.obscuresBackgroundDuringPresentation = false

		searchController.searchBar.tintColor = UIColor.colorPrimary
        if #available(iOS 11.0, *){
            navigationItem.searchController = searchController
        }else{
            navigationItem.titleView = searchController.searchBar
        }
        searchController.searchBar.setShowsCancelButton(false, animated: true)
        searchController.searchBar.showsCancelButton = false
		tableView.tableHeaderView = searchController.searchBar
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
        selectedTags.removeAll()
        selectedCuisines.removeAll()
        filterBarButton.removeBadge()
        isSearching = false
		isLoading = false
        getChefs()
    }
    
    private func getChefs(){
        if isLoading{
            return
        }
        var params = AreaFilter.shared.coverageParams
        params["page"] = 1
		params["filter_by"] = "location"
		
        isLoading = true
		
        RestClient().request(WalayemApi.discoverChef, params) { (result, error) in
            self.hideSpinner()
            self.hideActivityIndicator()
            self.tableView.refreshControl?.endRefreshing()
            self.isLoading = false
            
            if let error = error{
                self.handleNetworkError(error)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.chefs.removeAll()
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
				let rec = record as! [String : Any]
                let chef = Chef(record: rec, name: rec["chef_name"] as? String ?? "")
//                self.chefs.append(chef)
                if !self.chefs.contains(chef){
                   self.chefs.append(chef)
               }
            }
            self.tableView.reloadData()
        }
    }
    
    private func getMoreChefs(){
        if (isLoading) {
            return
        }
        var params = AreaFilter.shared.coverageParams
        params["page"] = page + 1
		params["getChefs"] = "location"
        isLoading = true
        RestClient().request(WalayemApi.discoverChef, params) { [weak self] (result, error) in
			
			guard let self  = self else { return }
			
            self.tableView.tableFooterView = nil
			if (self.isLoading || self.isSearching){
				return
        }
			let params : [String: Int] = ["page": self.page + 1]
			self.isLoading = true
        RestClient().request(WalayemApi.discoverChef, params) { (result, error) in
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
				let rec = record as! [String : Any]
				let chef = Chef(record: rec, name: rec["chef_name"] as? String ?? "")
                if !self.chefs.contains(chef){
                    self.chefs.append(chef)
                }
            }
            self.tableView.reloadData()
        }
    }
}
    
//    private func searchChef() {
//        isSearching = true
//            self.tableView.tableFooterView = nil
//    }
    
    // search for cuisine and tags
    private func searchChef(){
        
        isSearching = true
        
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            (tag.id ?? 0)
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            (cuisine.id ?? 0)
        }
        var params = AreaFilter.shared.coverageParams
        params["search"] = false
        params["food_tags"] = tagIds
        params["cuisine"] = cuisineIds
        params["page"] = 1

		RestClient().request(WalayemApi.searchChef, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0{
                return
            }
            self.chefs.removeAll()
            self.page = value["current_page"] as? Int ?? 0
            self.totalPage = value["total_pages"] as? Int ?? 0
            let records = value["data"] as! [Any]
            for record in records{
				let rec = record as! [String : Any]
				let chef = Chef(record: rec, name: rec["chef_name"] as? String ?? "")
                self.chefs.append(chef)
            }
            self.tableView.reloadData()
        }
    }
    
    private func searchMoreChefs() {
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            (tag.id ?? 0)
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            (cuisine.id ?? 0)
        }
        var params = AreaFilter.shared.coverageParams
        params["search"] = false
        params["food_tags"] = tagIds
        params["cuisine"] = cuisineIds
        params["page"] = self.page + 1
        RestClient().request(WalayemApi.searchChef, params) { (result, error) in
            self.tableView.tableFooterView = nil
            if error != nil {
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
				let rec = record as! [String : Any]
				let chef = Chef(record: rec, name: rec["chef_name"] as? String ?? "")
				if !self.chefs.contains(chef){
                    self.chefs.append(chef)
                }
            }
            self.tableView.reloadData()
        }
    }
    

	func foodSelected(_ food: Food){
        let storyBoard = UIStoryboard(name: "Discover", bundle: nil)
        guard let foodDetailVC = storyBoard.instantiateViewController(withIdentifier: "FoodDetailVC") as? FoodDetailViewController else {
            fatalError("Unexpected viewController")
        }
        foodDetailVC.food = food
        navigationController?.pushViewController(foodDetailVC, animated: true)
    }

//    private func handleNetworkError(_ error: NSError){
//        let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
//        if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
//            let alert = UIAlertController(title: "Cannot get Chefs", message: errmsg, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }else if errmsg == OdooClient.SESSION_EXPIRED{
//            self.onSessionExpired()
//        }
//    }
    
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
    
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        activityIndicator.color = UIColor.colorPrimary
        tableView.separatorStyle = .none
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator(){
        self.activityIndicator?.stopAnimating()
        self.tableView.separatorStyle = .singleLine
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "FavChefTableVCSegue":
            os_log("Favourite chef segue", log: .default, type: .debug)
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

extension ChefTableViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
       // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefTableViewCell", for: indexPath) as? ChefTableViewCell else{
            fatalError("Unexpected tableViewCell")
        }
        let chef = chefs[indexPath.row]
        cell.chef = chef
        cell.delegate = self
        cell.chefTableVC = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == chefs.count - 1 && page < totalPage {
            if isSearching {
                searchMoreChefs()
            } else {
                getMoreChefs()
            }
            
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            activityIndicator.startAnimating()
            
            tableView.tableFooterView = activityIndicator
        }
    }
}

extension ChefTableViewController: UISearchResultsUpdating{
    
    
    func updateSearchResults(for searchController: UISearchController) {

        dateC = Date()
        let calendar = Calendar.current
        dateN = calendar.date(byAdding: .second, value: 5, to: dateC)!
        
        if searchController.isActive{
            
        let sb = searchController.searchBar
        let searchQuery = sb.text!
                  
      
      var doSearch = false
      
        if searchQuery.count >= 1 {
                doSearch = true
        }
      
        if doSearch{
                let params: [String: Any] = ["search": true, "search_keyword": sb.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""]
                RestClient().request(WalayemApi.searchChef, params) { (result, error) in
                        if error != nil{
                            let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                            print (errmsg)
                            return
                        }
                        let value = result!["result"] as! [String: Any]
                        if let status = value["status"] as? Int, status == 0{
                            return
                        }
                        self.chefs.removeAll()
                        let records = value["data"] as! [Any]
                        for record in records{
							let rec = record as! [String : Any]
							let chef = Chef(record: rec, name: rec["chef_name"] as? String ?? "")
                            self.chefs.append(chef)
                        }
                        self.tableView.reloadData()
                    }
            }else{
            
            }
        }
    }
    
}
