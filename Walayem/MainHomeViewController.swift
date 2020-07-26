//
//  MainHomeViewController.swift
//  Walayem
//
//  Created by Hafiza Seemab on 2/3/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class MainHomeViewController: BaseTabViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mActivityIndicator: UIActivityIndicatorView!
    
    var partnerId: Int?
    var todays_meals = [PromotedItem]()
    var bestSellers = [PromotedItem]()
    var recommendedMeals = [PromotedItem]()
    var mealsURLs = [URL]()
    var recommendMealURLs = [URL]()
    var cuisines = [Cuisine]()
    var selectedCuisine: Cuisine?
    var foods = [Food]()
    //	var locationWrapper: LocationWrapper?
    //	var locationManager: CLLocationManager?
    
    let bookmarks = ["Recommended", "Meals of the day", "Cuisines", "Categories"]
    //    let bookmarks = ["Recommended", "Ramadan meals", "Cuisines", "Categories"]
    //    let bookmarks = ["مختارات السحور","رمضانيات", "Cuisines", "Categories"]
    
    
    var bookmarkImages: [UIImage] = [
        UIImage(named: "bookmark.jpg")!,
        //        UIImage(named: "moon.png")!,
        UIImage(named: "fire.jpg")!,
        UIImage(named: "cuisine_green.png")!,
        UIImage(named: "bookmark.jpeg")!,
        UIImage(named: "bookmark.jpg")!
    ]
    
    var activityIndicator: UIActivityIndicatorView!
    var spinnerView = UIView()
    var remoteConfigFetcher: RemoteConfigFetcher?
    
    func showSpinner(){
        spinnerView = getSpinnerView()
        self.view.addSubview(spinnerView)
    }
    
    func hideSpinner(){
        spinnerView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //		locationManager = CLLocationManager()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        //		locationWrapper = LocationWrapper(locationDelegate: self, vc: self)
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
//        if(StaticLinker.chefViewController != nil && StaticLinker.chefViewController?.timePickerButton != nil){
//            StaticLinker.chefViewController?.timePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
//        }
        //            self.datePickerButton.setTitle("\(date_str) at \(time_str)", for: .normal)
        //        self.datePickerButton.setTitle("ASAP", for: .normal)
        
    }
    
    
    @objc func handleTapAnimation(){
        print("handleTapAnimation")
    }
    
    override func deliveryLocationSelected(_ location: Location?, title: String) {
        super.deliveryLocationSelected(location, title: title)
        refreshData(sender: UIRefreshControl())
    }
    
    private func getPromoted(isAddress: Bool){
        var params = [String: Any]()
        if isAddress {
            params = AreaFilter.shared.addressParams
            params["filter_by"] = "address"
        } else {
            params = AreaFilter.shared.areaParams
            params["filter_by"] = "area"
        }
        params["partner_id"] = User().getUserDefaults().partner_id ?? 0//partnerId ?? 0
        //		params["filter_by"] = "area"//"location"
        
        RestClient().requestPromotedApi(WalayemApi.homeRecommendation, params, self) { (result, error) in
            self.tableView.refreshControl?.endRefreshing()
            self.mActivityIndicator.stopAnimating()
            self.hideSpinner()
            
            if(result != nil){
                
                if (result == nil || result!["result"] == nil) {
                    if result!["error"] != nil{
                        self.showSorryAlertWithMessage(result!["error"] as! String)
                    }
                    return
                }
                
                if result!["result"] != nil {
                    let data = result!["result"] as! [String: Any]
                    let status_api = data["status"] as? Int
                    
                    if let error = error{
                        self.handleNetworkError(error)
                        return
                    }
                    else if let status = status_api, status == 0{
                        print("Status Value------------->\(status)")
                        return
                    }else{
                        self.recommendedMeals.removeAll()
                        self.todays_meals.removeAll()
                        self.mealsURLs.removeAll()
                        self.recommendMealURLs.removeAll()
                        
                        if let best_sellers = data["best_sellers"] as? [Any]{
                            for best_seller in best_sellers{
                                let best_seller = PromotedItem(records: best_seller as! [String : Any])
                                self.bestSellers.append(best_seller)
                            }
                        }
                        if let recommendedMeals = data["recommended"] as? [Any]{
                            for recommended in recommendedMeals{
                                let recommend = PromotedItem(records: recommended as! [String : Any])
                                self.recommendedMeals.append(recommend)
                                
                                let id = recommend.item_details?.id
                                let url = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id ?? 0)/image")
                                self.recommendMealURLs.append(url!)
                                
                            }
                        }
                        if let todaysMeals = data["todays_meals"] as? [Any]{
                            for meal in todaysMeals {
                                let todays_meal = PromotedItem(records: meal as! [String : Any])
                                self.todays_meals.append(todays_meal)
                                let id = todays_meal.item_details?.id
                                let url = URL(string: "\(WalayemApi.BASE_URL)/walayem/image/product.template/\(id ?? 0)/image")
                                self.mealsURLs.append(url!)
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                    
                    if let advertisment_image = data["advertisment_image"] as? Int, advertisment_image == 0{
                        print(advertisment_image)
                        print("no image available")
                    }
                }
            }
            //            else{
            //                self.showSorryAlertWithMessage("No Internet Connection!")
            //            }
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
            showSorryAlertWithMessage("Some thing wrong in backend ...!")
        }
    }
    
    private func showSorryAlertWithMessage(_ msg: String){
        let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        getPromoted()
        
        //		if StaticLinker.shouldGetLocation {
        //			StaticLinker.shouldGetLocation = false
        //			locationWrapper = LocationWrapper(locationDelegate: self)
        //		}
        StaticLinker.selectedCuisine = nil
        remoteConfigFetcher = RemoteConfigFetcher(self)
    }
    
    private func getCuisines(){
        let fields = ["id", "name"]
        OdooClient.sharedInstance().searchRead(model: "product.cuisine", domain: [], fields: fields, offset: 0, limit: 500, order: "name ASC") { (result, error) in
            if error != nil{
                return
            }
            let records = result!["records"] as! [Any]
            for record in records{
                //                let tempRecord = record as! [String: Any]
                let tag = Cuisine(record: record as! [String : Any])
                //                let cuisine = Cuisine(id: tempRecord["id"] as? Int ?? 0, name: tempRecord["name"] as? String ?? "", img: "")
                self.cuisines.append(tag)
                //                self.cuisines.append(cuisine)
            }
            
            self.setSelectedCuisine()
        }
    }
    
    private func setSelectedCuisine(){
        for index in 0...cuisines.count - 1{
            if selectedCuisine?.id == cuisines[index].id{
                let indexPath = IndexPath(row: index, section: 0)
                break
            }
        }
    }
    
    @objc func didEnterForeground() {
        //		if StaticLinker.shouldGetLocation {
        //			StaticLinker.shouldGetLocation = false
        //			locationWrapper = LocationWrapper(locationDelegate: self, vc: self)
        //		}
        StaticLinker.selectedCuisine = nil
        remoteConfigFetcher = RemoteConfigFetcher(self)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func areaSelected(selectedAreaArray: [Int], areaName: String) {
        super.areaSelected(selectedAreaArray: selectedAreaArray, areaName: areaName)
        getPromoted(isAddress: AreaFilter.shared.isAddress)
    }
    
}

extension MainHomeViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
        getPromoted(isAddress: AreaFilter.shared.isAddress)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var collectionViewCellIdentifier = "cell1"
        
        if indexPath.row == 0 {
            collectionViewCellIdentifier = "recommendedCell0"
        }
        if indexPath.row == 1 {
            collectionViewCellIdentifier = "mealDayCell1"
        }
        if indexPath.row == 2 {
            collectionViewCellIdentifier = "cuisinesCell4"
        }
        if indexPath.row == 3 {
            collectionViewCellIdentifier = "tagCell"
        }
        
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell") as? HomeTableViewCell  else { fatalError("mainHomeTableViewCell") }
            
            cell.identifier = collectionViewCellIdentifier;
            cell.bookmarkText.text = self.bookmarks[indexPath.row]
            cell.bookmarkImage.image = self.bookmarkImages[indexPath.row]
            
            cell.recommendedMeals = self.recommendedMeals
            cell.recommendedImagesURLS = self.recommendMealURLs
            cell.todays_meals = self.todays_meals
            cell.mealImagesURLS = self.mealsURLs
            cell.bestSellers = self.bestSellers
            cell.navigationController = self.navigationController
            cell.cuisinesObj = self.cuisines
            cell.collectionView.reloadData()
            cell.selectionStyle = .none
            
            return cell
        }
            
            
            
        else if indexPath.row == 4 {
            guard let cell : HomeButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCell1") as? HomeButtonTableViewCell else { fatalError("mainHomeTableViewCell1") }
            
            cell.parent = self
            //            cell.button.shake()
            cell.selectionStyle = .none
            return cell
            
        }
        else if indexPath.row == 5 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCellLast") else { fatalError("mainHomeTableViewCellLast")  }
            cell.selectionStyle = .none
            
            let image = cell.viewWithTag(5000) as! UIImageView
            //            image.shake()
            
            let imageButton = cell.viewWithTag(5010) as! UIButton
            //            imageButton.shake()
            
            imageButton.addTarget(self, action:#selector(handleImageButton(_:)), for: .touchUpInside)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainHomeTableViewCellLast") else { fatalError("mainHomeTableViewCellLast")  }
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    
    
    
    @objc func browseMealsTapped(sender: UIButton){
        print("browse meals tapped!")
    }
    
    
    @objc func handleImageButton(_: UIButton){
        print("Image Add tapped!")
        StaticLinker.chefLoginFromHome = true
        
        
        if #available(iOS 13.0, *) {
            let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateViewController(identifier: "SignupViewController") as! SignupViewController
            self.present(viewController, animated: true, completion: nil)
        } else {
            let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true, completion: nil)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            if recommendedMeals.count > 0 {
                return 310
            }
            else{
                return 0
            }
            
        }
        if indexPath.row == 1 {
            if todays_meals.count > 0 {
                return 260
            }
            else{
                return 0
                
            }
            
            //            return 200
        }
        if indexPath.row == 2 {
            return 180
            
        }
        if indexPath.row == 4 {
            return 90
        }
        if indexPath.row == 3 {
            //            return 140
            return 0
        }
        return 90
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            var frame = cell.contentView.frame
            UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
                frame.origin.x = -80
                cell.contentView.frame = frame
            })
        }
        
        if indexPath.row == 5{
            var frame = cell.contentView.frame
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseIn, animations: {
                frame.origin.y = -50
                cell.contentView.frame = frame
            })
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

extension MainHomeViewController: LocationDelegate {
    
    func getLocation(location: Location, address: UserAddress, title: String) {
        AreaFilter.shared.setselectedLocation(location, title: title, userAddress: address)
        locationView.locationUpdated()
        
        getPromoted(isAddress: AreaFilter.shared.isAddress)
    }
    
    func locationPermissionDenied() {
        DLog(message: "Permission not available")
        //		locationManager?.requestAlwaysAuthorization()
        //		DispatchQueue.main.async {
        //			self.locationManager?.requestWhenInUseAuthorization()
        //		}
        
        //		locationWrapper?.checkLocationAvailability()
    }
    
}

extension MainHomeViewController: RemoteConfigProtocol {
    
    func fetched(data: RemoteConfigModel) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.showSpinner()
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            if (data.ios_prod_force_update_required && data.ios_min_prod_version > appVersion) || (data.ios_beta_force_update_required && data.ios_min_beta_version > appVersion) {
                let alert = UIAlertController(title: "App Update Available", message: "Please update the app to continue.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    if UIApplication.shared.canOpenURL(URL(string: data.ios_store_url)!) {
                        UIApplication.shared.open(URL(string: data.ios_store_url)!, options: [:], completionHandler: nil)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.setUpNormalFlow()
            }
        }
        
    }
    
    func setUpNormalFlow() {
        self.mActivityIndicator.stopAnimating()
        self.setupRefreshControl()
        self.getCuisines()
        self.initialCustomDate()
        if AreaFilter.shared.selectedArea == 0 && AreaFilter.shared.addressId == 0 {
            if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "AreaSelectionViewController") as? AreaSelectionViewController {
                vc.areaSelectionProtocol = self
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        } else {
            self.getPromoted(isAddress: AreaFilter.shared.isAddress)
            self.locationView.areaUpdated()
        }
        self.tableView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(self.handleTapAnimation)))
    }
    
}
