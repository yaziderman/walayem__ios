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

class ChefTableViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    var activityIndicator: UIActivityIndicatorView!
    
    var selectedTags = [Tag]()
    var selectedCuisines = [Cuisine]()
    var chefs = [Chef]()
    var page: Int = 0
    var totalPage: Int?
    var isLoading = false
    var discover = DiscoverTableViewController()
    
    @IBOutlet weak var timePickerButton: UIButton!
    @IBOutlet weak var locationPickButton: UIButton!
    @IBAction func locationPickClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Select an address", preferredStyle: .actionSheet)
        for address in (StaticLinker.discoverViewController?.addressList)!
        {
            alert.addAction(UIAlertAction(title: address.name, style: .default, handler: { (action) in
                self.locationPickButton.setTitle(address.name, for: .normal)
                
                if(StaticLinker.discoverViewController != nil){
                    StaticLinker.discoverViewController?.locationPickButton.setTitle(address.name, for: .normal)
                }
                let userDefaults = UserDefaults.standard
                userDefaults.set(address.id, forKey: "OrderAddress")
                userDefaults.synchronize()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        if((StaticLinker.discoverViewController?.addressList.count)! > 0){
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onTimePickerClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "When do you want your meal?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "ASAP", style: .default, handler: { (action) in
            self.timePickerButton.setTitle("ASAP", for: .normal)
            let userDefaults = UserDefaults.standard
            userDefaults.set("asap", forKey: "OrderType")
            userDefaults.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "Custom time", style: .default, handler: { (action) in
             self.datePickerTapped()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func datePickerTapped() {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearch()
        setupRefreshControl()
        tableView.delegate = self
        tableView.dataSource = self
        
//        let strNumber: NSString = "Today at 5pm to Address" as NSString
//        let range = (strNumber).range(of: "to")
//        let attribute = NSMutableAttributedString.init(string: strNumber as String)
//        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray , range: range)
//        scheduleButton.setAttributedTitle(attribute, for: .normal)
        Utils.setupNavigationBar(nav: self.navigationController!)
        showActivityIndicator()
        getChefs()
        StaticLinker.chefViewController = self
        
        if(StaticLinker.discoverViewController != nil){
            let str = StaticLinker.discoverViewController?.datePickerButton.titleLabel?.text
            self.timePickerButton.setTitle(str, for: .normal)
            let str_loc = StaticLinker.discoverViewController?.locationPickButton.titleLabel?.text
            self.locationPickButton.setTitle(str_loc, for: .normal)
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        let selectedAddressId = UserDefaults.standard.integer(forKey: "OrderAddress") as Int?
        if(selectedAddressId != nil){
            for addr in (StaticLinker.discoverViewController?.addressList)!{
                if(addr.id == selectedAddressId){
                    locationPickButton.setTitle(addr.name, for: .normal)
                }
            }
        }
    }

    // MARK: Private methods
    
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
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.colorPrimary
        if #available(iOS 11.0, *){
            navigationItem.searchController = searchController
        }else{
            tableView.tableHeaderView = searchController.searchBar
        }
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
        
        getChefs()
    }
    
    private func getChefs(){
        if isLoading{
            return
        }
        let params : [String: Int] = ["page": 1]
        isLoading = true
        RestClient().request(WalayemApi.discoverChef, params) { (result, error) in
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
            self.page = value["current_page"] as! Int
            self.totalPage = value["total_pages"] as? Int
            let records = value["data"] as! [Any]
            for record in records{
                let chef = Chef(record: record as! [String : Any])
                self.chefs.append(chef)
            }
            self.tableView.reloadData()
        }
    }
    
    private func getMoreChefs(){
        if isLoading{
            return
        }
        let params : [String: Int] = ["page": page + 1]
        isLoading = true
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
            self.page = value["current_page"] as! Int
            self.totalPage = value["total_pages"] as? Int
            let records = value["data"] as! [Any]
            for record in records{
                let chef = Chef(record: record as! [String : Any])
                self.chefs.append(chef)
            }
            self.tableView.reloadData()
            self.tableView.tableFooterView = nil
        }
    }
    
    private func searchChef(){
        let tagIds: [Int] = selectedTags.map { (tag) -> Int in
            tag.id
        }
        let cuisineIds: [Int] = selectedCuisines.map { (cuisine) -> Int in
            cuisine.id
        }
        let params: [String: Any] = ["search": false, "food_tags": tagIds, "cuisine": cuisineIds]
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
                let chef = Chef(record: record as! [String: Any])
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
    
    private func handleNetworkError(_ error: NSError){
        let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
        if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
            let alert = UIAlertController(title: "Cannot get Chefs", message: errmsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }else if errmsg == OdooClient.SESSION_EXPIRED{
            self.onSessionExpired()
        }
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.color = UIColor.colorPrimary
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
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
        // #warning Incomplete implementation, return the number of rows
        return chefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefTableViewCell", for: indexPath) as? ChefTableViewCell else{
            fatalError("Unexpected tableViewCell")
        }
        let chef = chefs[indexPath.row]
        cell.chef = chef
        cell.chefTableVC = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == chefs.count - 1 && page < totalPage!{
            getMoreChefs()
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            activityIndicator.startAnimating()
            
            tableView.tableFooterView = activityIndicator
        }
    }
    
}

extension ChefTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive{
            let sb = searchController.searchBar
            let searchQuery = sb.text!
            
            let params: [String: Any] = ["search": true, "search_keyword": searchQuery]
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
                    let chef = Chef(record: record as! [String: Any])
                    self.chefs.append(chef)
                }
                self.tableView.reloadData()
            }
        }else{
            getChefs()
        }
    }
    
}

