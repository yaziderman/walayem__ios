//
//  OrderViewController.swift
//  Walayem
//
//  Created by MAC on 5/9/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class OrderViewController: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var acceptedImageView: UIImageView!
    @IBOutlet weak var cookingImageView: UIImageView!
    @IBOutlet weak var deliveryImageView: UIImageView!
    @IBOutlet weak var deliveredImageView: UIImageView!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var cookingLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var informationIcon: UIImageView!
    @IBOutlet weak var summaryIcon: UIImageView!
    @IBOutlet weak var paymentIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    var orderId: Int?
    //var orderState = OrderState.sale
    var orderDetail: OrderDetail?
    var user: User?
    var foods = [Food]()
    
    // MARK: Actions
    
    @IBAction func cancelOrder(sender: UIButton){
        let alert = UIAlertController(title: "", message: "Are you sure you want to cancel this order?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel order", style: .destructive, handler: { (action) in
            let params = ["partner_id": self.user?.partner_id as Any,
                          "order_id": self.orderId as Any,
                          "next_state": OrderState.cancel.rawValue] as [String : Any]
            
            RestClient().request(WalayemApi.changeOrderState, params) { (result, error) in
                if let error = error{
                    let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showMessagePrompt(title: "Cannot cancel order", msg: errmsg)
                    return
                }
                self.getOrderDetail(orderId: self.orderId!)
                if let navigationVC = self.splitViewController?.viewControllers.first as? UINavigationController, let orderTVC = navigationVC.topViewController as? OrderTableViewController{
                    orderTVC.getOrderHistory()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popOverController = alert.popoverPresentationController{
            popOverController.sourceView = sender
            popOverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
            popOverController.permittedArrowDirections = [.down]
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        
        setViews()
        if let orderId = orderId{
            navigationItem.title = "#WA\(orderId)"
            getOrderDetail(orderId: orderId)
        }
    }

    // MARK: Private methods
    
    private func setViews(){
        informationIcon.tintColor = UIColor.peach
        summaryIcon.tintColor = UIColor.seafoamBlue
        paymentIcon.tintColor = UIColor.babyBlue
        addressIcon.tintColor = UIColor.rosa
    }
    
    private func getOrderDetail(orderId: Int){
        showActivityIndicator()
        
        let params: [String: Int] = ["partner_id": user!.partner_id!, "order_id": orderId]
        
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
            
            guard let order_type = record["order_type"] as? String else{
                self.updateViews()
                return
            }
            var deliveryForTitle = "Delivery as soon as possible"
            
            if(order_type == "future"){  
                let orderDate = record["order_for"] as? String ?? ""
                if(orderDate == ""){
                    deliveryForTitle = "Date Removed"
                }
                else{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    let date = formatter.date(from: orderDate)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd yyyy hh:mm aa"
                    dateFormatter.timeZone = TimeZone.current
                    var date_str = ""
                    if dateFormatter.string(from: date!) != nil {
                        date_str = dateFormatter.string(from: date!)
                    }
                    deliveryForTitle = "Delivery for \(date_str ?? "")"
                    
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
        foods = orderDetail!.products
        tableView.reloadData()
        
        var statusImage: UIImage?
        switch orderDetail!.state {
        case .sale:
            statusImage = UIImage(named: "ongoing")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = false
        case .done:
            statusImage = UIImage(named: "ongoing")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = true
            
            acceptedImageView.image = UIImage(named: "filledOrderState")
        case .cooking:
            statusImage = UIImage(named: "ongoing")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = true
            
            acceptedImageView.image = UIImage(named: "filledOrderState")
            cookingImageView.image = UIImage(named: "filledOrderState")
        case .ready:
            statusImage = UIImage(named: "ongoing")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = true
            
            acceptedImageView.image = UIImage(named: "filledOrderState")
            cookingImageView.image = UIImage(named: "filledOrderState")
            deliveryImageView.image = UIImage(named: "filledOrderState")
        case .delivered:
            statusImage = UIImage(named: "completed")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = true
            
            acceptedImageView.image = UIImage(named: "filledOrderState")
            cookingImageView.image = UIImage(named: "filledOrderState")
            deliveryImageView.image = UIImage(named: "filledOrderState")
            deliveredImageView.image = UIImage(named: "filledOrderState")
        case .cancel, .rejected:
            statusImage = UIImage(named: "cancelled")?.withRenderingMode(.alwaysOriginal)
            cancelButton.isHidden = true
        default:
            cancelButton.isHidden = false
            
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: statusImage, style: .plain, target: nil, action: nil)
        
        acceptedLabel.text = Utils.getTime(orderDetail!.doneDate)
        cookingLabel.text = Utils.getTime(orderDetail!.cookingDate)
        deliveryLabel.text = Utils.getTime(orderDetail!.readyDate)
        deliveredLabel.text = Utils.getTime(orderDetail!.deliveredDate)
        
        subtotalLabel.text = "AED \(orderDetail!.amount)"
        discountLabel.text = "(AED 0.0)"
        totalLabel.text = "AED \(orderDetail!.amount)"
        addressNameLabel.text = orderDetail!.address?.name
        addressDescriptionLabel.text = (orderDetail!.address?.street)! + ", " + (orderDetail!.address?.city)!
    }
    
    private func showMessagePrompt(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showActivityIndicator(){
        if activityIndicator == nil{
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.color = UIColor.colorPrimary
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return foods.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) > 0{
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "OrderFoodHeaderCell") as? OrderFoodHeaderCell else {
                fatalError("Unexpected header cell")
            }
            headerCell.chefImageView.layer.cornerRadius = 12
            headerCell.chefImageView.layer.masksToBounds = true
            headerCell.foodSummaryIcon.tintColor = UIColor.perrywinkle
            if let orderDetail = orderDetail{
                headerCell.nameLabel.text = orderDetail.chefName ?? "Chef Removed"
                headerCell.kitchenLabel.text = orderDetail.kitchen
                headerCell.chefImageView.image = Utils.decodeImage(orderDetail.chefImage)
                headerCell.dateLabel.text = Utils.getDay(orderDetail.createDate) + "\n" + Utils.getTime(orderDetail.createDate)
            }
            return headerCell
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.tableView(tableView, numberOfRowsInSection: section) > 0{
            let footerView = UIView()
            footerView.backgroundColor = UIColor.white
            
            let titleLabel = UILabel()
            titleLabel.text = (orderDetail?.note.isEmpty)! ? "No note added" : orderDetail?.note
            titleLabel.textColor = UIColor.lightGray
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
            imageView.image = UIImage(named: "information")
            imageView.tintColor = UIColor.silverTen
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            footerView.addSubview(imageView)
            footerView.addSubview(titleLabel)
            
            imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            
            if(self.orderDetail!.state == .rejected)
            {
                let rejectTitle = UILabel()
                rejectTitle.text = "Rejected"
                rejectTitle.textColor = UIColor.red
                rejectTitle.translatesAutoresizingMaskIntoConstraints = false
                
                let rejectReason = UILabel()
                if let reason = self.orderDetail?.reject_reason
                {
                    rejectReason.text = "\"\(reason)\""
                }
                rejectReason.textColor = UIColor.lightGray
                rejectReason.translatesAutoresizingMaskIntoConstraints = false
                
                let iv2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
                iv2.image = UIImage(named: "information")
                iv2.tintColor = UIColor.red
                iv2.translatesAutoresizingMaskIntoConstraints = false
                
                footerView.addSubview(rejectTitle)
                footerView.addSubview(rejectReason)
                footerView.addSubview(iv2)
                
                iv2.heightAnchor.constraint(equalToConstant: 16).isActive = true
                iv2.widthAnchor.constraint(equalToConstant: 16).isActive = true
                
                if #available(iOS 11, *){
                    let guide = footerView.safeAreaLayoutGuide
                    
                    imageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12).isActive = true
                    imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                    
                    titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12).isActive = true
                    titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
                    titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -70).isActive = true
                    titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                    
                    iv2.topAnchor.constraint(equalTo: guide.topAnchor, constant: 42).isActive = true
                    iv2.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                    
                    rejectTitle.topAnchor.constraint(equalTo: guide.topAnchor, constant: 38).isActive = true
                    rejectTitle.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
                    rejectTitle.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -40).isActive = true
                    rejectTitle.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                    
                    rejectReason.topAnchor.constraint(equalTo: guide.topAnchor, constant: 64).isActive = true
                    rejectReason.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
                    rejectReason.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12).isActive = true
                    rejectReason.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                    
                    
                }else{
                    footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[v0]-74-|", options: [], metrics: nil, views: ["v0": imageView]))
                    footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-10-[v1]-20-|", options: .alignAllCenterY, metrics: nil, views: ["v0": imageView, "v1": titleLabel]))
                }
            }
            else
            {
                if #available(iOS 11, *){
                    let guide = footerView.safeAreaLayoutGuide
                    
                    imageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
                    imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
                    
                    titleLabel.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
                    titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
                    titleLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                    titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 20).isActive = true
                }else{
                    footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[v0]-14-|", options: [], metrics: nil, views: ["v0": imageView]))
                    footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-10-[v1]-20-|", options: .alignAllCenterY, metrics: nil, views: ["v0": imageView, "v1": titleLabel]))
                }
            }
            return footerView
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 149
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(self.orderDetail?.state == .rejected)
        {
            return 100
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = foods[indexPath.row]
        if(food.id == -1){
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryForCell", for: indexPath) as? DeliveryForTableViewCell else {
                fatalError("Unexpected cell")
            }
            cell.title_text = food.name
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderFoodCell", for: indexPath) as? OrderFoodTableViewCell else {
                fatalError("Unexpected cell")
            }
            
            cell.food = food
            
            return cell
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
