//
//  CartViewController.swift
//  Walayem
//
//  Created by Inception on 6/15/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import DatePickerDialog

protocol CartViewDelegate {
    func refreshTableViewCell()
}


class CartViewController: UIViewController, CartFoodCellDelegate, CartFoodHeaderDelegate, CartFoodFooterDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var addressDetailLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var orderSummaryIcon: UIImageView!
    @IBOutlet weak var summaryIcon: UIImageView!
    @IBOutlet weak var paymentIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var orderForLabel: UILabel!
    @IBOutlet weak var orderView: UIView!
    
    var delegate: CartViewDelegate? = nil
    
    let db = DatabaseHandler()
    var user: User?
    var addressList = [Address]()
    var selectedAddress: Address?
    
    struct CartItem{
        var opened: Bool!
        var chef: Chef!
        var note: String!
    }
    var cartItems = [CartItem]()
    
    // MARK: Actions
    
    @IBAction func unwindToAddressList(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ChooseAddressTableViewController, let selectedAddress = sourceVC.selectedAddress{
            self.selectedAddress = selectedAddress
            self.setAddress()
        }
    }
    
    @IBAction func selectAddress(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "SelectAddressSegue", sender: self)
    }
    
    
    @IBAction func addAddress(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let addressVC = storyboard.instantiateViewController(withIdentifier: "AddressTableVC") as? AddressTableViewController else{
            fatalError("Unexpected ViewController")
        }
        addressVC.partnerId = user?.partner_id
        navigationController?.pushViewController(addressVC, animated: true)
    }
    
    @IBAction func placeOrder(_ sender: UIButton) {
        let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        if(session == nil)
        {
            onSessionExpired()
        }
        else
        {
            if selectedAddress == nil {
                        let alert = UIAlertController(title: "", message: "Add address before placing an order", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Select Address", style: .default, handler: { (action) in
                            self.performSegue(withIdentifier: "SelectAddressSegue", sender: self)
                        }))
                        alert.addAction(UIAlertAction(title: "Add Address", style: .destructive, handler: { (action) in
                            self.addAddress(UIButton())
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        if let popoverController = alert.popoverPresentationController {
                            popoverController.sourceView = sender
                            popoverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
                            popoverController.permittedArrowDirections = [.down]
                        }
                        self.present(alert, animated: true, completion: nil)
                        return
                    }else if user!.phone!.isEmpty{
                        let alert = UIAlertController(title: "", message: "You need to add your phone number before placing an order", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { (action) in
                            let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)
                            guard let profileVC = storyboard.instantiateViewController(withIdentifier: "updateProfileVC") as? UpdateProfileViewController else{
                                fatalError("Unexpected ViewController")
                            }
            //                guard let profileVC = UIStoryboard(name: "EditProfile", bundle: Bundle.main).instantiateInitialViewController() as? UpdateProfileViewController else {
            //                    fatalError("Unexpected view controller")
            //                }
                        
                            profileVC.user = self.user
                            self.navigationController?.pushViewController(profileVC, animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        if let popoverController = alert.popoverPresentationController {
                            popoverController.sourceView = sender
                            popoverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
                            popoverController.permittedArrowDirections = [.down]
                        }
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let progressAlert = showProgressAlert()
                    var orderItems = [Any]()
                    for item in cartItems{
                        // add food details
                        var products = [Any]()
                        for food in item.chef.foods{
                            var dict = [String: Int]()
                            dict["product_id"] = food.id
                            dict["product_uom_qty"] = food.quantity
                            
                            products.append(dict)
                        }
                        // add chef details
                        var dict = [String: Any]()
                        dict["chef_id"] = item.chef.id
                        dict["note"] = item.note
                        dict["products"] = products
                        
                        orderItems.append(dict)
                    }
                    
                    var params: [String: Any] = ["partner_id": user?.partner_id as Any,
                                                 "address_id": selectedAddress!.id,
                                                 "orders": orderItems]
                    let orderType = UserDefaults.standard.string(forKey: "OrderType") ?? "asap"
                    params.updateValue(orderType, forKey: "order_type")
                    
                    print("order type-->"+orderType)
                    
                    if(orderType == "future"){
                        let orderDate = UserDefaults.standard.string(forKey: "OrderDate") ?? ""
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.date(from: orderDate)
                        
                        let dateTimeFormatter = DateFormatter()
                        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dateTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        let date_time_str = dateTimeFormatter.string(from: date!)
                        params.updateValue(date_time_str, forKey: "order_for")
                    }
                    
                    RestClient().request(WalayemApi.placeOrder, params) { (result, error) in
                        progressAlert.dismiss(animated: true, completion: {
                            if error != nil{
                                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                                self.showAlert(title: "Error", msg: errmsg)
                                return
                            }
                            let value = result!["result"] as! [String: Any]
                            let msg = value["message"] as! String
                            if let status = value["status"] as? Int, status == 0{
                                self.showAlert(title: "Error", msg: msg)
                                return
                            }
                            
                            self.clearCartItems()
                            let records = value["orders"] as! [Any]
                            guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "OrderSuccessVC") as? OrderSuccessViewController else {
                                fatalError("Unexpected destiation view controller")
                            }
                            destinationVC.orders = records
                            self.present(destinationVC, animated: true, completion: nil)
                        })
                    }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        Utils.setupNavigationBar(nav: self.navigationController!)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.orderView.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonTitle) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
        
        updateButtonTitle()

    }
    
    @objc func updateButtonTitle() {
        
        let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        if(session == nil)
        {
            self.orderButton.setTitle("Login to Order", for: .normal)
        }
        else
        {
            self.orderButton.setTitle("Place Order", for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        user = User().getUserDefaults()
        getCartItems()
        getAddress()
        
        if (delegate != nil){
            
            delegate?.refreshTableViewCell()
        }
        
        let orderType = UserDefaults.standard.string(forKey: "OrderType") ?? "asap"
        
        if(orderType == "future"){
            let orderDate = UserDefaults.standard.string(forKey: "OrderDate") ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: orderDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy hh:mm aa"
            let date_str = dateFormatter.string(from: date!)
            orderForLabel.text = "\(date_str)"
            
            let calendar = NSCalendar.current
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm aa"
            
            let time_str = timeFormatter.string(from: date!)
        
            if calendar.isDateInToday(date!) {
                orderForLabel.text = "today at \(time_str)"
            }
            else if calendar.isDateInTomorrow(date!) {
                orderForLabel.text = "tomorrow at \(time_str)"
            }
            
        }else{
            orderForLabel.text = "Delivery as soon as possible"
        }
                
    }

    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want       
        
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
        
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", startTime: startTime, endTime: endTime, minimumDate: date , datePickerMode: .dateAndTime) {
            (date) -> Void in
            if let dt = date {
//                let thisDate = Date()
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
                
                self.orderForLabel.text = "\(date_str) at \(time_str)"
            }
        }
        
    }
    // MARK: Private methods
    
    private func setViews(){
        orderButton.layer.cornerRadius = 15
        orderButton.layer.masksToBounds = true
        
        orderSummaryIcon.tintColor = UIColor.peach
        summaryIcon.tintColor = UIColor.seafoamBlue
        paymentIcon.tintColor = UIColor.babyBlue
        addressIcon.tintColor = UIColor.rosa
        
        
//        let prefix = UILabel(frame: CGRect(x: 0, y:0, width: 10, height: 20))
//        prefix.text = "*"
//        prefix.sizeToFit()
//        prefix.textColor = UIColor.rosa
//
//        subjectToDeliveryLabel.addSubview(prefix)
        
        let headerNib = UINib(nibName: "CartFoodHeaderCell", bundle: .main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CartFoodHeaderCell")
        tableView.register(CartFoodFooterCell.self, forHeaderFooterViewReuseIdentifier: "CartFoodFooterCell")
    }
    
    @objc private func keyboardWillShow(notification: Notification){
        if let userInfo = notification.userInfo{
            guard let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{
                fatalError("Cannot convert to CGRect")
            }
            print(keyboardFrame.height)
            
            do
            {
                let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.height - self.tabBarController!.tabBar.frame.height, 0.0);
                UIView.animate(withDuration: 0.5) {
                    self.tableView.contentInset = contentInsets;
                    self.tableView.scrollIndicatorInsets = contentInsets;
                }
            }
            catch
            {
            
            }

        }
    }
    
    @objc private func keyboardWillHide(notification: Notification){
        let contentInsets = UIEdgeInsets()
        tableView.contentInset = contentInsets;
        tableView.scrollIndicatorInsets = contentInsets;
    }
    
    private func getCartItems(){
        let foods = db.getFoods()
//        validateFoods(foods: foods) { (success) in
            self.cartItems.removeAll()
            let chefs = self.db.getCartItems()
            if chefs.count == 0{
                self.changeView(true)
            }else{
                self.changeView(false)
                for chef in chefs{
                    let cartItem = CartItem(opened: true, chef: chef, note: "")
                    self.cartItems.append(cartItem)
                }
                self.calculateCost()
            }
            self.tableView.reloadData()
//        }
    }
    
    private func validateFoods(foods: [Food], completion: @escaping(Bool) -> Void){
//        let foodIds = foods.map { (food) -> Int in
//            return food.id
//        }
//        let domain = [["id", "in", foodIds], ["paused", "=", true], ["active", "=", false]]
//        let fields = ["id"]
//
//        OdooClient.sharedInstance().searchRead(model: "product.template", domain: domain, fields: fields, offset: 0, limit: 100, order: "name ASC") { (result, error) in
//            if let _ = error{
//                completion(false)
//                return
//            }
//            let records = result!["records"] as! [Any]
//            for record in records{
//                guard let record = record as? [String: Any] else {
//                    break;
//                }
//                let id = record["id"] as! Int
//                let _ = self.db.removeFood(foodId: id)
//            }
//            completion(true)
//        }
        
        let params: [String: Any] = [:]
        RestClient().request(WalayemApi.getActiveFoodIds, params) { (result, error) in
            if error != nil {
                _ = error?.userInfo[NSLocalizedDescriptionKey] as! String
                //error here
                completion(false)
                return
            }
            let value = result!["result"] as! [String: Any]
            if let status = value["status"] as? Int, status == 0 {
                //status false
                 completion(false)
                return
            }
            let data = value["data"] as! [Int]
//            print("active ids--->\(data)")
            for food in foods{
//                print("food id:\(food.id) is in list?")
                if(data.contains(food.id ?? 0)){
//                    print("yes")
                }else{
//                    print("no so delete it")
                    let _ = self.db.removeFood(foodId: food.id ?? 0)
                }
            }
            completion(true)
        }
    }
    
    private func getAddress(){
        let params: [String: Int] = ["partner_id": user!.partner_id!]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        RestClient().request(WalayemApi.address, params) { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let value = result!["result"] as! [String: Any]
            self.addressList.removeAll()
            let records = value["addresses"] as! [Any]
            if records.count == 0{
                self.addressView.isHidden = true
                return
            }
            self.addressView.isHidden = false
            for record in records{
                let address = Address(record: record as! [String : Any])
                self.addressList.append(address)
            }
            if self.selectedAddress == nil{
                self.selectedAddress = self.addressList[0]
                self.setAddress()
            }
            
            let selectedAddressId = UserDefaults.standard.integer(forKey: "OrderAddress") as Int?
            if(selectedAddressId != nil){
                for addr in self.addressList{
                    if(addr.id == selectedAddressId){
                        self.selectedAddress = addr
                        self.setAddress()
                    }
                }
            }
            
        }
    }
    
    private func setAddress(){
        addressNameLabel.text = selectedAddress?.name
        addressDetailLabel.text = selectedAddress!.city + ", " + selectedAddress!.street + ", " + selectedAddress!.extra
    }
    
    private func calculateCost(){
        var totalCost: Double = 0.0
        for item in cartItems{
            for food in item.chef.foods{
                totalCost += Double(food.quantity) * (food.price ?? 0.0)
            }
        }
        
        subtotalLabel.text = "AED \(totalCost)"
        discountLabel.text = "AED 0.0"
        totalLabel.text = "AED \(totalCost)"
    }
    
    private func changeView(_ isEmpty: Bool){
        if isEmpty{
            tableView.tableFooterView?.isHidden = true
            tableView.tableHeaderView?.isHidden = true
            tableView.backgroundView = emptyView
        }else{
            tableView.tableFooterView?.isHidden = false
            tableView.tableHeaderView?.isHidden = false
            tableView.backgroundView = nil
        }
    }
    
    private func clearCartItems(){
        db.clearDatabase()
        updateBadge()
        cartItems.removeAll()
        tableView.reloadData()
        changeView(true)
    }
    
    private func showProgressAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Placing order", message: "Please wait...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateBadge(){
        if let tabItem = tabBarController?.tabBar.items?[3]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = db.getFoodsCount()
        }
    }
    
    
    // MARK: CartFoodHeader delegate
    
    func toggleSection(section: Int) {
        if(cartItems.count <= section)
        {
            return
        }
        
        
        
        cartItems[section].opened = !cartItems[section].opened!
        
        tableView.reloadSections([section], with: .automatic)
    }
    
    // MARK: CartFoodFooter delegate
    
    func updateNote(sender: UITextField, section: Int) {
//        cartItems[section].note = sender.text
    }
    
    
    // MARK: CartFoodCell delegate
    
    func didTapAddItem(sender: CartFoodTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {
            fatalError("Cell does not exist")
        }
        let food = cartItems[indexPath.section].chef.foods[indexPath.row]
        if db.addQuantity(foodId: food.id ?? 0){
            print("Quantity added---- on Cart screen")
            calculateCost()
        }
        
    }
    
    
    
    func didTapRemoveItem(sender: CartFoodTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else{
            fatalError("Cell doesnot exist")
        }
        let food = cartItems[indexPath.section].chef.foods[indexPath.row]
        if food.quantity == 0{
            if db.removeFood(foodId: food.id ?? 0){
                cartItems[indexPath.section].chef.foods.remove(at: indexPath.row)
                if cartItems[indexPath.section].chef.foods.count == 0{
                    cartItems.remove(at: indexPath.section)
                    tableView.deleteSections([indexPath.section], with: .fade)
                }else{
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
                if cartItems.count == 0{
                    changeView(true)
                }
                updateBadge()
            }
        }else{
            if db.subtractQuantity(foodId: food.id ?? 0){
                print("Quantity Subtracted")
            }
        }
        calculateCost()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "SelectAddressSegue":
            let navigationVC = segue.destination as! UINavigationController
            guard let destinationVC = navigationVC.topViewController as? ChooseAddressTableViewController else {
                fatalError("Unexpected view controller")
            }
            destinationVC.addressList = addressList
        default:
            fatalError("Invalid segue")
        }
    }

}

extension CartViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cartItems[section].opened!{
            return cartItems[section].chef.foods.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CartFoodHeaderCell") as? CartFoodHeaderCell else {
            fatalError("Unexpected header view")
        }
        headerView.delegate = self
        headerView.section = section
        
        let chef = cartItems[section].chef
        headerView.chef = chef
        
        if cartItems[section].opened{
            UIView.animate(withDuration: 1) {
                headerView.caretIcon.transform = CGAffineTransform(rotationAngle: .pi/2)
            }
        }else{
            UIView.animate(withDuration: 1) {
                headerView.caretIcon.transform = CGAffineTransform.identity
            }
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartFoodCell", for: indexPath) as? CartFoodTableViewCell else {
            fatalError("Unexpected cell")
        }
        cell.delegate = self
        let food = cartItems[indexPath.section].chef.foods[indexPath.row]
        cell.food = food
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CartFoodFooterCell") as? CartFoodFooterCell else {
            fatalError("Unexpected footer view")
        }
        footerView.delegate = self
        footerView.section = section
        footerView.foods = cartItems[section].chef.foods
        
        footerView.update()
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let orderType = UserDefaults.standard.string(forKey: "OrderType") ?? "asap"
        
        if(orderType == "asap"){
            return 80
        }
        
        return 60
    }
}
