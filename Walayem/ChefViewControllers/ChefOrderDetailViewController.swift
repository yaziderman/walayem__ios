//
//  ChefOrderDetailViewController.swift
//  Walayem
//
//  Created by MAC on 5/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefOrderDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var informationIcon: UIImageView!
    @IBOutlet weak var summaryIcon: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    var orderId: Int?
    var orderState = OrderState.sale
    var user: User?
    var orderDetail: OrderDetail?
    
    // MARK: Actions
    
    @IBAction func callCustomer(_ sender: UIButton) {
        if let orderDetail = orderDetail, let address = orderDetail.address{
            if let url = URL(string: "tel://\(address.phone!)"){
                UIApplication.shared.open(url, options: [:], completionHandler: { (Success) in
                    print("Make call \(Success)")
                })
            }
        }
    }
    
    @IBAction func changeState(_ sender: UIButton) {
        let progressAlert = showProgressAlert()
        
        var nextState = OrderState.sale
        switch orderState {
        case .sale:
            nextState = OrderState.done
        case .done:
            nextState = OrderState.cooking
        case .cooking:
            nextState = OrderState.ready
        case .ready:
            nextState = OrderState.delivered
        default:
            print ("Invalid order state")
        }
        
        let params = ["partner_id": user?.partner_id as Any,
                      "order_id": orderId as Any,
                      "next_state": nextState.rawValue] as [String : Any]
        
        RestClient().request(WalayemApi.changeOrderState, params) { (result, error) in
            progressAlert.stopAnimating()
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showAlert(title: "Error", msg: errmsg)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelOrder(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Why do want to reject the order?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter resaon for rejection"
            textField.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action) in
            let progressAlert = self.showProgressAlert()
            let reason = alert.textFields![0].text ?? ""
            
            let params = ["partner_id": self.user?.partner_id as Any,
                          "order_id": self.orderId as Any,
                          "next_state": OrderState.rejected.rawValue,
                          "reject_reason": reason] as [String : Any]

            RestClient().request(WalayemApi.changeOrderState, params) { (result, error) in
                progressAlert.stopAnimating()
                if let error = error{
                    let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showAlert(title: "Error", msg: errmsg)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        
        tableView.delegate = self
        tableView.dataSource = self
        setViews()
        if let _ = orderId{
            var title: String?
            
            switch orderState{
            case .sale:
                title = "Order Pending"
                stateButton.setTitle("Accept order", for: .normal)
            case .done:
                title = "Order Done"
                stateButton.setTitle("Cooking", for: .normal)
                cancelButton.isHidden = true
            case .cooking:
                title = "Order Cooking"
                stateButton.setTitle("Ready", for: .normal)
                cancelButton.isHidden = true
            case .ready:
                title = "Order Ready"
                stateButton.setTitle("Delivered", for: .normal)
                cancelButton.isHidden = true
            case .delivered:
                title = "Order Completed"
                stateButton.isHidden = true
                cancelButton.isHidden = true
            case .rejected, .cancel:
                title = "Order Cancelled"
                stateButton.isHidden = true
                cancelButton.isHidden = true
            }
            navigationItem.title = title
            getOrderDetail()
        }
       Utils.setupNavigationBar(nav: self.navigationController!)
    }
    
    // MARK: Private methods
    
    private func setViews(){
        stateButton.layer.cornerRadius = 15
        stateButton.layer.masksToBounds = true
        
        informationIcon.tintColor = UIColor.rosa
        summaryIcon.tintColor = UIColor.babyBlue
    }
    
    @IBAction func whatsAppCustomer(_ sender: UIButton) {
                if let orderDetail = orderDetail, let address = orderDetail.address{
            let textMsg = "*Greetings from Walayem*, This is *\(user?.name ?? "CHEF_NAME")*.\nI got your order and would like to confirm."
                    
            let urlWhats = "whatsapp://send?phone=\(address.phone!)&abid=12354&text=\(textMsg)"
                if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
                        if let whatsappURL = URL(string: urlString) {
                            if UIApplication.shared.canOpenURL(whatsappURL){
                                if #available(iOS 10.0, *) {
                                          UIApplication.shared.open(whatsappURL, options: [:],completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(whatsappURL)
                                }
                        }
                        else {
                            print("Install Whatsapp")
                        }
                }
            }
        }
    }
    
    private func getOrderDetail(){
        showActivityIndicator()
        let params: [String: Int] = ["partner_id": user!.partner_id!, "order_id": orderId!]
        
        RestClient().request(WalayemApi.orderDetail, params) { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                let alert  = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            self.hideActivityIndicator()
            let value = result!["result"] as! [String: Any]
            let record = value["order_detail"] as! [String: Any]
            self.orderDetail = OrderDetail(record: record)
            self.updateViews()
            
            var deliveryForTitle = "Delivery as soon as possible"
            
            guard let order_type = record["order_type"] as? String else{
                let deliveryForCell = Food(id: -1, name: deliveryForTitle, price: -1, quantity: -1, preparationTime: -1)
                self.orderDetail?.products.append(deliveryForCell)
                self.updateViews()
               print("oder_type not found!!")
                return
            }
             print("order type--->>>\(order_type)")
            if(order_type == "future"){
                if record["order_for"] != nil{
                    let orderDate = record["order_for"] as? String ?? "1987-12-31 12:00:00"
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    let date = formatter.date(from: orderDate)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd yyyy hh:mm aa"
                    dateFormatter.timeZone = TimeZone.current
                    let date_str = dateFormatter.string(from: date!)
                    deliveryForTitle = "Delivery for \(date_str)"
                    
                    let calendar = NSCalendar.current
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.timeZone = TimeZone.current
                    timeFormatter.dateFormat = "hh:mm aa"
                    
                    let time_str = timeFormatter.string(from: date!)
                    
                    if calendar.isDateInToday(date!) {
                        deliveryForTitle = "Delivery for today at \(time_str)"
                    }
                    else if calendar.isDateInTomorrow(date!) {
                        deliveryForTitle = "Delivery for tomorrow at \(time_str)"
                    }
                }
                
            }
            
            //delivery for row at the end
            let deliveryForCell = Food(id: -1, name: deliveryForTitle, price: -1, quantity: -1, preparationTime: -1)
            self.orderDetail?.products.append(deliveryForCell)
            self.updateViews()
        }
    }
    
    private func updateViews(){
        tableView.reloadData()
        
        customerNameLabel.text = orderDetail?.customer
        addressLabel.text = orderDetail!.address!.name + ", " + orderDetail!.address!.street + ", " + orderDetail!.address!.city
        deliveryLabel.text = "Out for delivery"
        
        subtotalLabel.text = "AED \(orderDetail!.amount)"
        discountLabel.text = "(AED 0.0)"
        totalLabel.text = "AED \(orderDetail!.amount)"
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.hidesWhenStopped = true
        }
        tableView.backgroundView = activityIndicator
        tableView.tableHeaderView?.isHidden = true
        tableView.tableFooterView?.isHidden = true
        
        activityIndicator.startAnimating()
        
    }
    
    private func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        tableView.tableHeaderView?.isHidden = false
        tableView.tableFooterView?.isHidden = false
        
    }
    
    private func showProgressAlert() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        let rightBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

   
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChefOrderDetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = orderDetail{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foods = orderDetail?.products{
            return foods.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "ChefOrderFoodHeader") as? ChefOrderFoodHeaderCell else {
            fatalError("Unexpected header cell")
        }
        headerCell.iconView.tintColor = UIColor.peach
        if let orderDetail = orderDetail{
            headerCell.titleLabel.text = "Order #WA\(orderId ?? 0)"
            headerCell.timeLabel.text = "\(Utils.getDay(orderDetail.createDate))\n\(Utils.getTime(orderDetail.createDate))"
        }
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = self.orderDetail?.products[indexPath.row]
        if(food?.id == -1){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryForCell", for: indexPath) as? DeliveryForTableViewCell else {
                fatalError("Unexpected cell")
            }
            cell.title_text = food?.name
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChefOrderFoodCell", for: indexPath) as? ChefOrderFoodCell else {
                fatalError("Unexpected cell")
            }
            let food = orderDetail?.products[indexPath.row]
            cell.food = food
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerCell = tableView.dequeueReusableCell(withIdentifier: "ChefFoodFooter") as? ChefOrderFoodFooterCell else {
            fatalError("Unexpected header cell")
        }
        footerCell.noteIcon.tintColor = UIColor.silverTen
        footerCell.timeIcon.tintColor = UIColor.silverTen
        if let orderDetail = orderDetail{
            footerCell.notesLabel.text = orderDetail.note.isEmpty ? "No note added" : orderDetail.note
            var totalTime = 0
            for food in orderDetail.products{
                totalTime += food.preparationTime
            }
            let time = Int(max(1, round( Double(totalTime) / 60.0)))
            footerCell.preparationTimeLabel.text = "\(time) hour(s) preparation time"
        }
        return footerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 88
    }

    
}
