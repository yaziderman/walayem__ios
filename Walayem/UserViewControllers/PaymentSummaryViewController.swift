//
//  CartViewController.swift
//  Walayem
//
//  Created by Inception on 6/15/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import DatePickerDialog
import HandyUIKit

protocol PaymentSummaryViewDelegate {
	func refreshTableViewCell()
}

enum PaymentMethod {
    case cod
    case online
}

class PaymentSummaryViewController: UIViewController, CartFoodCellDelegate, CartFoodHeaderDelegate, CartFoodFooterDelegate {
	
	// MARK: Properties
	
    var subTotal : Double = 0
    var bigTotal : Double = 0
    var totalDeliveryCharge: Double?

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var subtotalLabel: UILabel!
	@IBOutlet weak var deliveryAmountLabel: UILabel!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var addressView: UIView!
	@IBOutlet weak var addressNameLabel: UILabel!
	@IBOutlet weak var addressDetailLabel: UILabel!
	@IBOutlet weak var orderButton: UIButton!
	@IBOutlet weak var addAddressButton: UIButton!
	@IBOutlet weak var emptyView: UIView!
	
	@IBOutlet weak var orderSummaryIcon: UIImageView!
	@IBOutlet weak var summaryIcon: UIImageView!
	@IBOutlet weak var paymentIcon: UIImageView!
	@IBOutlet weak var addressIcon: UIImageView!
	@IBOutlet weak var orderForLabel: UILabel!
	@IBOutlet weak var orderView: UIView!
	@IBOutlet weak var summaryDeliveryChargeLabel: UILabel!
	@IBOutlet weak var deliverySummaryLabel: UILabel!
	//  @IBOutlet weak var abuDhabiOnlyText: UILabel!
	//   @IBOutlet weak var contactUsBtn: UIButton!
	
    @IBOutlet weak var optionPickup: UIButton!
    @IBOutlet weak var optionDelivery: UIButton!

    var paymentMethod = PaymentMethod.online
    
    @IBOutlet weak var ivCheckCOD: UIImageView!
    @IBOutlet weak var ivCheckONLINE: UIImageView!

    var image_tick_on = UIImage(named: "tick_on")
    var image_tick_off = UIImage(named: "tick_off")
    
    var amount_subtotal = ""
    var amount_delivery = ""
    var amount_total = ""
    
    var chefName = ""
    var chefAddress = ""
    
    @IBOutlet weak var viewCOD: UIView!
    @IBOutlet weak var viewOnline: UIView!

    @IBOutlet weak var buttonChange: UIButton!

    @IBAction func proceedToPayment(){

        let progressAlert = showProgressAlert()
        var orderItems = [Any]()
        for item in cartItems {
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
            dict["delivery_cost"] = item.deliveryCost
            dict["note"] = item.note
            dict["products"] = products
            
            orderItems.append(dict)
        }
        
        var params: [String: Any] = [
            "partner_id": user!.partner_id as Any,
            "address_id": selectedAddress!.id,
            "orders": orderItems,
            "delivery_type": (self.orderType == .delivery) ? ("delivery") : ("pickup")
        ]
        
        if(self.paymentMethod == PaymentMethod.online){
            params["payment_type"] = "card"
        } 
        
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
        
        print(params.description)
        SwiftLoading().showLoading()
        print("WalayemApi.placeOrder",WalayemApi.placeOrder)
        RestClient().request(WalayemApi.placeOrder, params, self) { (result, error) in
            print("error____________________________",error)
            SwiftLoading().hideLoading()
            
            print("result______________________________________________",result)
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
                
                //self.clearCartItems()
                let records = value["orders"] as! [Any]
                
    //                                self.navigationController?.pushViewController(vc_summary, animated: true)
    //                                return
                
    //                                guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "OrderSuccessVC") as? OrderSuccessViewController else {
    //                                    fatalError("Unexpected destiation view controller")
    //                                }
    //                                destinationVC.orders = records
    //                                self.present(destinationVC, animated: true, completion: nil)
            })
            
        }
    }
    
    
    func renderPaymentButtonsAlpha(){
        let alphaOff : CGFloat = 1.0
        let alphaOn : CGFloat = 1.0
        
        if(self.orderType == OrderType.pickup){
            viewCOD.alpha = alphaOff
            viewOnline.alpha = alphaOff
        }else{
            viewCOD.alpha = alphaOn
            viewOnline.alpha = alphaOn
        }
    }
    
    func renderTotals(){
        print("renderTotals_____")
        self.subtotalLabel.text = self.amount_subtotal
        deliveryAmountLabel.text = (self.orderType == OrderType.pickup) ? ("AED 0") : (amount_delivery) 
        self.deliveryAmountLabel.textColor = .lightGray
        totalLabel.text = amount_total
        self.deliverySummaryLabel.text = "Total Delivery"
        
        if(self.orderType == .pickup){
            self.addressNameLabel.text = self.chefName
            self.addressDetailLabel.text = self.chefAddress
        }else{
            self.setAddress()
        }
        
    }
    
    func renderChecks(){
        ivCheckCOD.image = (self.paymentMethod == .cod) ? ( image_tick_on )  : ( image_tick_off )
        ivCheckONLINE.image = (self.paymentMethod == .cod) ? ( image_tick_off )  : ( image_tick_on )
    }
    
    @IBAction func didSelectCOD() {
        self.paymentMethod = .cod
        renderChecks()
    }
    
    @IBAction func didSelectOnline() {
        self.paymentMethod = .online
        renderChecks()
    }
    
    @IBOutlet weak var lblButtonCallToAction: UILabel!

    @IBAction func didChangeMethod() {
        self.orderType = (self.orderType == OrderType.pickup) ? (OrderType.delivery) : (OrderType.pickup)
        renderAddress()
        renderTotals()
        renderPaymentButtonsAlpha()
    }
    
    var orderType = OrderType.delivery

    func renderAddress(){
        self.addressNameLabel.text = (self.orderType == .delivery) ? ("delivery_address") : ("pickup_address")
        self.addressDetailLabel.text = (self.orderType == .delivery) ? ("delivery_address_details") : ("pickup_address_details")
        self.lblButtonCallToAction.text = (self.orderType == .delivery) ? ("Save On Delivery Changes?") : ("Save On Travel Time?")
        self.buttonChange.setTitle((self.orderType == .delivery) ? ("Change to pickup") : ("Change to delivery"), for: .normal)
    }
            
	var delegate: PaymentSummaryViewDelegate? = nil
	
	let db = DatabaseHandler()
	var user: User?
	var addressList = [Address]()
	var selectedAddress: Address?
	var fixedDelay = 0
	
	struct CartItem{
		var opened: Bool!
		var chef: Chef!
		var note = ""
		var deliveryCost: Double?
	}
	var cartItems = [CartItem]()
	var shouldAllowAppear = true
	
	private var isUserLoggedIn: Bool {
		return UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID) != nil
	}
	
	
	// MARK: Actions
	
	@IBAction func unwindToAddressList(sender: UIStoryboardSegue){
		if let sourceVC = sender.source as? ChooseAddressTableViewController, let selectedAddress = sourceVC.selectedAddress{
			self.selectedAddress = selectedAddress
			if self.isUserLoggedIn {
				self.getCartDetails()
				self.getFixedDelay()
			}
			self.setAddress()
		}
	}
	
	@IBAction func selectAddress(_ sender: UITapGestureRecognizer) {
		performSegue(withIdentifier: "SelectAddressSegue", sender: self)
	}
	
	
	@IBAction func addAddress(_ sender: UIButton) {
		
		if self.isUserLoggedIn {
			let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
			if(session == nil)
			{
			}
			else{
				
				let storyboard = UIStoryboard(name: "Profile", bundle: nil)
				guard let addressVC = storyboard.instantiateViewController(withIdentifier: "AddressTableVC") as? AddressTableViewController else{
					fatalError("Unexpected ViewController")
				}
				addressVC.partnerId = user?.partner_id
				addressVC.isFromCart = true
				addressVC.selectionDelegate = self
				shouldAllowAppear = false
				navigationController?.pushViewController(addressVC, animated: true)
				
			}
		} else {
			showAlert(title: "Error", msg: "Please login to add address.")
		}
	}
	
	@IBAction func contactWhatsApp(_ sender: UIButton) {
		Utils.openWhatsapp(name: user?.name ?? "Anonymous")
	}
    
	@IBAction func placeOrder(_ sender: UIButton) {
		guard self.isUserLoggedIn else {
			self.showAlertBeforeLogin(message: "Please login to place order!")
			return
		}
        
		guard selectedAddress != nil else {
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
		}
		guard let phone = user?.phone,
			!phone.isEmpty else {
				
				let alert = UIAlertController(title: "", message: "You need to add your phone number before placing an order", preferredStyle: .actionSheet)
				alert.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { (action) in
					let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)
					guard let profileVC = storyboard.instantiateViewController(withIdentifier: "updateProfileVC") as? UpdateProfileViewController else{
						fatalError("Unexpected ViewController")
					}
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
		
		if deliveryAmountLabel.text != "*" {
			
			let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
			
			if(session == nil)
				
			{
				let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
				self.present(viewController, animated: true, completion: nil)
			} else {
				
				let progressAlert = showProgressAlert()
				var orderItems = [Any]()
				for item in cartItems {
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
                    dict["delivery_cost"] = item.deliveryCost
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
                
                print(params.description)
				
				RestClient().request(WalayemApi.placeOrder, params, self) { (result, error) in
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
		} else {
			showAlert(title: "Error", msg: "Delivery is not available for your area, please refine your search.")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        renderChecks()
		setViews()
		renderTotals()
        renderPaymentButtonsAlpha()
        
        self.tableView.backgroundColor = UIColor(hexString: "F4F4F4")
        self.tableView.separatorStyle = .none
		user = User().getUserDefaults()
		
		tableView.backgroundColor = tint
		tableView.delegate = self
		tableView.dataSource = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		Utils.setupNavigationBar(nav: self.navigationController!)
		
		let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
		//self.orderView.addGestureRecognizer(gesture)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateButtonTitle) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
		
		updateButtonTitle()
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateFav) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
		
        
        self.renderTotals()

        self.tableView.reloadData()
        
        
	}
	
	@IBOutlet weak var cAddressView: UIView!
	
	@objc func updateFav()
	{
		if !isUserLoggedIn {
			self.addressView.isHidden = true
			self.addressNameLabel.isHidden = true
			self.addressDetailLabel.isHidden = true
		} else {
            self.addressView.isHidden = false
            self.addressNameLabel.isHidden = false
            self.addressDetailLabel.isHidden = false
			//			getAddress()
		}
        //self.addAddressButton.isHidden = false

	}
	
	@objc func updateButtonTitle() {
		
		if self.isUserLoggedIn {
			self.orderButton.setTitle("Proceed To Pay", for: .normal)
		} else {
			self.orderButton.setTitle("Login to Order", for: .normal)
		}
		getAddress()
	}
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		user = User().getUserDefaults()
		getCartItems()
		//		getAddress()
		updateButtonTitle()
		self.tableView.backgroundColor = UIColor.init(light: UIColor.white, dark: UIColor.black)
		
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
			//orderForLabel.text = "\(date_str)"

			let calendar = NSCalendar.current

			let timeFormatter = DateFormatter()
			timeFormatter.dateFormat = "hh:mm aa"

			let time_str = timeFormatter.string(from: date!)

			if calendar.isDateInToday(date!) {
				//orderForLabel.text = "Today at \(time_str)"
			}
			else if calendar.isDateInTomorrow(date!) {
				//orderForLabel.text = "Tomorrow at \(time_str)"
			}
			
		}else{
			//orderForLabel.text = "Delivery as soon as possible"
		}
		
		updateFav()
		if shouldAllowAppear {
			self.addressList.removeAll()
			if user?.partner_id != nil && user?.partner_id != 0 {
				//getAddress()
			}
		} else {
			shouldAllowAppear = true
		}
        
	}
	
	@objc func checkAction(sender : UITapGestureRecognizer) {
		
		let startTime = Utils.getChefStartTime()
		let endTime = Utils.getChefEndTime()
//		let minHours = Utils.getMinHours()
		let delayHours = fixedDelay/60
		
		var date = Date()
		
		var calendar = Calendar(identifier: .gregorian)
		
		print(TimeZone.current)
		
		print(calendar.timeZone)
		
		calendar.timeZone = TimeZone.current
		date = calendar.date(byAdding: .hour, value: delayHours, to: date)!
		
		var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
		
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
				
		let dialog = DatePickerDialog()
		
		dialog.setUpGap(timeGap: delayHours)
		
		dialog.show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", startTime: startTime, endTime: endTime, minimumDate: date , datePickerMode: .dateAndTime) {
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
				
				//self.orderForLabel.text = "\(date_str) at \(time_str)"
			}
		}
		
	}
	// MARK: Private methods
	
	private func setViews(){
		orderButton.layer.cornerRadius = 15
		orderButton.layer.masksToBounds = true
		
		//orderSummaryIcon.tintColor = UIColor.peach
		summaryIcon.tintColor = UIColor.seafoamBlue
		//paymentIcon.tintColor = UIColor.babyBlue
		//addressIcon.tintColor = UIColor.rosa
		
		
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
			guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else{
				fatalError("Cannot convert to CGRect")
			}
			print(keyboardFrame.height)
            
            var contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 218.0, right: 0.0)
            
            if (keyboardFrame.height > 0 && self.tabBarController!.tabBar.frame.height > 0) {
                contentInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardFrame.height - self.tabBarController!.tabBar.frame.height, right: 0.0)
            }
			
            UIView.animate(withDuration: 0.5) {
                self.tableView.contentInset = contentInsets;
                self.tableView.scrollIndicatorInsets = contentInsets;
                }
			
		}
	}
	
	@objc private func keyboardWillHide(notification: Notification){
		let contentInsets = UIEdgeInsets()
		tableView.contentInset = contentInsets;
		tableView.scrollIndicatorInsets = contentInsets;
	}
	
	private func getCartItems(){
		self.cartItems.removeAll()
		let chefs = self.db.getCartItems()
		if chefs.count == 0{
			self.changeView(true)
		}else{
			self.changeView(false)
			for chef in chefs{
				let cartItem = CartItem(opened: true, chef: chef, deliveryCost: nil)
				self.cartItems.append(cartItem)
			}
			if self.isUserLoggedIn {
				self.getCartDetails()
				self.getFixedDelay()
			} else {
				self.calculateCost()
			}
		}
		self.tableView.reloadData()
	}
	
	private func getCartDetails() {
		guard let address = self.selectedAddress else { return }
		
		var orderItems = [[String: Any]]()
		for item in cartItems {
			var products = [Any]()
			for food in item.chef.foods{
				var dict = [String: Int]()
				dict["product_id"] = food.id
				dict["quantity"] = food.quantity
				products.append(dict)
			}
			var dict = [String: Any]()
			dict["chef_id"] = item.chef.id
			dict["items"] = products
			orderItems.append(dict)
		}
		
		var params: [String: Any] = ["cart_items": orderItems]
		if address.id == 0 {
			let user = User().getUserDefaults()
			params["customer_address"] = ["new_address": [
				"address_name": address.name,
				"street": address.street,
				"city": address.city,
				"street2": "",
				"partner_id": user.partner_id ?? 0,
				"lat": "\(address.location?.latitude ?? 0)",
				"long": "\(address.location?.longitude ?? 0)"]]
		} else {
			params["customer_address"] =  ["address_id": address.id]
		}
		if orderItems.count > 0 {
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			RestClient().request(WalayemApi.cartDetails, params, self) { (result, error) in
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if let error = error {
					self.calculateCost()
					self.cartItems = self.cartItems.map({ (cartItem) -> CartItem in
                        return CartItem(opened: true, chef: cartItem.chef, note: cartItem.note, deliveryCost: nil)
					})
					self.tableView.reloadData()
					self.handleNetworkError(error)
					return
				}
				
				let value = result!["result"] as! [String: Any]
				let status = value["status"] as! Int
				if status == 0 {
					self.calculateCost()
					self.cartItems = self.cartItems.map({ (cartItem) -> CartItem in
						return CartItem(opened: true, chef: cartItem.chef, note: cartItem.note, deliveryCost: nil)
					})
					self.tableView.reloadData()
					//				let error = NSError(domain: value["message"] as? String ?? "", code: 200, userInfo: nil)
					//				self.showSorryAlertWithMessage(value["message"] as? String ?? "")
					return
				}
				guard let data = value["data"] as? [String: Any] else {
					self.calculateCost()
					self.cartItems = self.cartItems.map({ (cartItem) -> CartItem in
						return CartItem(opened: true, chef: cartItem.chef, note: cartItem.note, deliveryCost: nil)
					})
					self.tableView.reloadData()
					let error = NSError(domain: "com.walayem.status", code: 200, userInfo: nil)
					self.handleNetworkError(error)
					return
				}
				//self.summaryDeliveryChargeLabel.isHidden = true
				if let fetchedCartItems = data["cart_items"] as? [[String: Any]] {
					for fetchedCartItem in fetchedCartItems {
						guard let fetchedChef = fetchedCartItem["chef"] as? [String: Any],
							let fetchedChefId = fetchedChef["chef_id"] as? Int else {
								continue
						}
						self.cartItems = self.cartItems.map({ (cartItem) -> CartItem in
							if cartItem.chef.id == fetchedChefId {
								let fetchedDeliveryCost = fetchedCartItem["delivery_cost"] as? Double
								return CartItem(opened: true, chef: cartItem.chef, note: cartItem.note, deliveryCost: fetchedDeliveryCost)
							}
							return cartItem
						})
					}
				}
				
//				let subTotal: Double = (data["total_price"] as? Double) ?? 0.0
//				self.subtotalLabel.text = "AED \(subTotal)"
//				let totalDeliveryCharge: Double = (data["total_delivery_cost"] as? Double) ?? 0.0
//				self.deliveryAmountLabel.text = "AED \(totalDeliveryCharge)"
//				self.deliveryAmountLabel.textColor = .lightGray
//				let totalCost: Double = (data["big_total"] as? Double) ?? 0.0
//				self.totalLabel.text = "AED \(totalCost)"
//				self.deliverySummaryLabel.text = "Total Delivery"
				self.tableView.reloadData()
			}
		}
		
		let foods = db.getFoods()
		//        validateFoods(foods: foods) { (success) in
		self.cartItems.removeAll()
		let chefs = self.db.getCartItems()
		if chefs.count == 0{
			self.changeView(true)
		}else{
			self.changeView(false)
			for chef in chefs{
				let cartItem = CartItem(opened: true, chef: chef)
				self.cartItems.append(cartItem)
			}
			self.calculateCost()
		}
		self.tableView.reloadData()
		//        }
	}
	
	private func validateFoods(foods: [Food], completion: @escaping(Bool) -> Void){
		
		let params: [String: Any] = [:]
		RestClient().request(WalayemApi.getActiveFoodIds, params, self) { (result, error) in
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
		let params: [String: Int] = ["partner_id": user?.partner_id ?? 0]
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		RestClient().request(WalayemApi.address, params, self) { (result, error) in
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			
			//            if let error = error{
			//                self.handleNetworkError(error)
			//                return
			//            }
			
			if error != nil{
				let errmsg = error?.localizedDescription
				print (errmsg ?? "")
				return
			}
			let value = result!["result"] as! [String: Any]
			let status = value["status"] as! Int
			
			if (status != 0) {
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
				
				let selAddressId = AreaFilter.shared.addressId
				if selAddressId != 0{
					
					for address in self.addressList {
						if address.id == selAddressId {
							self.selectedAddress = address
							break
						}
					}
				} else {
					self.selectedAddress = nil
				}
				
				if self.selectedAddress == nil {
					self.selectedAddress = self.addressList.first
				}
				//self.setAddress()
				
				if self.selectedAddress != nil,
					self.isUserLoggedIn {
					//self.getCartDetails()
				}
			}
			
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
			//			showSorryAlertWithMessage("Some thing wrong in backend ...!")
		}
	}
	
	private func showSorryAlertWithMessage(_ msg: String){
		let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	private func setAddress(){
		addressNameLabel.text = selectedAddress?.name
		addressDetailLabel.text = selectedAddress!.city + ", " + selectedAddress!.street + ", " + selectedAddress!.extra
	}
	
        private func calculateCost(){
            var totalCost: Double = 0.0
            for item in cartItems{
                for food in item.chef.foods{
                    totalCost += Double(food.quantity) * (food.price)
                }
            }
            

            
            //subtotalLabel.text = "AED \(totalCost)"
    //        deliveryAmountLabel.text = "*"
    //        deliveryAmountLabel.textColor = .red
    //        totalLabel.attributedText = "AED \(totalCost)^{*}".superscripted(font: totalLabel.font)
            deliverySummaryLabel.text = "Total Delivery"
            let totalCost2: Double = (self.orderType == OrderType.pickup) ? (self.subTotal) : (self.bigTotal)
            self.totalLabel.text = "AED \(totalCost2)"
            self.deliveryAmountLabel.text = (self.orderType == .pickup) ? ("AED 0") : ("AED \(self.totalDeliveryCharge ?? 0)") 

            //summaryDeliveryChargeLabel.isHidden = false
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
		
		self.cartItems[section].opened = !self.cartItems[section].opened!
		//        UIView.animate(withDuration: 1.0, delay: 0, options:.beginFromCurrentState, animations: {
		
		//            self.tableView.reloadSections([section], with: .fade)
		//        })
		tableView.reloadSections([section], with: .automatic)
		//        cartItems[section].opened = !cartItems[section].opened!
	}
	
	// MARK: CartFoodFooter delegate
	
	func updateNote(sender: UITextField, section: Int) {
        if(cartItems.count > 0){
            if (sender.text?.count ?? -1 > 0 ){
                cartItems[section].note = sender.text ?? ""
            }else{
                cartItems[section].note = ""
            }
        }else{
            return
        }
        
	}
	
	// MARK: CartFoodCell delegate
	
	func didTapAddItem(sender: CartFoodTableViewCell) {
		guard let indexPath = tableView.indexPath(for: sender) else {
			fatalError("Cell does not exist")
		}
		let food = cartItems[indexPath.section].chef.foods[indexPath.row]
		if db.addQuantity(foodId: food.id ?? 0){
			if self.isUserLoggedIn {
				//getCartDetails()
			} else {
				//calculateCost()
			}
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
		if self.isUserLoggedIn {
			//getCartDetails()
		} else {
			calculateCost()
		}
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
	
	private func getFixedDelay() {
		
		var chefIds = [Int]()
		for item in cartItems {
			chefIds.append(item.chef.id)
		}
		
		let params: [String: Any] = ["chef_id": chefIds]
		RestClient().request(WalayemApi.fixedDelay, params, self) { [weak self] (result, error) in
			
			guard let self = self else { return }
			
			print(result!)	
			if error != nil {
				print(error?.localizedDescription ?? "")
				//error here
			}
			
			let value = result!["result"] as? [String: Any]
			if let status = value?["status"] as? Int, status == 0 {
				//status false
				return
			}
			
			guard let data = value?["fixed_delay"] as? Int else {
				print("error")
				return
			}
			
			self.fixedDelay = data
						
			let hr = data/60
			
			Utils.DELAY_TIME = hr
			
			var dt = Date()
			
			let dateFormatter = DateFormatter()
			
			let calendar = NSCalendar.current
			dt = calendar.date(byAdding: .hour, value: hr, to: dt)!
			
			let calHr = calendar.component(.hour, from: dt)
			
			if(calHr > 23 || calHr < 7) {
				if calHr > 23 {
					dt = calendar.date(byAdding: .day, value: 1, to: dt)!
				}
				dt = calendar.date(bySetting: .hour, value: 7, of: dt)!
			}
			
			dateFormatter.dateFormat = "MMM dd yyyy"
			
			let timeFormatter = DateFormatter()
			timeFormatter.timeZone = TimeZone.current
			timeFormatter.dateFormat = "hh:mm aa"
			
			let time_str = timeFormatter.string(from: dt)
			var date_str = dateFormatter.string(from: dt)
			
			if calendar.isDateInToday(dt) { date_str = "Today" }
			else if calendar.isDateInTomorrow(dt) { date_str = "Tomorrow" }
			
			let dateTimeFormatter = DateFormatter()
			dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			dateTimeFormatter.timeZone = TimeZone.current
			let date_time_str = dateTimeFormatter.string(from: dt)
			
			let userDefaults = UserDefaults.standard
			userDefaults.set("future", forKey: "OrderType")
			userDefaults.set(date_time_str, forKey: "OrderDate")
			userDefaults.synchronize()
			
			//self.orderForLabel.text = "\(date_str) at \(time_str)"
			
						
		}
	}
	
}

extension PaymentSummaryViewController: UITableViewDelegate, UITableViewDataSource{
	
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
		let cartItem = cartItems[indexPath.section]
		let food = cartItem.chef.foods[indexPath.row]
		cell.set(food: food, deliveryCharge: cartItem.deliveryCost)
        cell.nameLabel?.text? += " X\(food.quantity)"
        cell.discountedLabel.textColor = .gray
        cell.discountedLabel.text = "AED \(food.price*Double(food.quantity))"
        cell.priceLabel.isHidden = true
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CartFoodFooterCell") as? CartFoodFooterCell else {
			fatalError("Unexpected footer view")
		}
		footerView.delegate = self
		footerView.section = section
		let cartItem = cartItems[section]
		let foods = cartItem.chef.foods
		footerView.update(deliveryCharge: cartItem.deliveryCost ?? 0.0)//update(foods: foods, deliveryCharge: cartItem.deliveryCost)
        footerView.backgroundColor = UIColor(hexString: "F4F4F4") //UIColor.init(light: .white, dark: .black)
        footerView.clipsToBounds = true
        footerView.contentView.backgroundColor = UIColor(hexString: "F4F4F4")
        //UIColor(hexString: "FEFEFE")
		return footerView
	}
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 66
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
		let orderType = UserDefaults.standard.string(forKey: "OrderType") ?? "asap"
		
		if(orderType == "asap"){
			return 80
		}
		
		if cartItems.isEmpty {
			return 0.001
		}
		
		if cartItems[section].chef.foods.isEmpty {
			return 0.001
		}
		
        if(orderType == "future"){
            return 80
        }else{
            return 0
        }
        
		return 60
	}
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
}

extension PaymentSummaryViewController: AddressSelectionDelegate {
	
	func addressSelected(_ address: Address) {
		self.selectedAddress = address
		AreaFilter.shared.setselectedLocation(address.location, title: address.name, addressId: address.id)
		if self.isUserLoggedIn {
			self.getCartDetails()
			self.getFixedDelay()
		}
		self.setAddress()
	}
	
}
